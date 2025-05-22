/*
*  File: LocationRequestView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A view prompting the user to grant location permissions, with multiple options for action.
/// This is typically shown when location access is denied or not yet requested.
struct LocationRequestView: View {

    // MARK: - Environment

    /// Manages location services and authorization requests.
    @EnvironmentObject var locationManager: LocationManager

    /// Tracks the current system color scheme for adaptive theming.
    @Environment(\.colorScheme) private var scheme

    // MARK: - View Body

    var body: some View {
        VStack(spacing: 24) {
            // Icon representing location access denial
            Image(systemName: "location.slash")
                .font(.system(size: 64))
                .foregroundColor(.gray)
                .accessibilityHidden(true)

            // Headline title
            Text("Location Access Needed")
                .font(.appTitle2)
                .foregroundColor(scheme.textPrimary)
                .multilineTextAlignment(.center)

            // Explanation text
            Text("Please allow location permissions so we can show you weather data for your area.")
                .font(.appBody)
                .foregroundColor(scheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Action buttons
            HStack(spacing: 16) {
                // Request permission via CLLocationManager
                Button("Grant Access") {
                    locationManager.requestAuthorization()
                }
                .font(.appCallout)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(scheme.brandBlue)
                .foregroundColor(.white)
                .cornerRadius(8)

                // Attempt to manually start location updates
                Button("Start Updates") {
                    locationManager.startUpdatingLocation()
                }
                .font(.appCallout)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(scheme.surface)
                .foregroundColor(scheme.textPrimary)
                .cornerRadius(8)

                // Open iOS Settings app for manual permission management
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.appCallout)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(scheme.surface)
                .foregroundColor(scheme.textPrimary)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(scheme.surface)
        .cornerRadius(16)
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Location permission required.")
    }
}
