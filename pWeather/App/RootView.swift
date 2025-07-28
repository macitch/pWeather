/*
*  File: RootView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Root view that initializes and manages the primary flow of the app.
/// Handles location authorization, weather fetching, and routing to appropriate UI screens.
struct RootView: View {

    // MARK: - Environment

    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var weatherViewModel: WeatherViewModel
    @EnvironmentObject private var weatherPagerViewModel: WeatherPagerViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.colorScheme) private var scheme

    // MARK: - UI State

    /// Indicates when content is ready to be shown after weather data loads.
    @State private var isReadyToShowContent = false

    // MARK: - View

    var body: some View {
        ZStack {
            scheme.background.ignoresSafeArea()

            switch contentState {
            case .requestingLocation:
                LocationRequestView()

            case .error(let message):
                ErrorView(
                    title: "Something went wrong",
                    message: message,
                    retryAction: { fetchWeatherIfLocationAvailable() },
                    showSettingsButton: message.contains("permission"),
                    openSettingsAction: openSystemSettings
                )

            case .loading:
                VStack(spacing: 20) {
                    LoadingView()
                    Text("Fetching data for your location…")
                        .font(.appSubheadline)
                        .foregroundColor(scheme.textSecondary)
                }

            case .ready:
                BottomTabView()
            }
        }
        .onAppear {
            print("📲 RootView appeared.")
            fetchWeatherIfLocationAvailable()
        }
        .onReceive(locationManager.$userLocation) { location in
            guard let loc = location else {
                print("⚠️ userLocation is nil")
                return
            }

            print("📍 Location update: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")

            // Avoid unnecessary refetches
            if let current = weatherViewModel.currentLocationWeatherData,
               abs(current.location.lat - loc.coordinate.latitude) < 0.001,
               abs(current.location.lon - loc.coordinate.longitude) < 0.001 {
                print("🟡 Location unchanged — skipping refetch.")
                return
            }

            isReadyToShowContent = false
            fetchWeather(for: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        }
        .onReceive(weatherViewModel.$currentLocationWeatherData) { data in
            guard let data else {
                print("⚠️ No weather data yet.")
                return
            }

            print("✅ Weather data received: \(data.location.name)")

            let currentCity = CityInfo(
                name: data.location.name,
                latitude: data.location.lat,
                longitude: data.location.lon,
                isCurrentLocation: true
            )

            // Remove duplicates from saved list
            appSettings.savedCities.removeAll {
                weatherPagerViewModel.isSameCity($0, as: currentCity)
            }

            print("🧹 Removed duplicates from savedCities: \(currentCity.name)")

            // Update pager with current city
            weatherPagerViewModel.setCurrentLocationCity(currentCity)

            // Delay UI presentation for smoother transition
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                isReadyToShowContent = true
            }
        }
    }

    // MARK: - Derived View State

    /// Determines the UI state based on location and weather data availability.
    private var contentState: ContentState {
        if locationManager.userLocation == nil {
            return .requestingLocation
        } else if let error = weatherViewModel.fetchError?.localizedDescription {
            return .error(error)
        } else if weatherViewModel.currentLocationWeatherData == nil || !isReadyToShowContent {
            return .loading
        } else {
            return .ready
        }
    }

    // MARK: - Weather Fetching

    /// Attempts to fetch weather data if the user’s location is available.
    private func fetchWeatherIfLocationAvailable() {
        if let loc = locationManager.userLocation {
            fetchWeather(for: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        } else {
            print("⚠️ No userLocation available.")
            Task { @MainActor in
                locationManager.requestAuthorization()
            }
        }
    }

    /// Fetches current location weather data using the provided coordinates.
    private func fetchWeather(for latitude: Double, longitude: Double) {
        weatherViewModel.fetchCurrentLocationWeatherData(
            latitude: latitude,
            longitude: longitude
        )
    }

    // MARK: - System Settings

    /// Opens the app’s system settings for location permission adjustments.
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - View State Enum

    /// Represents the four primary content states shown in the root view.
    private enum ContentState {
        case requestingLocation
        case error(String)
        case loading
        case ready
    }
}
