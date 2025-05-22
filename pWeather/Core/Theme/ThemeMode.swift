/*
*  File: ThemeMode.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Defines the visual theme mode selected by the user.
enum ThemeMode: String, CaseIterable, Identifiable {
    
    /// Follows the system-wide appearance (light/dark).
    case system
    
    /// Always use light mode.
    case light
    
    /// Always use dark mode.
    case dark

    /// Unique identifier for use in SwiftUI lists or pickers.
    var id: String { rawValue }

    /// User-facing display name for each theme option.
    var displayName: String {
        switch self {
        case .system: return "Auto"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
}
