/*
*  File: WeatherView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Displays detailed weather information for a specific city, including current, daily, and hourly forecasts.
/// Accepts external data and integrates with the shared view model for refreshing.
struct WeatherView: View {

    // MARK: - Environment

    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var weatherViewModel: WeatherViewModel

    // MARK: - Input

    var externalWeatherData: WeatherData?
    var selectedIndex: Int

    // MARK: - State

    @State private var weatherData: WeatherData?

    // MARK: - Body

    var body: some View {
        ZStack {
            scheme.background.ignoresSafeArea()

            if let data = weatherData {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {

                        // Location & Date
                        VStack(alignment: .leading, spacing: 4) {
                            Text(data.location.name)
                                .font(.appCallout)
                                .foregroundColor(scheme.textPrimary)

                            Text(WeatherUtils.formatToDayAndDate(data.current.last_updated) ?? "--")
                                .font(.appFootnote)
                                .foregroundColor(scheme.textSecondary)
                        }

                        Spacer(minLength: 330)

                        // Temperature & High/Low
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

                        // Current Condition
                        Text(data.current.condition.text)
                            .font(.appTitle2)
                            .foregroundColor(scheme.textPrimary)

                        // Hourly Forecast
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(relevantHourlyData(data), id: \.time_epoch) { hour in
                                    HourlyWeatherView(
                                        icon: WeatherUtils.getImageName(
                                            forConditionCode: String(hour.condition.code),
                                            isDay: hour.is_day
                                        ),
                                        time: hour.time.extractTime() ?? "--:--",
                                        tempC: hour.temp_c,
                                        tempF: hour.temp_f
                                    )
                                }
                            }
                            .padding(.trailing, 8)
                        }

                        // Weather Metrics
                        WeatherCardView(viewModel: data)
                    }
                    .padding()
                }
                .refreshable {
                    await refreshWeather(for: data.location.name)
                }
            } else {
                EmptyStateView(message: "No weather data available.")
            }
        }
        .onAppear(perform: injectWeatherDataIfNeeded)
    }

    // MARK: - Helpers

    private func formattedTemperature(_ data: WeatherData) -> String {
        let temp = Temperature(metricValue: data.current.temp_c, imperialValue: data.current.temp_f)
        return temp.formatted(for: appSettings.temperatureUnit, defaultUnit: .celsius, decimals: 0)
    }

    private func relevantHourlyData(_ data: WeatherData) -> [Hour] {
        let now = Int(Date().timeIntervalSince1970)
        let next24h = now + (24 * 60 * 60)

        return data.forecast.forecastday
            .flatMap(\.hour)
            .filter { $0.time_epoch >= now && $0.time_epoch <= next24h }
    }

    private func refreshWeather(for cityName: String) async {
        do {
            let data = try await weatherViewModel.weatherService.fetch(byCityName: cityName)
            weatherData = data
        } catch {
            print("❌ Refresh failed for \(cityName): \(error.localizedDescription)")
        }
    }

    private func injectWeatherDataIfNeeded() {
        guard let ext = externalWeatherData else { return }

        if weatherData == nil || ext.location.name != weatherData?.location.name {
            weatherData = ext
        }
    }
}
// MARK: - Previews

#if DEBUG
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let settings = AppSettings()
            let weatherVM = WeatherViewModel(weatherService: WeatherManager(), appSettings: settings)

            WeatherView(
                externalWeatherData: previewWeatherData,
                selectedIndex: 0
            )
            .environmentObject(settings)
            .environmentObject(weatherVM)
            .safePreferredColorScheme(.light)
            .previewDisplayName("WeatherView - Light")

            WeatherView(
                externalWeatherData: previewWeatherData,
                selectedIndex: 0
            )
            .environmentObject(settings)
            .environmentObject(weatherVM)
            .safePreferredColorScheme(.dark)
            .previewDisplayName("WeatherView - Dark")
        }
    }
}
#endif
