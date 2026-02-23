/*
*  File: SettingsStores.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2026.
*  License: MIT - Copyright (C) 2026. macitch.
*/

import Foundation

protocol SettingsStore {
    func saveUnit(_ unit: String, forKey key: UnitType)
    func getUnit(forKey key: UnitType) -> String?
    func saveThemeMode(_ mode: ThemeMode)
    func getThemeMode() -> ThemeMode?
}

protocol CityStore {
    func saveCities(_ cities: [CityInfo])
    func loadCities() -> [CityInfo]
    func clearCities()
}
