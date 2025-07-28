/*
*  File: LocationSelectorView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A wrapper view that connects the `LocationSearchView` to the broader application context.
/// It passes along the view model, app settings, and selected tab binding for navigation control.
struct LocationSelectorView: View {

    // MARK: - Input Properties

    /// The view model responsible for managing location state.
    @EnvironmentObject var locationViewModel: LocationViewModel

    /// The view model responsible for managing city search logic.
    @EnvironmentObject var citySearchViewModel: CitySearchViewModel

    /// The global app settings, injected from the environment.
    @EnvironmentObject var appSettings: AppSettings

    /// Binding to the selected tab index, used to switch between views in a parent container.
    @Binding var selectedTab: Int

    // MARK: - View Body

    var body: some View {
        // Passes all required dependencies to the main search view.
        LocationSearchView(
            searchViewModel: citySearchViewModel,
            selectedTab: $selectedTab
        )
        .environmentObject(locationViewModel)
        .environmentObject(appSettings)
    }
}
