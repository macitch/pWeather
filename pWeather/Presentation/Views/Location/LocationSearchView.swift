/*
*  File: LocationSearchView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A view that allows the user to search for a city's weather or select from saved cities.
/// Supports city search, live weather previews, and adding cities to favorites.
struct LocationSearchView: View {

    // MARK: - View Models & State

    @ObservedObject var viewModel: LocationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @EnvironmentObject var weatherPagerViewModel: WeatherPagerViewModel

    /// Binding to the parent-selected tab index, allowing tab changes from this view.
    @Binding var selectedTab: Int

    /// User-entered city name in the search field.
    @State private var cityName: String = ""

    /// Selected search result to preview in a modal sheet.
    @State private var selectedSearchResult: WeatherData?

    /// Tracks focus state of the search field.
    @FocusState private var isSearchFieldFocused: Bool

    /// Tracks current system color scheme.
    @Environment(\.colorScheme) private var scheme

    // MARK: - View Body

    var body: some View {
        NavigationStack {
            ZStack {
                scheme.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    searchBar

                    // Error message display
                    if let error = viewModel.error {
                        Text("Error: \(error.localizedDescription)")
                            .font(.appCallout)
                            .foregroundColor(scheme.brandRed)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Loading indicator
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }

                    // Main content list (search results or saved cities)
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if !viewModel.searchResults.isEmpty {
                                searchResultsList()
                            } else if !appSettings.savedCities.isEmpty {
                                savedCitiesList()
                            } else {
                                Text("No cities stored.")
                                    .font(.appCallout)
                                    .foregroundColor(.gray)
                                    .padding(.top, 20)
                            }
                        }
                        .padding(.vertical)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 32)
            }
            .navigationTitle("Your Locations")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isSearchFieldFocused = true
            }
            .sheet(item: $selectedSearchResult) { data in
                // Weather preview modal with option to save
                NavigationStack {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Button("Save") {
                                let city = CityInfo(
                                    name: data.location.name,
                                    latitude: data.location.lat,
                                    longitude: data.location.lon
                                )

                                // Prevent saving current location or duplicates
                                if let current = weatherPagerViewModel.currentLocationCity,
                                   weatherPagerViewModel.isSameCity(current, as: city) {
                                    print("⚠️ City is current location, skipping save.")
                                } else if !appSettings.savedCities.contains(where: { $0.id == city.id }) {
                                    appSettings.addCity(city)
                                }

                                // Clear state and refocus search
                                cityName = ""
                                viewModel.clearSearchResults()
                                viewModel.clearError()
                                selectedSearchResult = nil
                                isSearchFieldFocused = true
                            }
                            .font(.appCallout)
                            .padding()
                        }

                        Divider()

                        // Weather view preview for selected city
                        WeatherView(
                            externalWeatherData: data,
                            selectedIndex: -1
                        )
                        .environmentObject(appSettings)
                        .environmentObject(weatherViewModel)
                    }
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            TextField("Enter city name...", text: $cityName)
                .font(.appBody)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(scheme.surface)
                .foregroundColor(scheme.textPrimary)
                .cornerRadius(12)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .onSubmit { performSearch() }
                .onChange(of: cityName) { newValue in
                    viewModel.clearError()
                    if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.clearSearchResults()
                    }
                }

            Button(action: performSearch) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(scheme.textPrimary)
                    .padding(10)
                    .background(scheme.surface)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Search Results List

    @ViewBuilder
    private func searchResultsList() -> some View {
        ForEach(viewModel.searchResults, id: \.location.name) { data in
            let cardVM = CityCardViewModel(weatherData: data, appSettings: appSettings)

            CityCardView(viewModel: cardVM, showStar: false, onFavoriteTapped: {})
                .onTapGesture {
                    selectedSearchResult = data
                }
                .padding(.horizontal)
        }
    }

    // MARK: - Saved Cities List

    @ViewBuilder
    private func savedCitiesList() -> some View {
        ForEach(appSettings.savedCities) { city in
            // Creates placeholder WeatherData from saved city info (used for local display only)
            let data = WeatherData(
                location: Location(
                    name: city.name,
                    region: previewWeatherData.location.region,
                    country: previewWeatherData.location.country,
                    lat: city.latitude,
                    lon: city.longitude,
                    tz_id: previewWeatherData.location.tz_id,
                    localtime_epoch: previewWeatherData.location.localtime_epoch,
                    localtime: previewWeatherData.location.localtime
                ),
                current: previewWeatherData.current,
                forecast: previewWeatherData.forecast,
                alerts: previewWeatherData.alerts
            )

            let cardVM = CityCardViewModel(weatherData: data, appSettings: appSettings)

            CityCardView(viewModel: cardVM, showStar: false, onFavoriteTapped: {})
                .onTapGesture {
                    selectedSearchResult = data
                }
                .padding(.horizontal)
        }
    }

    // MARK: - Search Logic

    /// Triggers a weather search using the trimmed city name.
    private func performSearch() {
        let trimmed = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.searchCityWeather(cityName: trimmed)
    }
}
