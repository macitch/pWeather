/*
*  File: AppDependencies.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import Combine

/// Central dependency container for the pWeather app
@MainActor
final class AppDependencies {
    /// Shared singleton instance
    static let shared = AppDependencies()

    // MARK: - Services
    let weatherManager: WeatherManager
    let locationManager: LocationManager

    // MARK: - Settings
    let appSettings: AppSettings

    // MARK: - ViewModels
    let weatherPagerViewModel: WeatherPagerViewModel
    let weatherViewModel: WeatherViewModel
    let locationViewModel: LocationViewModel

    /// Runs on the main actor so it can call into @MainActor ViewModel inits
    private init() {
        // 1) Core services
        self.weatherManager = WeatherManager()
        self.locationManager = LocationManager.shared

        // 2) Settings
        self.appSettings = AppSettings()

        // 3) ViewModels (all @MainActor)

        // First: pagerViewModel
        self.weatherPagerViewModel = WeatherPagerViewModel(
            weatherService: weatherManager,
            appSettings: appSettings
        )

        // Then: weatherViewModel (which uses pager)
        self.weatherViewModel = WeatherViewModel(
            weatherManager: weatherManager,
            appSettings: appSettings
        )

        // Lastly: locationViewModel
        self.locationViewModel = LocationViewModel(
            weatherService: weatherManager,
            appSettings: appSettings
        )
    }
}
