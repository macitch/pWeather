/*
*  File: HourlyWeatherView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A compact weather card displaying hourly weather data including icon, time, and temperature.
/// Designed to be displayed in a horizontally scrollable list.
struct HourlyWeatherView: View {

	 // MARK: - Environment

	 /// Accesses the current color scheme to apply adaptive styling.
	 @Environment(\.colorScheme) private var scheme

	 /// Accesses app-wide settings, including user-selected temperature unit.
	 @EnvironmentObject private var appSettings: AppSettings

	 // MARK: - Input Properties

	 /// Name of the weather condition icon asset (e.g., "1000_day").
	 let icon: String

	 /// Time string for the hour slot (e.g., "08:00 AM").
	 let time: String

	 /// Temperature in Celsius.
	 let tempC: Double

	 /// Temperature in Fahrenheit.
	 let tempF: Double

	 // MARK: - Computed Properties

	 /// Formatted temperature string based on user settings.
	 private var temperature: String {
		  WeatherUtils.formattedTemperature(
				tempC: tempC,
				tempF: tempF,
				unit: appSettings.temperatureUnit
		  )
	 }

	 // MARK: - View Body

	 var body: some View {
		  VStack(spacing: 4) {
				// Weather icon
				Image(icon)
					 .renderingMode(.template)
					 .resizable()
					 .aspectRatio(contentMode: .fit)
					 .foregroundColor(scheme.textPrimary)
					 .frame(width: 32, height: 32)
					 .accessibilityHidden(true)

				// Time label
				Text(time)
					 .font(.appFootnote)
					 .foregroundColor(scheme.textPrimary)
					 .lineLimit(1)
					 .minimumScaleFactor(0.8)

				// Temperature label
				Text(temperature)
					 .font(.appHeadline)
					 .foregroundColor(scheme.textPrimary)
					 .lineLimit(1)
					 .minimumScaleFactor(0.8)
		  }
		  .padding(.vertical, 8)
		  .frame(width: 80, height: 100)
		  .background(scheme.surface)
		  .cornerRadius(8)
		  .accessibilityElement(children: .combine)
		  .accessibilityLabel("At \(time), the temperature is \(temperature)")
	 }
}

// MARK: - Previews

#if DEBUG
struct HourlyWeatherView_Previews: PreviewProvider {
	 static var previews: some View {
		  Group {
				let sampleHour = previewWeatherData.forecast.forecastday.first!.hour.first!

				HourlyWeatherView(
					 icon: "1000_night",
					 time: sampleHour.time.extractTime() ?? "N/A",
					 tempC: sampleHour.temp_c,
					 tempF: sampleHour.temp_f
				)
				.environmentObject(AppSettings())
				.safePreferredColorScheme(.light)
				.padding()
				.previewDisplayName("HourlyWeatherView - Light")

				HourlyWeatherView(
					 icon: "1000_night",
					 time: sampleHour.time.extractTime() ?? "N/A",
					 tempC: sampleHour.temp_c,
					 tempF: sampleHour.temp_f
				)
				.environmentObject(AppSettings())
				.safePreferredColorScheme(.dark)
				.padding()
				.previewDisplayName("HourlyWeatherView - Dark")
		  }
	 }
}
#endif
