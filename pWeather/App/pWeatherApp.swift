/*
*  File: pWeatherApp.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

@main
struct pWeatherApp: App {
    let deps = AppDependencies.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            DynamicThemeView {
                RootView()
            }
            .environmentObject(deps.locationManager)
            .environmentObject(deps.locationViewModel)
            .environmentObject(deps.weatherViewModel)
            .environmentObject(deps.weatherPagerViewModel)
            .environmentObject(deps.appSettings) 
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                print("🔄 App became active")
                if let loc = deps.locationManager.userLocation {
                    deps.weatherViewModel.fetchCurrentLocationWeatherData(
                        latitude: loc.coordinate.latitude,
                        longitude: loc.coordinate.longitude
                    )
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
