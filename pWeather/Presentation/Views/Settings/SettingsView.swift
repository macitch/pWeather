/*
*  File: SettingsView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 06.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A settings screen where users can customize their preferences for units, theme mode, and saved locations.
struct SettingsView: View {

    // MARK: - Environment

    /// Shared application settings including units and saved cities.
    @EnvironmentObject var appSettings: AppSettings

    /// Tracks the system's current color scheme for adaptive styling.
    @Environment(\.colorScheme) private var scheme

    // MARK: - State

    /// Controls the visibility of the "Clear All Locations" confirmation dialog.
    @State private var showClearConfirmation = false

    // MARK: - Unit Options

    private let temperatureUnits = ["°C", "°F"]
    private let windSpeedUnits = ["mph", "km/h"]
    private let pressureUnits = ["mmHg", "hPa"]
    private let themeModes: [ThemeMode] = [.system, .light, .dark]

    // MARK: - View Body

    var body: some View {
        ZStack {
            scheme.background
                .ignoresSafeArea(.all, edges: .all)

            VStack(spacing: 50) {
                // MARK: Units Section
                settingsSection(title: "Units") {
                    SettingPickerView(
                        title: "Degrees",
                        selection: Binding(
                            get: { appSettings.temperatureUnit == "C" ? "°C" : "°F" },
                            set: { newValue in
                                let clean = newValue.replacingOccurrences(of: "°", with: "")
                                appSettings.toggleTemperatureUnit(to: clean)
                                print("Temperature changed to \(clean)")
                            }
                        ),
                        options: temperatureUnits
                    ) { _ in }

                    SettingPickerView(
                        title: "Wind",
                        selection: $appSettings.windSpeedUnit,
                        options: windSpeedUnits
                    ) { newUnit in
                        appSettings.toggleWindSpeedUnit(to: newUnit)
                        print("Wind changed to \(newUnit)")
                    }

                    SettingPickerView(
                        title: "Pressure",
                        selection: $appSettings.pressureUnit,
                        options: pressureUnits
                    ) { newUnit in
                        appSettings.togglePressureUnit(to: newUnit)
                        print("Pressure changed to \(newUnit)")
                    }
                }

                // MARK: Preferences Section
                settingsSection(title: "Preferences") {
                    SettingPickerView(
                        title: "Theme",
                        selection: Binding(
                            get: { appSettings.themeMode.displayName },
                            set: { newValue in
                                if let newMode = ThemeMode.allCases.first(where: { $0.displayName == newValue }) {
                                    appSettings.themeMode = newMode
                                    print("Theme mode changed to \(newMode)")
                                }
                            }
                        ),
                        options: themeModes.map { $0.displayName }
                    ) { _ in }

                    SettingButtonView(
                        title: "Clear list of Locations",
                        action: { showClearConfirmation = true },
                        color: Color(hex: "#E35964") // Custom red shade for destructive action
                    )
                }
            }
            .padding()
        }

        // MARK: - Clear All Confirmation Dialog
        .confirmationDialog(
            "Are you sure you want to clear all saved locations?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All", role: .destructive) {
                appSettings.clearAllCities()
                print("✅ Cleared all saved cities.")
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Section Wrapper

    /// Helper to create a styled section with a title and content.
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.appHeadline)
                .foregroundColor(scheme.textPrimary)
                .padding(.bottom, 8)

            content()
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
        .safePreferredColorScheme(.light)
}
