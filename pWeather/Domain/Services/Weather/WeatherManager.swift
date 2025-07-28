/*
*  File: WeatherManager.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 02.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import CoreLocation

/// Responsible for building requests and retrieving weather data from the remote Weather API.
final class WeatherManager: WeatherService {

    // MARK: - API Configuration

    private let baseURL: String = APIConfig.baseURL
    private let apiKey: String  = APIConfig.apiKey

    // MARK: - Public Fetch Methods

    func fetch(byCoordinates latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> WeatherData {
        let query = "\(latitude),\(longitude)"
        return try await fetchWeather(for: query)
    }

    func fetch(byCityName name: String) async throws -> WeatherData {
        try await fetchWeather(for: name)
    }

    // MARK: - Internal Fetch Logic

    private func fetchWeather(for query: String) async throws -> WeatherData {
        let url = try buildWeatherURL(query: query)
        return try await APIService.shared.fetch(url, responseType: WeatherData.self)
    }

    // MARK: - URL Builder

    private func buildWeatherURL(query: String) throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            .init(name: "key", value: apiKey),
            .init(name: "q", value: query),
            .init(name: "days", value: "7"),
            .init(name: "aqi", value: "yes"),
            .init(name: "alerts", value: "yes")
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        return url
    }
}
