/*
*  File: WeatherMapView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 07.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import MapKit

/// A map view that displays weather-related city markers on a global map.
/// Initializes with a default region and focuses on the first city if available.
struct WeatherMapView: View {

    // MARK: - Input

    /// A list of cities with geographic coordinates to be displayed on the map.
    let cities: [CityInfo]

    // MARK: - State

    /// The currently visible region of the map.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.2, longitude: 6.1), // Default: Central Europe
        span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)   // Wide zoom to show multiple cities
    )

    // MARK: - View Body

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: cities) { city in
            // Adds a red marker for each city on the map.
            MapMarker(
                coordinate: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude),
                tint: .red
            )
        }
        .ignoresSafeArea() // Allows map to extend behind safe areas (e.g., navigation bar)
        .onAppear {
            // On first appearance, center the map on the first city if available.
            if let first = cities.first {
                region.center = CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude)
            }
        }
    }
}
