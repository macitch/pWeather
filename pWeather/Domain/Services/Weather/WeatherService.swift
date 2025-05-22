/*
*  File: WeatherService.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 02.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import CoreLocation

/// A protocol defining an abstraction for fetching weather data.
/// Enables dependency injection and easy mocking for unit tests or preview environments.
protocol WeatherService {

    /// Fetches weather data using geographic coordinates.
    ///
    /// - Parameters:
    ///   - latitude:  The latitude of the location.
    ///   - longitude: The longitude of the location.
    /// - Returns: A decoded `WeatherData` model containing current and forecast information.
    /// - Throws: An error if the request fails or decoding is unsuccessful.
    func fetch(
        byCoordinates latitude: CLLocationDegrees,
        longitude: CLLocationDegrees
    ) async throws -> WeatherData

    /// Fetches weather data using a city name.
    ///
    /// - Parameter name: The name of the city to look up.
    /// - Returns: A decoded `WeatherData` model containing current and forecast information.
    /// - Throws: An error if the request fails or decoding is unsuccessful.
    func fetch(
        byCityName name: String
    ) async throws -> WeatherData
}
