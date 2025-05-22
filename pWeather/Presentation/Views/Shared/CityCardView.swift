/*
*  File: CityCardView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A card-style view that displays summary weather information for a specific city.
/// Optionally includes a star icon for managing favorites.
struct CityCardView: View {
    
    // MARK: - Input Properties

    /// The view model providing city-specific weather data.
    @ObservedObject var viewModel: CityCardViewModel

    /// Flag indicating whether the favorite star should be shown.
    let showStar: Bool

    /// Callback triggered when the favorite icon is tapped.
    let onFavoriteTapped: () -> Void

    // MARK: - Environment

    /// App-wide settings including saved cities and user preferences.
    @EnvironmentObject private var appSettings: AppSettings

    /// The system color scheme (light or dark), used to apply dynamic theming.
    @Environment(\.colorScheme) private var scheme

    // MARK: - Computed Properties

    /// Determines whether the current city is saved as a favorite.
    private var isFavorited: Bool {
        appSettings.savedCities.contains { $0.name == viewModel.cityName }
    }

    // MARK: - View Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // City name
                Text(viewModel.cityName)
                    .font(.appHeadline)
                    .foregroundColor(scheme.textPrimary)

                Spacer()

                // Optional favorite star icon
                if showStar {
                    Button(action: onFavoriteTapped) {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                            .foregroundColor(scheme.accent)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Local time
            Text(viewModel.formattedTime)
                .font(.appSubheadline)
                .foregroundColor(scheme.textSecondary)

            // Weather condition (e.g., "Cloudy", "Sunny")
            Text(viewModel.weatherCondition)
                .font(.appBody)
                .foregroundColor(scheme.textPrimary)

            // Temperature reading
            Text(viewModel.formattedTemp)
                .font(.appTitle2)
                .foregroundColor(scheme.brandRed)
        }
        .padding()
        .background(scheme.surface)
        .cornerRadius(12)
    }
}

#Preview("CityCard – Light") {
    CityCardView(
        viewModel: CityCardViewModel(weatherData: previewWeatherData, appSettings: AppSettings()),
        showStar: true,
        onFavoriteTapped: {}
    )
    .environmentObject(AppSettings())
    .preferredColorScheme(.light)
    .padding()
}

#Preview("CityCard – Dark") {
    CityCardView(
        viewModel: CityCardViewModel(weatherData: previewWeatherData, appSettings: AppSettings()),
        showStar: true,
        onFavoriteTapped: {}
    )
    .environmentObject(AppSettings())
    .preferredColorScheme(.dark)
    .padding()
}
