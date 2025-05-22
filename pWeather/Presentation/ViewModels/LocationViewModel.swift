/*
*  File: LocationViewModel.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import Combine

/// ViewModel responsible for managing city search, search results, and saving cities to app settings.
@MainActor
final class LocationViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Stores weather data results for the current city search.
    @Published var searchResults: [WeatherData] = []

    /// Indicates whether a search is currently in progress.
    @Published var isLoading = false

    /// Holds any error that occurred during the search.
    @Published var error: Error?

    // MARK: - Dependencies

    private let weatherService: WeatherService
    private let appSettings: AppSettings

    // MARK: - Initialization

    /// Initializes the view model with a weather service and app settings.
    init(weatherService: WeatherService = WeatherManager(), appSettings: AppSettings) {
        self.weatherService = weatherService
        self.appSettings = appSettings
    }

    // MARK: - Accessors

    /// Provides access to the list of currently saved cities.
    var savedCities: [CityInfo] {
        appSettings.savedCities
    }

    // MARK: - Search

    /// Searches for weather data by city name and updates `searchResults`.
    /// Trims whitespace and guards against empty input.
    func searchCityWeather(cityName: String) {
        let trimmed = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            isLoading = true
            error = nil
            do {
                let weatherData = try await weatherService.fetch(byCityName: trimmed)
                searchResults = [weatherData]
                print("🔍 Search result: \(weatherData.location.name)")
            } catch {
                self.error = error
                print("❌ Search failed: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }

    // MARK: - Save

    /// Saves a city to the saved list using weather data.
    /// Avoids duplicate entries based on city ID.
    func saveCity(from data: WeatherData) {
        let city = CityInfo(
            name: data.location.name,
            latitude: data.location.lat,
            longitude: data.location.lon,
            isCurrentLocation: false
        )

        if !appSettings.savedCities.contains(where: { $0.id == city.id }) {
            appSettings.addCity(city)
            print("✅ Saved city: \(city.name)")
        } else {
            print("⚠️ City already saved: \(city.name)")
        }
    }

    // MARK: - Helpers

    /// Clears the current error, typically after user acknowledgement or retry.
    func clearError() {
        error = nil
    }

    /// Clears search results, e.g. when the input is empty or after a city is saved.
    func clearSearchResults() {
        searchResults = []
    }
}
