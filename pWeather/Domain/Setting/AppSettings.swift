/*
*  File: AppSettings.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 04.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Manages user preferences and saved cities, persisting all changes through `UserDefaultsService`.
/// Acts as a central app-wide state container, published via `ObservableObject`.
@MainActor
final class AppSettings: ObservableObject {

    // MARK: - Dependencies

    /// Shared service responsible for reading/writing to UserDefaults.
    private let userDefaultsService = UserDefaultsService.shared

    // MARK: - Published User Preferences

    /// Selected unit for temperature display (e.g., "C", "F").
    @Published var temperatureUnit: String {
        didSet { userDefaultsService.saveUnit(temperatureUnit, forKey: .temperature) }
    }

    /// Selected unit for wind speed (e.g., "km/h", "mph").
    @Published var windSpeedUnit: String {
        didSet { userDefaultsService.saveUnit(windSpeedUnit, forKey: .windSpeed) }
    }

    /// Selected unit for pressure (e.g., "hPa", "mmHg").
    @Published var pressureUnit: String {
        didSet { userDefaultsService.saveUnit(pressureUnit, forKey: .pressure) }
    }

    /// Selected theme mode (system, light, or dark).
    @Published var themeMode: ThemeMode {
        didSet { userDefaultsService.saveThemeMode(themeMode) }
    }

    // MARK: - Saved Cities

    /// The list of user-saved cities, including optional favorites.
    @Published var savedCities: [CityInfo] {
        didSet { userDefaultsService.saveCities(savedCities) }
    }

    // MARK: - Initialization

    /// Loads persisted user preferences and saved cities on app launch.
    init() {
        self.temperatureUnit = userDefaultsService.getUnit(forKey: .temperature) ?? TemperatureUnit.celsius.rawValue
        self.windSpeedUnit   = userDefaultsService.getUnit(forKey: .windSpeed) ?? WindSpeedUnit.kilometersPerHour.rawValue
        self.pressureUnit    = userDefaultsService.getUnit(forKey: .pressure) ?? PressureUnit.hectopascals.rawValue
        self.savedCities     = userDefaultsService.loadCities()
        self.themeMode       = userDefaultsService.getThemeMode() ?? .system
    }

    // MARK: - Unit Preference Helpers

    /// Programmatically updates the temperature unit.
    func toggleTemperatureUnit(to unit: String) {
        temperatureUnit = unit
    }

    /// Programmatically updates the wind speed unit.
    func toggleWindSpeedUnit(to unit: String) {
        windSpeedUnit = unit
    }

    /// Programmatically updates the pressure unit.
    func togglePressureUnit(to unit: String) {
        pressureUnit = unit
    }

    /// Sets the theme mode explicitly.
    func setThemeMode(to mode: ThemeMode) {
        themeMode = mode
    }

    // MARK: - City Management

    /// Adds a new city to the list, avoiding duplicates.
    func addCity(_ city: CityInfo) {
        guard !savedCities.contains(city) else { return }
        savedCities.append(city)
    }

    /// Removes a city from the saved list.
    func deleteCity(_ city: CityInfo) {
        savedCities.removeAll { $0 == city }
    }

    /// Reorders saved cities (used with drag-and-drop).
    func reorderCities(from source: IndexSet, to destination: Int) {
        savedCities.move(fromOffsets: source, toOffset: destination)
    }

    /// Clears all saved cities from memory and persistence.
    func clearAllCities() {
        savedCities.removeAll()
    }
}
