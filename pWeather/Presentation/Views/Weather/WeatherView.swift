/*
*  File: WeatherView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Displays detailed weather information for a specific city, including current, daily, and hourly forecasts.
/// Can accept external weather data and integrates with the shared view model for refreshing.
struct WeatherView: View {

    // MARK: - Environment

    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var weatherViewModel: WeatherViewModel

    // MARK: - Input

    /// Optional external weather data to be injected when this view appears.
    var externalWeatherData: WeatherData?

    /// Index of the current page/tab from the parent view.
    var selectedIndex: Int

    // MARK: - State

    /// Local state copy of the weather data used for rendering and refresh.
    @State private var weatherData: WeatherData?

    // MARK: - View Body

    var body: some View {
        ZStack {
            scheme.background.ignoresSafeArea()

            if let data = weatherData {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {

                        // MARK: Location & Date
                        VStack(alignment: .leading, spacing: 4) {
                            Text(data.location.name)
                                .font(.appCallout)
                                .foregroundColor(scheme.textPrimary)

                            Text(WeatherUtils.formatToDayAndDate(data.current.last_updated) ?? "--")
                                .font(.appFootnote)
                                .foregroundColor(scheme.textSecondary)
                        }

                        Spacer(minLength: 330) // Ensures temperature appears lower on the screen

                        // MARK: Temperature & High/Low
                        HStack {
                            Text(formattedTemperature(data))
                                .font(.appHugeTemp)
                                .foregroundColor(scheme.brandRed)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("H: \(WeatherUtils.highTemperature(from: data, unit: appSettings.temperatureUnit))")
                                Text("L: \(WeatherUtils.lowTemperature(from: data, unit: appSettings.temperatureUnit))")
                            }
                            .font(.appCallout)
                            .foregroundColor(scheme.textSecondary)
                        }

                        Divider()
                            .frame(height: 4)
                            .background(scheme.background)
                            .cornerRadius(8)

                        // MARK: Current Condition
                        Text(data.current.condition.text)
                            .font(.appTitle2)
                            .foregroundColor(scheme.textPrimary)

                        // MARK: Hourly Forecast
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(relevantHourlyData(data), id: \.time_epoch) { hour in
                                    HourlyWeatherView(
                                        icon: WeatherUtils.getImageName(forConditionCode: String(hour.condition.code), isDay: hour.is_day),
                                        time: hour.time.extractTime() ?? "--:--",
                                        tempC: hour.temp_c,
                                        tempF: hour.temp_f
                                    )
                                }
                            }
                            .padding(.trailing, 8)
                        }

                        // MARK: Additional Weather Metrics
                        WeatherCardView(viewModel: data)
                    }
                    .padding()
                }
                .refreshable {
                    await refreshWeather(for: data)
                }
            } else {
                EmptyStateView(message: "No weather data available.")
            }
        }
        .onAppear {
            print("📱 WeatherView appeared on tab \(selectedIndex): \(externalWeatherData?.location.name ?? "nil")")
            injectWeatherDataIfNeeded()
        }
    }

    // MARK: - Helpers

    /// Formats the current temperature string according to app settings.
    private func formattedTemperature(_ data: WeatherData) -> String {
        let temp = Temperature(metricValue: data.current.temp_c, imperialValue: data.current.temp_f)
        return temp.formatted(for: appSettings.temperatureUnit, defaultUnit: .celsius, decimals: 0)
    }

    /// Returns an array of hourly forecasts within the next 24 hours.
    private func relevantHourlyData(_ data: WeatherData) -> [Hour] {
        let now = Int(Date().timeIntervalSince1970)
        let next24h = now + (24 * 60 * 60)
        return data.forecast.forecastday
            .flatMap { $0.hour }
            .filter { $0.time_epoch >= now && $0.time_epoch <= next24h }
    }

    /// Refreshes weather data for the given city.
    private func refreshWeather(for city: WeatherData) async {
        do {
            let data = try await weatherViewModel.weatherManager.fetch(byCityName: city.location.name)
            print("🔁 Refreshed weather for \(data.location.name)")
            weatherData = data
        } catch {
            print("❌ Refresh failed for \(city.location.name): \(error.localizedDescription)")
        }
    }

    /// Injects external weather data into local state if needed (e.g. on first load).
    private func injectWeatherDataIfNeeded() {
        guard let ext = externalWeatherData else { return }
        if weatherData == nil || ext.location.name != weatherData?.location.name {
            print("⏬ Injecting external weather data into local state")
            weatherData = ext
        }
    }
}

// MARK: - Previews

#Preview("WeatherView – Light") {
    let settings = AppSettings()
    let weatherVM = WeatherViewModel(weatherManager: WeatherManager(), appSettings: settings)

    return WeatherView(
        externalWeatherData: previewWeatherData,
        selectedIndex: 0
    )
    .environmentObject(settings)
    .environmentObject(weatherVM)
    .preferredColorScheme(.light)
}

#Preview("WeatherView – Dark") {
    let settings = AppSettings()
    let weatherVM = WeatherViewModel(weatherManager: WeatherManager(), appSettings: settings)

    return WeatherView(
        externalWeatherData: previewWeatherData,
        selectedIndex: 0
    )
    .environmentObject(settings)
    .environmentObject(weatherVM)
    .preferredColorScheme(.dark)
}
