/*
*  File: WeatherViewModel.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 04.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import CoreLocation

/// A ViewModel responsible for managing weather data for the current location
/// and searched cities. Supports async/await and reactive updates.
@MainActor
final class WeatherViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentLocationWeatherData: WeatherData?
    @Published var searchedWeatherData: WeatherData?
    @Published var isLoading = false
    @Published var fetchError: Error?

    // MARK: - Dependencies

    let weatherService: WeatherService
    let appSettings: AppSettings

    // MARK: - Initialization

    init(weatherService: WeatherService, appSettings: AppSettings) {
        self.weatherService = weatherService
        self.appSettings = appSettings
    }

    // MARK: - Fetch Current Location

    func fetchCurrentLocationWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        Task {
            withAnimation { isLoading = true }
            fetchError = nil

            print("📡 Fetching weather for: \(latitude), \(longitude)")

            do {
                let data = try await weatherService.fetch(byCoordinates: latitude, longitude: longitude)
                currentLocationWeatherData = data
                print("✅ Loaded weather for current location: \(data.location.name)")
            } catch {
                fetchError = error
                print("❌ Failed to load current location weather: \(error.localizedDescription)")
            }

            withAnimation { isLoading = false }
        }
    }

    // MARK: - Fetch by City Name

    func searchCityWeather(cityName: String) {
        let trimmed = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            withAnimation { isLoading = true }
            fetchError = nil

            do {
                let data = try await weatherService.fetch(byCityName: trimmed)
                searchedWeatherData = data
                print("🔍 Found weather for: \(data.location.name)")
            } catch {
                fetchError = error
                print("❌ Search failed for city: \(error.localizedDescription)")
            }

            withAnimation { isLoading = false }
        }
    }

    // MARK: - Reset Search

    func clearSearchResult() {
        searchedWeatherData = nil
        fetchError = nil
    }
}
