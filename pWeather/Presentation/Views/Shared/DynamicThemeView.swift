/*
*  File: DynamicThemeView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 04.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A wrapper view that applies a dynamic color scheme based on the user's selected theme mode.
/// The content provided will respect the theme defined in `AppSettings`.
struct DynamicThemeView<Content: View>: View {
    
    /// The app-wide settings object that holds the current theme mode.
    @EnvironmentObject var appSettings: AppSettings
    
    /// The content view to be displayed inside the dynamic theme container.
    let content: () -> Content

    var body: some View {
        content()
            // Applies the appropriate color scheme based on user settings.
            .preferredColorScheme(colorSchemeFrom(appSettings.themeMode))
    }

    /// Maps the `ThemeMode` enum to SwiftUI's `ColorScheme`.
    ///
    /// - Parameter mode: The theme mode selected by the user.
    /// - Returns: A corresponding `ColorScheme`, or `nil` to follow the system setting.
    private func colorSchemeFrom(_ mode: ThemeMode) -> ColorScheme? {
        switch mode {
        case .system:
            return nil // Follows the device's system theme.
        case .light:
            return .light // Forces light mode.
        case .dark:
            return .dark // Forces dark mode.
        }
    }
}
