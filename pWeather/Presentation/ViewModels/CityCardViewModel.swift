/*
*  File: CityCardViewModel.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 08.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import Combine

/// ViewModel responsible for preparing and updating display values for a city weather card.
/// Automatically reacts to unit changes and formats temperature and local time accordingly.
@MainActor
final class CityCardViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Formatted temperature string (e.g., "22°C" or "71°F") based on current unit settings.
    @Published private(set) var formattedTemp: String

    /// Formatted local time string for the city's timezone.
    @Published private(set) var formattedTime: String

    // MARK: - Dependencies

    /// Raw weather data for the city.
    private let weatherData: WeatherData

    /// Shared app settings for units and preferences.
    private let appSettings: AppSettings

    /// Tracks Combine subscriptions for unit changes.
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Initializes the view model with weather data and shared settings.
    init(weatherData: WeatherData, appSettings: AppSettings) {
        self.weatherData = weatherData
        self.appSettings = appSettings

        self.formattedTemp = WeatherUtils.formattedTemperature(from: weatherData, unit: appSettings.temperatureUnit)
        self.formattedTime = WeatherUtils.formatLocalTime(from: weatherData.location.localtime)

        observeTemperatureUnitChanges()
    }

    // MARK: - Reactive Updates

    /// Observes changes to the temperature unit and updates the formatted temperature accordingly.
    private func observeTemperatureUnitChanges() {
        appSettings.$temperatureUnit
            .sink { [weak self] unit in
                guard let self = self else { return }
                self.formattedTemp = WeatherUtils.formattedTemperature(from: self.weatherData, unit: unit)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Read-Only Properties

    /// The name of the city.
    var cityName: String {
        weatherData.location.name
    }

    /// The textual description of the current weather condition (e.g., "Sunny", "Rain").
    var weatherCondition: String {
        weatherData.current.condition.text
    }
}
