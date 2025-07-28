/*
*  File: AppDependencies.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import Combine

/// Central dependency container for the pWeather app.
/// Responsible for initializing and injecting all services, settings, and view models.
@MainActor
final class AppDependencies {

    // MARK: - Singleton Instance

    /// Shared global instance of the dependency container.
    static let shared = AppDependencies()

    // MARK: - Services

    /// Abstract weather service used across the app.
    let weatherService: WeatherService

    /// Location manager providing real-time location updates.
    let locationManager: LocationManager

    // MARK: - Settings

    /// Shared app settings, including unit preferences and theme.
    let appSettings: AppSettings

    // MARK: - ViewModels

    /// Manages swipeable city-based weather views.
    let weatherPagerViewModel: WeatherPagerViewModel

    /// Manages current and searched weather data.
    let weatherViewModel: WeatherViewModel

    /// Manages saved locations and persistence.
    let locationViewModel: LocationViewModel
    
    /// Handles city search results and errors (refactored)
    let citySearchViewModel: CitySearchViewModel

    // MARK: - Initialization

    /// Private initializer to enforce singleton usage.
    private init() {
        // 1. Core Services
        let weatherManager = WeatherManager() // Concrete implementation
        self.weatherService = weatherManager
        self.locationManager = LocationManager() // ✅ MainActor-safe

        // 2. App Settings
        self.appSettings = AppSettings()

        // 3. ViewModels (all @MainActor)
        self.weatherPagerViewModel = WeatherPagerViewModel(
            weatherService: weatherService,
            appSettings: appSettings
        )

        self.weatherViewModel = WeatherViewModel(
            weatherService: weatherService,
            appSettings: appSettings
        )

        self.locationViewModel = LocationViewModel(
            appSettings: appSettings
        )
        
        self.citySearchViewModel = CitySearchViewModel(weatherService: weatherService)
    }
}
