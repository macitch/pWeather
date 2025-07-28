/*
*  File: BottomTabView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A container view that manages the bottom tab navigation for the weather app.
/// It handles three main sections: Location Search, Weather Pager, and Settings.
struct BottomTabView: View {
    
    // MARK: - Environment Objects

    /// Provides access to user settings, including theme and units.
    @EnvironmentObject var appSettings: AppSettings

    /// Handles logic and state for location searching and management.
    @EnvironmentObject var locationViewModel: LocationViewModel

    /// Provides weather data for the currently selected city.
    @EnvironmentObject var weatherViewModel: WeatherViewModel

    /// Manages swiping between weather pages and active index tracking.
    @EnvironmentObject var weatherPagerViewModel: WeatherPagerViewModel

    /// Manages device location updates and permissions.
    @EnvironmentObject var locationManager: LocationManager
    
    /// Manages search-specific logic for city weather.
    @EnvironmentObject var citySearchViewModel: CitySearchViewModel

    // MARK: - State and Environment

    /// Tracks the currently selected tab index (0: Locations, 1: Weather, 2: Settings).
    @State private var selectedTabIndex: Int = 1

    /// Reads the current color scheme (light/dark) to apply themed styles.
    @Environment(\.colorScheme) private var scheme

    // MARK: - View Body

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTabIndex {
                case 0:
                    // Location tab with search functionality.
                    LocationSearchView(
                        searchViewModel: citySearchViewModel,
                        selectedTab: $selectedTabIndex
                    )
                case 1:
                    // Main weather view with paging/swiping between cities.
                    WeatherPagerView()
                case 2:
                    // Settings screen with unit preferences and app themes.
                    SettingsView()
                default:
                    // Fallback view in case of an invalid index.
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // MARK: - Bottom Tab Bar

            HStack {
                tabButton(index: 0, systemImage: "list.bullet", label: "Locations")
                Spacer()
                weatherTabButton(index: 1)
                Spacer()
                tabButton(index: 2, systemImage: "gear", label: "Settings")
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(
                scheme.surface
                    .ignoresSafeArea(edges: .bottom)
            )
            // If a new weather page is selected, auto-switch to Weather tab.
            .onChange(of: weatherPagerViewModel.selectedIndex) { newIndex in
                if selectedTabIndex != 1 {
                    selectedTabIndex = 1
                }
            }
        }
        .accentColor(scheme.brandRed) // Highlights active tab icons
    }

    // MARK: - Tab Button Builder

    /// Creates a standard icon+label button for the tab bar.
    @ViewBuilder
    private func tabButton(index: Int, systemImage: String, label: String) -> some View {
        Button(action: {
            selectedTabIndex = index
        }) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .medium))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(selectedTabIndex == index ? scheme.brandRed : .gray)
        }
    }

    /// Creates the special weather tab button using a custom page indicator.
    @ViewBuilder
    private func weatherTabButton(index: Int) -> some View {
        Button(action: {
            selectedTabIndex = index
        }) {
            VStack(spacing: 4) {
                PageIndicator(
                    numberOfPages: max(weatherPagerViewModel.cityList.count, 1),
                    currentIndex: weatherPagerViewModel.selectedIndex,
                    forceInvertScheme: true
                )
                .frame(height: 10)
            }
            .foregroundColor(selectedTabIndex == index ? scheme.brandRed : .gray)
        }
    }
}
