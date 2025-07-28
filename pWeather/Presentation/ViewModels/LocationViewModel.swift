/*
*  File: LocationViewModel.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// ViewModel responsible for managing saved cities.
@MainActor
final class LocationViewModel: ObservableObject {

    // MARK: - Published Properties

    /// The list of saved cities.
    @Published private(set) var savedCities: [CityInfo]

    // MARK: - Dependencies

    private let appSettings: AppSettings

    // MARK: - Init

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        self.savedCities = appSettings.savedCities
    }

    // MARK: - Save

    /// Adds a new city to saved list if not already included.
    func saveCity(_ city: CityInfo) {
        guard !savedCities.contains(where: { $0.id == city.id }) else {
            print("⚠️ City already saved: \(city.name)")
            return
        }

        appSettings.addCity(city)
        savedCities = appSettings.savedCities
        print("✅ Saved city: \(city.name)")
    }

    /// Adds a city from `WeatherData` (used by CitySearchViewModel consumers).
    func saveCity(from data: WeatherData) {
        let city = CityInfo(
            name: data.location.name,
            latitude: data.location.lat,
            longitude: data.location.lon,
            isCurrentLocation: false
        )
        saveCity(city)
    }

    // MARK: - Delete / Clear

    func deleteCity(_ city: CityInfo) {
        appSettings.deleteCity(city)
        savedCities = appSettings.savedCities
    }

    func clearAllCities() {
        appSettings.clearAllCities()
        savedCities = []
    }

    // MARK: - Reorder

    func reorderCities(from source: IndexSet, to destination: Int) {
        appSettings.reorderCities(from: source, to: destination)
        savedCities = appSettings.savedCities
    }
}
