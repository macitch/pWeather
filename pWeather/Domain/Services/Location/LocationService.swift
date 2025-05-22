/*
*  File: LocationService.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import Combine
import CoreLocation

/// A protocol that abstracts location-related operations, enabling decoupling from `CLLocationManager`.
/// Conforming types provide real-time location updates, permission handling, and error reporting.
protocol LocationService: ObservableObject {

    /// The most recently reported user location.
    var userLocation: CLLocation? { get }

    /// The current system-level authorization status for location access.
    var authorizationStatus: CLAuthorizationStatus { get }

    /// The last error encountered during location operations, if any.
    var locationError: Error? { get }

    /// Requests permission to access location while the app is in use.
    func requestAuthorization()

    /// Begins location tracking.
    func startUpdatingLocation()

    /// Stops location tracking.
    func stopUpdatingLocation()
}

/// A configuration model for customizing the behavior of a location manager.
struct LocationConfig {

    /// The desired accuracy level for location updates.
    let desiredAccuracy: CLLocationAccuracy

    /// The minimum distance (in meters) the user must move before receiving an update.
    let distanceFilter: CLLocationDistance

    /// The debounce interval (in seconds) to reduce frequent location updates.
    let debounceInterval: TimeInterval

    /// Default configuration:
    /// - Accuracy: Best
    /// - Distance Filter: 100 meters
    /// - Debounce Interval: 2 seconds
    static let `default` = LocationConfig(
        desiredAccuracy: kCLLocationAccuracyBest,
        distanceFilter: 100,
        debounceInterval: 2
    )
}
