/*
*  File: WeatherCardView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A card-style view that displays detailed weather metrics such as UV index, wind, pressure,
/// sunrise/sunset times, and feels-like temperature. Includes a large weather condition image.
struct WeatherCardView: View {

    // MARK: - Environment

    /// Provides access to the system's color scheme (light/dark) for adaptive theming.
    @Environment(\.colorScheme) private var scheme

    /// Accesses app-wide user settings for units (temperature, wind, pressure).
    @EnvironmentObject private var appSettings: AppSettings

    // MARK: - Input

    /// Weather data for the current city/location.
    let viewModel: WeatherData

    // MARK: - Computed Display Strings

    /// Returns formatted wind speed string based on user-selected unit.
    private var windSpeedUnit: String {
        WeatherUtils.formattedWindSpeed(
            speedKph: viewModel.current.wind_kph,
            speedMph: viewModel.current.wind_mph,
            unit: appSettings.windSpeedUnit
        )
    }

    /// Returns formatted pressure string based on user-selected unit.
    private var pressureUnit: String {
        WeatherUtils.formattedPressure(
            pressureMb: viewModel.current.pressure_mb,
            pressureIn: viewModel.current.pressure_in,
            unit: appSettings.pressureUnit
        )
    }

    /// Returns formatted "feels like" temperature based on user-selected unit.
    private var feelsLike: String {
        WeatherUtils.formattedTemperature(
            tempC: viewModel.current.feelslike_c,
            tempF: viewModel.current.feelslike_f,
            unit: appSettings.temperatureUnit
        )
    }

    /// Extracts astronomical data (sunrise/sunset) for the current day.
    private var astro: Astro? {
        viewModel.forecast.forecastday.first?.astro
    }

    /// Extracts daily data (UV index, humidity) for the current day.
    private var day: Day? {
        viewModel.forecast.forecastday.first?.day
    }

    // MARK: - View Body

    var body: some View {
        HStack {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                // Section title
                Text("Details")
                    .font(.appHeadline)
                    .foregroundColor(scheme.textPrimary)

                HStack(spacing: 24) {
                    // Weather condition icon
                    Image(WeatherUtils.getImageName(forConditionCode: "\(viewModel.current.condition.code)", isDay: viewModel.current.is_day))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .padding(.trailing, 4)
                        .foregroundColor(scheme.brandRed)

                    // Weather info rows
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRowView(label: "Sunrise:", value: astro?.sunrise.formattedToLocalTime() ?? "—")
                        InfoRowView(label: "Sunset:", value: astro?.sunset.formattedToLocalTime() ?? "—")
                        InfoRowView(label: "UV Index:", value: String(format: "%.1f", day?.uv ?? 0))
                        InfoRowView(label: "Pressure:", value: pressureUnit)
                        InfoRowView(label: "Wind:", value: windSpeedUnit)
                        InfoRowView(label: "Humidity:", value: "\(Int(day?.avghumidity ?? 0))%")
                        InfoRowView(label: "Feels Like:", value: feelsLike)
                    }
                }
            }
            .padding()

            Spacer()
        }
        .background(scheme.surface)
        .cornerRadius(16)
        .padding(.vertical, 16)
    }
}

// MARK: - Previews

#Preview("WeatherCardView – Light") {
    WeatherCardView(viewModel: previewWeatherData)
        .environmentObject(AppSettings())
        .preferredColorScheme(.light)
        .padding()
}

#Preview("WeatherCardView – Dark") {
    WeatherCardView(viewModel: previewWeatherData)
        .environmentObject(AppSettings())
        .preferredColorScheme(.dark)
        .padding()
}
