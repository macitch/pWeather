/*
*  File: WeatherService.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 02.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import CoreLocation

/// An abstraction for retrieving weather data, enabling dependency injection and mocking.
protocol WeatherService: AnyObject {

    /// Fetches weather data for a given coordinate location.
    /// - Parameters:
    ///   - latitude: Latitude of the location.
    ///   - longitude: Longitude of the location.
    /// - Returns: A decoded `WeatherData` object.
    func fetch(
        byCoordinates latitude: CLLocationDegrees,
        longitude: CLLocationDegrees
    ) async throws -> WeatherData

    /// Fetches weather data for a given city.
    /// - Parameter name: City name to search for.
    /// - Returns: A decoded `WeatherData` object.
    func fetch(
        byCityName name: String
    ) async throws -> WeatherData
}
