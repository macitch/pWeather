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

/// Errors that may occur during location updates or authorization.
enum LocationError: Error {
    case authorizationDenied
    case updateFailed(String)
}

/// Concrete location service that publishes user location updates and handles permissions.
final class LocationManager: NSObject, ObservableObject, LocationService {

    // MARK: - Published Properties

    @Published private(set) var userLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var locationError: Error?

    // MARK: - Dependencies

    private let manager: CLLocationManager
    private let config: LocationConfig
    private var debounceCancellable: AnyCancellable?

    // MARK: - Initialization

    init(config: LocationConfig = .default) {
        self.manager = CLLocationManager()
        self.config = config
        self.authorizationStatus = manager.authorizationStatus
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = config.desiredAccuracy
        manager.distanceFilter = config.distanceFilter

        debounceCancellable = $userLocation
            .debounce(for: .seconds(config.debounceInterval), scheduler: RunLoop.main)
            .sink { _ in }

        if authorizationStatus == .notDetermined {
            requestAuthorization()
        } else {
            startUpdatingLocation()
        }
    }

    // MARK: - LocationService Conformance

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .restricted, .denied:
            userLocation = nil
            locationError = LocationError.authorizationDenied
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }

        let distanceMoved = userLocation?.distance(from: latest) ?? .greatestFiniteMagnitude
        guard distanceMoved > config.distanceFilter else { return }

        userLocation = latest
        locationError = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = LocationError.updateFailed(error.localizedDescription)
    }
}
