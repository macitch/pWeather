/*
*  File: WeatherPagerViewModel.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 07.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import Combine
import CoreLocation

/// Manages the list of cities shown in the weather pager, including weather loading and syncing with saved preferences.
@MainActor
final class WeatherPagerViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var cityList: [CityInfo] = []
    @Published var selectedIndex = 0
    @Published var weatherCache: [String: WeatherData] = [:]

    // MARK: - Dependencies

    private let weatherService: WeatherService
    private let appSettings: AppSettings
    private var cancellables = Set<AnyCancellable>()

    private(set) var currentLocationCity: CityInfo?

    // MARK: - Initialization

    init(weatherService: WeatherService, appSettings: AppSettings) {
        self.weatherService = weatherService
        self.appSettings = appSettings
    }

    // MARK: - Selected City

    var selectedCity: CityInfo? {
        guard selectedIndex >= 0, selectedIndex < cityList.count else { return nil }
        return cityList[selectedIndex]
    }

    // MARK: - Set Current Location

    func setCurrentLocationCity(_ city: CityInfo) {
        if let current = currentLocationCity, isSameCity(current, as: city) {
            print("🔁 Skipping update — same current location: \(city.name)")
            return
        }

        print("📍 Set current location city to: \(city.name)")
        currentLocationCity = city

        if cancellables.isEmpty {
            appSettings.$savedCities
                .sink { [weak self] cities in
                    self?.refreshCityList(with: cities)
                }
                .store(in: &cancellables)
        }

        refreshCityList(with: appSettings.savedCities)

        if weatherCache[city.id] == nil {
            Task { await loadWeather(for: city) }
        }
    }

    // MARK: - Refresh City List

    private func refreshCityList(with saved: [CityInfo]) {
        guard let current = currentLocationCity else {
            print("⚠️ No current location set during refresh.")
            return
        }

        let filtered = saved.filter { !isSameCity($0, as: current) }
        cityList = [current] + filtered

        print("🧭 Updated city list:")
        for (index, city) in cityList.enumerated() {
            let marker = city.isCurrentLocation ? "(Current)" : ""
            print("  [\(index)] \(city.name) \(marker)")
        }
    }

    // MARK: - City Comparison

    func isSameCity(_ a: CityInfo, as b: CityInfo) -> Bool {
        let nameMatch = a.name.lowercased() == b.name.lowercased()
        let latMatch = abs(a.latitude - b.latitude) < 0.01
        let lonMatch = abs(a.longitude - b.longitude) < 0.01
        return nameMatch || (latMatch && lonMatch)
    }

    // MARK: - Weather Data

    func loadWeather(for city: CityInfo) async {
        guard weatherCache[city.id] == nil else { return }

        print("📦 Loading weather for city ID: \(city.id)")

        do {
            let data = try await weatherService.fetch(byCoordinates: city.latitude, longitude: city.longitude)
            weatherCache[city.id] = data
        } catch {
            print("⚠️ Failed to load weather for \(city.name): \(error.localizedDescription)")
        }
    }

    func refreshWeather(for city: CityInfo) async {
        do {
            let data = try await weatherService.fetch(byCoordinates: city.latitude, longitude: city.longitude)
            weatherCache[city.id] = data
        } catch {
            print("⚠️ Failed to refresh weather for \(city.name): \(error.localizedDescription)")
        }
    }

    func preloadAllCities() async {
        var seen = Set<String>()
        for city in cityList where !seen.contains(city.id) {
            seen.insert(city.id)
            await loadWeather(for: city)
        }
    }

    // MARK: - City Management

    func addCity(from weatherData: WeatherData) {
        let newCity = CityInfo(
            name: weatherData.location.name,
            latitude: weatherData.location.lat,
            longitude: weatherData.location.lon,
            isCurrentLocation: false
        )

        print("➕ Attempting to add city: \(newCity.name)")

        if let current = currentLocationCity, isSameCity(newCity, as: current) {
            print("⚠️ \(newCity.name) is already the current location. Skipping add.")
            return
        }

        guard !appSettings.savedCities.contains(where: { isSameCity($0, as: newCity) }) else {
            print("⚠️ \(newCity.name) is already in saved cities.")
            return
        }

        appSettings.addCity(newCity)
        weatherCache[newCity.id] = weatherData
    }

    func deleteCity(_ city: CityInfo) {
        appSettings.deleteCity(city)
        weatherCache[city.id] = nil
    }

    func reorderCities(from source: IndexSet, to destination: Int) {
        appSettings.reorderCities(from: source, to: destination)
    }

    func resetSavedCities() {
        print("🗑 Clearing all saved cities...")
        appSettings.clearAllCities()

        let currentID = currentLocationCity?.id
        weatherCache = weatherCache.filter { $0.key == currentID }

        refreshCityList(with: appSettings.savedCities)
    }
}
