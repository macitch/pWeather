/*
*  File: WeatherManager.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 02.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import CoreLocation

/// Concrete implementation of `WeatherService`, responsible for building requests and
/// retrieving weather data from the remote Weather API.
final class WeatherManager {

    // MARK: - API Configuration

    private let baseURL = APIConfig.baseURL
    private let apiKey  = APIConfig.apiKey

    // MARK: - URL Construction

    /// Builds a complete URL for a weather API request using a city name or coordinate query.
    ///
    /// - Parameter query: A string representing the city name or "lat,lon".
    /// - Returns: A fully formed `URL` with required query parameters.
    /// - Throws: `URLError.badURL` if URL construction fails.
    private func buildURL(forQuery query: String) throws -> URL {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "days", value: "7"),
            URLQueryItem(name: "aqi", value: "yes"),
            URLQueryItem(name: "alerts", value: "yes")
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        return url
    }

    // MARK: - Fetch Methods

    /// Fetches weather data using geographic coordinates.
    func fetchWeatherByCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> WeatherData {
        let query = "\(latitude),\(longitude)"
        let url = try buildURL(forQuery: query)
        return try await APIService.shared.fetch(url, responseType: WeatherData.self)
    }

    /// Fetches weather data using a city name.
    func fetchWeatherByCityName(city: String) async throws -> WeatherData {
        let url = try buildURL(forQuery: city)
        return try await APIService.shared.fetch(url, responseType: WeatherData.self)
    }
}

// MARK: - WeatherService Conformance

extension WeatherManager: WeatherService {

    /// Protocol requirement: fetch weather using coordinates.
    func fetch(byCoordinates latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> WeatherData {
        try await fetchWeatherByCoordinates(latitude: latitude, longitude: longitude)
    }

    /// Protocol requirement: fetch weather using a city name.
    func fetch(byCityName name: String) async throws -> WeatherData {
        try await fetchWeatherByCityName(city: name)
    }
}
