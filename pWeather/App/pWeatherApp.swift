/*
*  File: pWeatherApp.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Entry point of the pWeather application.
/// Initializes dependency injection, applies dynamic theming, and manages lifecycle events.
@main
@MainActor
struct pWeatherApp: App {

    // MARK: - Dependencies

    /// Shared app-wide dependency container.
    let deps = AppDependencies.shared

    // MARK: - App Lifecycle

    /// Monitors the app's foreground/background state.
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            DynamicThemeView {
                RootView()
            }
            // Inject global app-wide objects into the environment
            .environmentObject(deps.locationManager)
            .environmentObject(deps.locationViewModel)
            .environmentObject(deps.weatherViewModel)
            .environmentObject(deps.weatherPagerViewModel)
            .environmentObject(deps.citySearchViewModel)
            .environmentObject(deps.appSettings)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                print("🔄 App became active")

                // ⚠️ Ensure safe access to @MainActor methods
                Task { @MainActor in
                    if let loc = deps.locationManager.userLocation {
                        deps.weatherViewModel.fetchCurrentLocationWeatherData(
                            latitude: loc.coordinate.latitude,
                            longitude: loc.coordinate.longitude
                        )
                    }
                }

            case .inactive:
                print("⏸ App became inactive")

            case .background:
                print("📤 App moved to background")

            default:
                break
            }
        }
    }
}
