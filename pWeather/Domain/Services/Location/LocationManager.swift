/*
*  File: LocationManager.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import Combine
import CoreLocation

/// Enum representing common errors that may occur during location updates or authorization.
enum LocationError: Error {
    /// Location services were denied by the user or system.
    case authorizationDenied
    /// An update failed with an underlying error message.
    case updateFailed(String)
}

/// A concrete implementation of `LocationService` using `CLLocationManager`.
/// Provides reactive location updates and permission handling via `@Published` properties.
class LocationManager: NSObject, ObservableObject, LocationService, CLLocationManagerDelegate {

    // MARK: - Singleton Instance

    static let shared = LocationManager()

    // MARK: - Published State

    /// The user’s most recently reported location.
    @Published var userLocation: CLLocation?

    /// The current system-level location authorization status.
    @Published var authorizationStatus: CLAuthorizationStatus

    /// Any error encountered during location operations.
    @Published var locationError: Error?

    // MARK: - Internal Properties

    private let manager: CLLocationManager
    private let config: LocationConfig
    private var debounceCancellable: AnyCancellable?

    // MARK: - Initialization

    /// Initializes the shared `CLLocationManager`, applies configuration, and sets up observers.
    private init(config: LocationConfig = .default) {
        self.manager = CLLocationManager()
        self.config = config
        self.authorizationStatus = manager.authorizationStatus
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = config.desiredAccuracy
        manager.distanceFilter = config.distanceFilter

        // Debounce frequent updates to reduce noise.
        debounceCancellable = $userLocation
            .debounce(for: .seconds(config.debounceInterval), scheduler: RunLoop.main)
            .sink { _ in /* Intentionally empty – observers use @Published */ }

        // Request permission if needed; otherwise start updates.
        if authorizationStatus == .notDetermined {
            requestAuthorization()
        } else {
            startUpdatingLocation()
        }
    }

    // MARK: - LocationService Protocol

    /// Requests permission to access the user’s location when the app is in use.
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    /// Starts actively tracking the user’s location, if authorized.
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        manager.startUpdatingLocation()
    }

    /// Stops location tracking.
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    /// Handles changes in system location authorization status.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.startUpdatingLocation()
            case .restricted, .denied:
                self.userLocation = nil
                self.locationError = LocationError.authorizationDenied
            default:
                break
            }
        }
    }

    /// Publishes location updates if the user has moved beyond the configured distance filter.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }

        let distance = userLocation?.distance(from: latest) ?? .greatestFiniteMagnitude
        guard distance > config.distanceFilter else { return }

        DispatchQueue.main.async {
            self.userLocation = latest
            self.locationError = nil
        }
    }

    /// Captures and publishes any errors encountered during location updates.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = LocationError.updateFailed(error.localizedDescription)
        }
    }
}
