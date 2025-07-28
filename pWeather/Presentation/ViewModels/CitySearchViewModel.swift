/*
 * File: CitySearchViewModel.swift
 * Project: pWeather
 * Author: macitch.(@https://www.github.com/macitch)
 * Created: On 29.07.2025.
 * License: MIT - Copyright © 2025 macitch. All rights reserved.
 */

import SwiftUI
import Combine

/// ViewModel responsible for searching weather data by city name.
/// Isolated from city saving or app settings to promote single responsibility.
@MainActor
final class CitySearchViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Stores the search results (weather data).
    @Published var searchResults: [WeatherData] = []

    /// Whether a search is currently in progress.
    @Published var isLoading = false

    /// Holds any error encountered during the search.
    @Published var error: Error?

    // MARK: - Dependencies

    private let weatherService: WeatherService

    // MARK: - Init

    init(weatherService: WeatherService = WeatherManager()) {
        self.weatherService = weatherService
    }

    // MARK: - Search

    /// Searches for weather data by city name.
    func searchCityWeather(cityName: String) {
        let trimmed = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            error = nil
            return
        }

        Task {
            isLoading = true
            error = nil

            do {
                let weatherData = try await weatherService.fetch(byCityName: trimmed)
                searchResults = [weatherData]
                print("🔍 Found weather for: \(weatherData.location.name)")
            } catch {
                self.error = error
                print("❌ Search failed: \(error.localizedDescription)")
            }

            isLoading = false
        }
    }

    // MARK: - Helpers

    func clearSearchResults() {
        searchResults = []
        error = nil
    }

    func clearError() {
        error = nil
    }
}
