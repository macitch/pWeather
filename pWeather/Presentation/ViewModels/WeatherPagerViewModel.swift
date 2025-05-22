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

/// ViewModel that manages the list of cities displayed in the weather pager,
/// including loading, caching, and syncing weather data.
@MainActor
final class WeatherPagerViewModel: ObservableObject {

    // MARK: - Published Properties

    /// The complete list of cities shown in the pager view (first is current location).
    @Published var cityList: [CityInfo] = []

    /// The currently selected index in the pager.
    @Published var selectedIndex: Int = 0

    /// Cached weather data keyed by city ID.
    @Published var weatherCache: [String: WeatherData] = [:]

    // MARK: - Dependencies

    private let weatherService: WeatherManager
    private let appSettings: AppSettings
    private var cancellables = Set<AnyCancellable>()

    /// Tracks the current location as a city entry.
    private(set) var currentLocationCity: CityInfo?

    // MARK: - Initialization

    init(weatherService: WeatherManager, appSettings: AppSettings) {
        self.weatherService = weatherService
        self.appSettings = appSettings
    }

    // MARK: - Computed Properties

    /// Returns the currently selected city, if valid.
    var selectedCity: CityInfo? {
        guard selectedIndex >= 0, selectedIndex < cityList.count else { return nil }
        return cityList[selectedIndex]
    }

    // MARK: - Set Current Location

    /// Sets the current location city and begins syncing saved cities.
    func setCurrentLocationCity(_ city: CityInfo) {
        if let current = currentLocationCity, isSameCity(current, as: city) {
            print("🔁 Skipping update — same current location: \(city.name)")
            return
        }

        print("📍 Set current location city to: \(city.name)")
        currentLocationCity = city

        // Start observing saved cities once current location is known
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

    // MARK: - City List Management

    /// Updates the pager's city list, ensuring current location is first.
    private func refreshCityList(with saved: [CityInfo]) {
        guard let current = currentLocationCity else {
            print("⚠️ No currentLocationCity set during refresh.")
            return
        }

        var updatedList: [CityInfo] = [current]
        let filtered = saved.filter { !isSameCity($0, as: current) }
        updatedList.append(contentsOf: filtered)
        cityList = updatedList

        print("🧭 Updated city list:")
        for (index, city) in updatedList.enumerated() {
            let marker = city.isCurrentLocation ? "(Current)" : ""
            print("  [\(index)] \(city.name) \(marker)")
        }
    }

    /// Determines whether two cities represent the same location.
    func isSameCity(_ a: CityInfo, as b: CityInfo) -> Bool {
        let nameMatch = a.name.lowercased() == b.name.lowercased()
        let latMatch = abs(a.latitude - b.latitude) < 0.01
        let lonMatch = abs(a.longitude - b.longitude) < 0.01
        return nameMatch || (latMatch && lonMatch)
    }

    // MARK: - Weather Data Management

    /// Loads weather data for a city if not already cached.
    func loadWeather(for city: CityInfo) async {
        guard weatherCache[city.id] == nil else { return }
        print("📦 Loading weather for city ID: \(city.id)")
        do {
            let data = try await weatherService.fetchWeatherByCoordinates(
                latitude: city.latitude,
                longitude: city.longitude
            )
            weatherCache[city.id] = data
        } catch {
            print("⚠️ Failed to load weather for \(city.name): \(error)")
        }
    }

    /// Forces a weather refresh for a city, even if already cached.
    func refreshWeather(for city: CityInfo) async {
        do {
            let data = try await weatherService.fetchWeatherByCoordinates(
                latitude: city.latitude,
                longitude: city.longitude
            )
            weatherCache[city.id] = data
        } catch {
            print("⚠️ Failed to refresh weather for \(city.name): \(error)")
        }
    }

    /// Preloads weather data for all cities in the list.
    func preloadAllCities() async {
        var seenIDs = Set<String>()
        for city in cityList where !seenIDs.contains(city.id) {
            seenIDs.insert(city.id)
            await loadWeather(for: city)
        }
    }

    // MARK: - Saved City Management

    /// Adds a new city to the saved list and caches its weather data.
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

        guard !appSettings.savedCities.contains(where: { $0.id == newCity.id }) else {
            print("⚠️ City \(newCity.name) is already saved.")
            return
        }

        appSettings.addCity(newCity)
        weatherCache[newCity.id] = weatherData
    }

    /// Deletes a city from saved list and cache.
    func deleteCity(_ city: CityInfo) {
        appSettings.deleteCity(city)
        weatherCache[city.id] = nil
    }

    /// Reorders cities in the saved list (excluding current location).
    func reorderCities(from source: IndexSet, to destination: Int) {
        appSettings.reorderCities(from: source, to: destination)
    }

    /// Clears all saved cities, retaining only the current location.
    func resetSavedCities() {
        print("🗑 Clearing all saved cities...")
        appSettings.clearAllCities()

        let currentID = currentLocationCity?.id
        weatherCache = weatherCache.filter { $0.key == currentID }

        refreshCityList(with: appSettings.savedCities)
    }
}
