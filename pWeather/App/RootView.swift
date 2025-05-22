/*
*  File: RootView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var weatherViewModel: WeatherViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var locationViewModel: LocationViewModel
    @EnvironmentObject private var weatherPagerViewModel: WeatherPagerViewModel

    @Environment(\.colorScheme) private var scheme
    @State private var isReadyToShowContent = false

    var body: some View {
        ZStack {
            scheme.background.ignoresSafeArea()

            if locationManager.userLocation == nil {
                LocationRequestView()
            } else if let error = weatherViewModel.error?.localizedDescription {
                ErrorView(
                    title: "Something went wrong",
                    message: error,
                    retryAction: {
                        if let loc = locationManager.userLocation {
                            weatherViewModel.fetchCurrentLocationWeatherData(
                                latitude: loc.coordinate.latitude,
                                longitude: loc.coordinate.longitude
                            )
                        }
                    },
                    showSettingsButton: error.contains("permission"),
                    openSettingsAction: {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    }
                )
            } else if weatherViewModel.currentLocationWeatherData == nil || !isReadyToShowContent {
                VStack(spacing: 20) {
                    LoadingView()
                    Text("Fetching data for your location…")
                        .font(.appSubheadline)
                        .foregroundColor(scheme.textSecondary)
                }
            } else {
                BottomTabView()
            }
        }
        .onAppear {
            if let loc = locationManager.userLocation {
                print("📍 Initial location onAppear: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                weatherViewModel.fetchCurrentLocationWeatherData(
                    latitude: loc.coordinate.latitude,
                    longitude: loc.coordinate.longitude
                )
            } else {
                print("⚠️ Location not available onAppear")
            }
        }
        .onReceive(locationManager.$userLocation) { newLoc in
            guard let loc = newLoc else {
                print("⚠️ Received nil location")
                return
            }

            print("📍 Received location update: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")

            if let current = weatherViewModel.currentLocationWeatherData,
               abs(current.location.lat - loc.coordinate.latitude) < 0.001,
               abs(current.location.lon - loc.coordinate.longitude) < 0.001 {
                print("🟡 Location unchanged — skipping refetch.")
                return
            }

            isReadyToShowContent = false
            weatherViewModel.fetchCurrentLocationWeatherData(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude
            )
        }
        .onReceive(weatherViewModel.$currentLocationWeatherData) { newData in
            guard let newData = newData else {
                print("⚠️ currentLocationWeatherData is still nil")
                return
            }

            print("✅ Weather data received for: \(newData.location.name)")

            let currentCity = CityInfo(
                name: newData.location.name,
                latitude: newData.location.lat,
                longitude: newData.location.lon,
                isCurrentLocation: true
            )

            // 🧹 Clean saved list of any duplicate city
            appSettings.savedCities.removeAll { saved in
                weatherPagerViewModel.isSameCity(saved, as: currentCity)
            }
            print("🧹 Removed duplicate city: \(currentCity.name) from savedCities")

            // ✅ Set current city
            weatherPagerViewModel.setCurrentLocationCity(currentCity)

            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                isReadyToShowContent = true
            }
        }
    }
}
