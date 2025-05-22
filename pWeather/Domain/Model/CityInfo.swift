/*
*  File: CityInfo.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Represents a city with geolocation and identity information, used for storing saved or current locations.
struct CityInfo: Codable, Equatable, Hashable, Identifiable {

    /// The display name of the city.
    let name: String

    /// The latitude coordinate of the city.
    let latitude: Double

    /// The longitude coordinate of the city.
    let longitude: Double

    /// Indicates whether this city represents the user's current location.
    let isCurrentLocation: Bool

    /// A unique identifier for the city, used for hashing, storage, and comparison.
    /// If it's the current location, it prefixes with `"current_"`.
    /// Otherwise, it includes the name and rounded coordinates.
    var id: String {
        if isCurrentLocation {
            return "current_\(name.lowercased())"
        } else {
            // Coordinates rounded for consistency and hash safety
            let roundedLat = String(format: "%.4f", latitude)
            let roundedLon = String(format: "%.4f", longitude)
            return "\(name.lowercased())_\(roundedLat)_\(roundedLon)"
        }
    }

    // MARK: - Initializer

    /// Creates a new `CityInfo` instance.
    ///
    /// - Parameters:
    ///   - name: Name of the city.
    ///   - latitude: Geographic latitude.
    ///   - longitude: Geographic longitude.
    ///   - isCurrentLocation: Flag indicating if this is the user's current location (default: false).
    init(
        name: String,
        latitude: Double,
        longitude: Double,
        isCurrentLocation: Bool = false
    ) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isCurrentLocation = isCurrentLocation
    }

    // MARK: - Factory Method

    /// Creates a `CityInfo` instance from a `WeatherData` object.
    ///
    /// - Parameters:
    ///   - data: The `WeatherData` containing location metadata.
    ///   - isCurrent: Whether this city is the current user location (default: false).
    /// - Returns: A `CityInfo` instance representing the location.
    static func from(_ data: WeatherData, isCurrent: Bool = false) -> CityInfo {
        return CityInfo(
            name: data.location.name,
            latitude: data.location.lat,
            longitude: data.location.lon,
            isCurrentLocation: isCurrent
        )
    }
}
