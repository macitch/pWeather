/*
*  File: WeatherViewModel.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 04.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import Combine
import CoreLocation

/// A ViewModel responsible for fetching and managing weather data for the current location
/// and searched cities. It supports reactive updates, error handling, and async operations.
@MainActor
final class WeatherViewModel: ObservableObject {

    // MARK: - Published State

    /// Weather data for the user’s current location.
    @Published var currentLocationWeatherData: WeatherData? = nil

    /// Weather data for a city searched via the search field.
    @Published var searchedWeatherData: WeatherData? = nil

    /// Indicates whether a fetch operation is currently in progress.
    @Published var isLoading: Bool = false

    /// Holds any error encountered during a fetch or search operation.
    @Published var error: Error? = nil

    // MARK: - Dependencies

    /// The weather service manager that provides network access.
    let weatherManager: WeatherManager

    /// Shared app settings used for display formatting and preferences.
    let appSettings: AppSettings

    // MARK: - Initialization

    /// Initializes the view model with a weather manager and app settings.
    init(
        weatherManager: WeatherManager,
        appSettings: AppSettings
    ) {
        self.weatherManager = weatherManager
        self.appSettings = appSettings
    }

    // MARK: - Current Location Weather

    /// Fetches weather data for the given coordinates (typically from the user’s current location).
    /// Updates `currentLocationWeatherData` and handles errors.
    func fetchCurrentLocationWeatherData(latitude: Double, longitude: Double) {
        Task {
            isLoading = true
            error = nil
            print("📡 Fetching weather for: \(latitude), \(longitude)")

            do {
                let data = try await weatherManager.fetchWeatherByCoordinates(
                    latitude: latitude,
                    longitude: longitude
                )
                currentLocationWeatherData = data
                print("✅ Loaded weather for current location: \(data.location.name)")
            } catch {
                self.error = error
                print("❌ Failed to load current location weather: \(error.localizedDescription)")
            }

            isLoading = false
        }
    }

    // MARK: - City Search Weather

    /// Searches for weather data using a city name.
    /// Updates `searchedWeatherData` and handles errors.
    func searchCityWeather(cityName: String) {
        let trimmed = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            isLoading = true
            error = nil

            do {
                let data = try await weatherManager.fetch(byCityName: trimmed)
                searchedWeatherData = data
                print("🔍 Found weather for: \(data.location.name)")
            } catch {
                self.error = error
                print("❌ Search failed for city: \(error.localizedDescription)")
            }

            isLoading = false
        }
    }

    // MARK: - Fetch with Completion Handler

    /// Performs a fetch using a completion handler for interoperability with non-async code.
    func fetchWeather(for cityName: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        Task {
            do {
                let data = try await weatherManager.fetch(byCityName: cityName)
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Reset

    /// Clears the last search result and error.
    func clearSearchResult() {
        searchedWeatherData = nil
        error = nil
    }
}
