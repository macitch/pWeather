/*
*  File: UserDefaultsService.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 04.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

// MARK: - Enum Keys for Unit Types

/// Keys used to store user preferences for different unit types in UserDefaults.
enum UnitType: String {
    case temperature = "TemperatureUnit"
    case windSpeed   = "WindSpeedUnit"
    case pressure    = "PressureUnit"
}

// MARK: - UserDefaultsService Singleton

/// A centralized service for managing app preferences and persisted data using `UserDefaults`.
/// Includes storage for user-selected units, theme mode, and saved cities.
@MainActor
final class UserDefaultsService {

    // MARK: - Singleton Instance

    static let shared = UserDefaultsService()

    // MARK: - Properties

    private let defaults: UserDefaults
    private let citiesKey = "SavedCities"

    /// Private initializer for singleton enforcement.
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Unit Preference Persistence

    /// Saves a user-selected unit string for a given unit type.
    /// Falls back to a default unit if the provided value is invalid.
    func saveUnit(_ unit: String, forKey key: UnitType) {
        let isValid: Bool = {
            switch key {
            case .temperature: return TemperatureUnit(rawValue: unit) != nil
            case .windSpeed:   return WindSpeedUnit(rawValue: unit) != nil
            case .pressure:    return PressureUnit(rawValue: unit) != nil
            }
        }()

        let fallback: String = {
            switch key {
            case .temperature: return TemperatureUnit.celsius.rawValue
            case .windSpeed:   return WindSpeedUnit.kilometersPerHour.rawValue
            case .pressure:    return PressureUnit.hectopascals.rawValue
            }
        }()

        defaults.set(isValid ? unit : fallback, forKey: key.rawValue)
    }

    /// Retrieves the saved unit string for the given unit type, or returns a default.
    func getUnit(forKey key: UnitType) -> String? {
        let stored = defaults.string(forKey: key.rawValue) ?? ""

        switch key {
        case .temperature:
            return TemperatureUnit(rawValue: stored)?.rawValue ?? TemperatureUnit.celsius.rawValue
        case .windSpeed:
            return WindSpeedUnit(rawValue: stored)?.rawValue ?? WindSpeedUnit.kilometersPerHour.rawValue
        case .pressure:
            return PressureUnit(rawValue: stored)?.rawValue ?? PressureUnit.hectopascals.rawValue
        }
    }

    // MARK: - Saved Cities Persistence

    /// Saves an array of `CityInfo` objects to UserDefaults.
    func saveCities(_ cities: [CityInfo]) {
        do {
            let encoded = try JSONEncoder().encode(cities)
            defaults.set(encoded, forKey: citiesKey)
        } catch {
            print("⚠️ UserDefaultsService: Failed to encode [CityInfo]: \(error)")
        }
    }

    /// Loads the saved `CityInfo` array from UserDefaults.
    func loadCities() -> [CityInfo] {
        guard let data = defaults.data(forKey: citiesKey) else { return [] }
        do {
            return try JSONDecoder().decode([CityInfo].self, from: data)
        } catch {
            print("⚠️ UserDefaultsService: Failed to decode [CityInfo] from key '\(citiesKey)': \(error)")
            return []
        }
    }

    /// Clears all saved cities from UserDefaults.
    func clearCities() {
        defaults.removeObject(forKey: citiesKey)
    }
}

// MARK: - Theme Mode Persistence

extension UserDefaultsService {

    /// Saves the selected theme mode to UserDefaults.
    func saveThemeMode(_ mode: ThemeMode) {
        defaults.set(mode.rawValue, forKey: "themeMode")
    }

    /// Retrieves the saved theme mode, if available.
    func getThemeMode() -> ThemeMode? {
        guard let raw = defaults.string(forKey: "themeMode") else { return nil }
        return ThemeMode(rawValue: raw)
    }
}
