/*
*  File: WeatherPagerView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 07.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A swipeable (paging) view that displays weather data for a list of cities.
/// Automatically fetches current location weather and supports lazy loading of each city's data.
struct WeatherPagerView: View {

    // MARK: - Environment Objects

    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var citySearchViewModel: CitySearchViewModel
    @EnvironmentObject var weatherPagerViewModel: WeatherPagerViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @EnvironmentObject var appSettings: AppSettings

    // MARK: - State

    /// Tracks the index of the currently selected city page.
    @State private var selectedCityIndex = 0

    /// Controls the visibility of the location selector modal.
    @State private var isShowingLocationSelector = false

    /// Tracks the system's current color scheme for dynamic theming.
    @Environment(\.colorScheme) private var scheme

    // MARK: - View Body

    var body: some View {
        ZStack {
            scheme.background.ignoresSafeArea()

            if !weatherPagerViewModel.cityList.isEmpty {
                // Main pager UI with swipeable tabs per city
                TabView(selection: $weatherPagerViewModel.selectedIndex) {
                    ForEach(Array(weatherPagerViewModel.cityList.enumerated()), id: \.element.id) { index, city in
                        pagerPageView(for: city, at: index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            } else {
                // Empty state when no cities are stored
                EmptyStateView(message: "No cities available.")
            }
        }
        .onAppear {
            // Trigger fetch for current location if available
            if let location = locationManager.userLocation {
                print("📡 Fetching weather for: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                weatherViewModel.fetchCurrentLocationWeatherData(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        }
        .sheet(isPresented: $isShowingLocationSelector) {
            // Location selector modal with embedded navigation stack
            NavigationStack {
                LocationSearchView(
                    searchViewModel: citySearchViewModel,
                    selectedTab: .constant(1)
                )
                .environmentObject(locationViewModel)
                .environmentObject(appSettings)
                .environmentObject(weatherViewModel)
                .environmentObject(weatherPagerViewModel)
                .navigationTitle("Your Locations")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            isShowingLocationSelector = false
                        }
                        .font(.appCallout)
                    }
                }
            }
        }
    }

    // MARK: - Pager Page View

    /// Renders a single page of the pager for the given city.
    @ViewBuilder
    private func pagerPageView(for city: CityInfo, at index: Int) -> some View {
        Group {
            if let data = weatherPagerViewModel.weatherCache[city.id] {
                // Render weather if data is already cached
                WeatherView(
                    externalWeatherData: data,
                    selectedIndex: index
                )
                .onAppear {
                    print("📍 Showing weather for: \(data.location.name)")
                }
            } else {
                // Lazy load weather data when not yet available
                EmptyStateView(message: "Loading weather for \(city.name)…")
                    .onAppear {
                        print("⌛ Waiting for weather data for city: \(city.name)")
                        Task {
                            await weatherPagerViewModel.loadWeather(for: city)
                        }
                    }
            }
        }
        .tag(index) 
    }
}
