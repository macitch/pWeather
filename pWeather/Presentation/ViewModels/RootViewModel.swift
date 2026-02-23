/*
*  File: RootViewModel.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2026.
*  License: MIT - Copyright (C) 2026. macitch.
*/

import Foundation
import Combine
import CoreLocation

@MainActor
final class RootViewModel: ObservableObject {

    enum ContentState: Equatable {
        case requestingLocation
        case locationError(String)
        case error(String)
        case loading
        case ready
    }

    @Published private(set) var contentState: ContentState = .loading
    @Published private(set) var nonBlockingMessage: String?

    private let locationManager: LocationManager
    private let weatherViewModel: WeatherViewModel
    private let weatherPagerViewModel: WeatherPagerViewModel
    private let appSettings: AppSettings

    private var cancellables = Set<AnyCancellable>()

    private var isFetchingWeather = false
    private var pendingCoordinates: CLLocationCoordinate2D?
    private var readyTask: Task<Void, Never>?
    private var isReadyToShowContent = false

    init(
        locationManager: LocationManager,
        weatherViewModel: WeatherViewModel,
        weatherPagerViewModel: WeatherPagerViewModel,
        appSettings: AppSettings
    ) {
        self.locationManager = locationManager
        self.weatherViewModel = weatherViewModel
        self.weatherPagerViewModel = weatherPagerViewModel
        self.appSettings = appSettings

        bind()
        updateContentState()
    }

    func onAppear() {
        fetchWeatherIfLocationAvailable()
    }

    func retryLocationFlow() {
        locationManager.retryLocationFlow()
    }

    func clearNonBlockingMessage() {
        nonBlockingMessage = nil
    }

    func fetchWeatherIfLocationAvailable() {
        if let loc = locationManager.userLocation {
            enqueueOrFetchWeather(for: loc.coordinate)
        } else {
            locationManager.retryLocationFlow()
        }
    }

    // MARK: - Bindings

    private func bind() {
        locationManager.$userLocation
            .compactMap { $0 }
            .debounce(for: .seconds(locationManager.debounceInterval), scheduler: RunLoop.main)
            .sink { [weak self] loc in
                self?.handleLocationUpdate(loc)
            }
            .store(in: &cancellables)

        locationManager.$locationError
            .sink { [weak self] _ in
                self?.updateContentState()
            }
            .store(in: &cancellables)

        appSettings.$savedCities
            .sink { [weak self] _ in
                self?.updateContentState()
            }
            .store(in: &cancellables)

        weatherViewModel.$currentLocationWeatherData
            .sink { [weak self] data in
                guard let self else { return }
                if let data {
                    self.handleWeatherData(data)
                }
                self.updateContentState()
            }
            .store(in: &cancellables)

        weatherViewModel.$currentLocationError
            .sink { [weak self] _ in
                self?.updateContentState()
            }
            .store(in: &cancellables)

        weatherViewModel.$isLoadingCurrentLocation
            .removeDuplicates()
            .sink { [weak self] loading in
                guard let self else { return }
                guard self.isFetchingWeather, loading == false else { return }
                self.isFetchingWeather = false
                self.fetchQueuedWeatherIfNeeded()
                self.updateContentState()
            }
            .store(in: &cancellables)
    }

    // MARK: - Location/Weather Orchestration

    private func handleLocationUpdate(_ loc: CLLocation) {
        if let current = weatherViewModel.currentLocationWeatherData,
           abs(current.location.lat - loc.coordinate.latitude) < 0.001,
           abs(current.location.lon - loc.coordinate.longitude) < 0.001 {
            return
        }

        enqueueOrFetchWeather(for: loc.coordinate)
    }

    private func handleWeatherData(_ data: WeatherData) {
        let currentCity = CityInfo(
            name: data.location.name,
            latitude: data.location.lat,
            longitude: data.location.lon,
            isCurrentLocation: true
        )

        appSettings.removeCity { [weak weatherPagerViewModel] in
            guard let weatherPagerViewModel else { return false }
            return weatherPagerViewModel.isSameCity($0, as: currentCity)
        }

        weatherPagerViewModel.setCurrentLocationCity(currentCity)

        readyTask?.cancel()
        readyTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard !Task.isCancelled else { return }
            isReadyToShowContent = true
            updateContentState()
        }
    }

    private func enqueueOrFetchWeather(for coordinate: CLLocationCoordinate2D) {
        if isFetchingWeather {
            pendingCoordinates = coordinate
            return
        }

        pendingCoordinates = nil
        isReadyToShowContent = false
        readyTask?.cancel()
        readyTask = nil

        isFetchingWeather = true
        updateContentState()
        fetchWeather(for: coordinate.latitude, longitude: coordinate.longitude)
    }

    private func fetchQueuedWeatherIfNeeded() {
        guard let next = pendingCoordinates else { return }
        pendingCoordinates = nil
        enqueueOrFetchWeather(for: next)
    }

    private func fetchWeather(for latitude: Double, longitude: Double) {
        weatherViewModel.fetchCurrentLocationWeatherData(latitude: latitude, longitude: longitude)
    }

    // MARK: - Content State

    private func updateContentState() {
        let decision = resolveContentState(
            hasSavedCities: !appSettings.savedCities.isEmpty,
            userLocation: locationManager.userLocation,
            locationError: locationManager.locationError,
            currentLocationWeatherData: weatherViewModel.currentLocationWeatherData,
            currentLocationError: weatherViewModel.currentLocationError,
            isReadyToShowContent: isReadyToShowContent
        )

        nonBlockingMessage = decision.nonBlockingMessage
        contentState = decision.contentState
    }

    private struct ContentStateDecision {
        let contentState: ContentState
        let nonBlockingMessage: String?
    }

    private func resolveContentState(
        hasSavedCities: Bool,
        userLocation: CLLocation?,
        locationError: Error?,
        currentLocationWeatherData: WeatherData?,
        currentLocationError: Error?,
        isReadyToShowContent: Bool
    ) -> ContentStateDecision {
        var nonBlockingMessage: String?

        if let locError = locationError?.localizedDescription {
            if hasSavedCities {
                nonBlockingMessage = locError
            } else {
                return ContentStateDecision(contentState: .locationError(locError), nonBlockingMessage: nil)
            }
        }

        if userLocation == nil && !hasSavedCities {
            return ContentStateDecision(contentState: .requestingLocation, nonBlockingMessage: nil)
        }

        if let weatherError = currentLocationError?.localizedDescription {
            if hasSavedCities {
                nonBlockingMessage = weatherError
            } else {
                return ContentStateDecision(contentState: .error(weatherError), nonBlockingMessage: nil)
            }
        }

        if hasSavedCities {
            return ContentStateDecision(contentState: .ready, nonBlockingMessage: nonBlockingMessage)
        }

        if currentLocationWeatherData == nil || !isReadyToShowContent {
            return ContentStateDecision(contentState: .loading, nonBlockingMessage: nil)
        }

        return ContentStateDecision(contentState: .ready, nonBlockingMessage: nil)
    }
}

