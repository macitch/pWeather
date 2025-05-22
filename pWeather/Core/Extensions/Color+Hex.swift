/*
*  File: Color+Hex.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Extension to initialize SwiftUI `Color` using a hex string.
/// Supports 3-digit, 6-digit (RGB), and 8-digit (ARGB) formats.
extension Color {

    /// Creates a `Color` from a hex string (e.g. "#FF0000", "3498db", "80FFFFFF").
    ///
    /// - Parameter hex: A hex string representing the color.
    ///   - Supports:
    ///     - 3-digit RGB (e.g. `"F00"`)
    ///     - 6-digit RGB (e.g. `"FF0000"`)
    ///     - 8-digit ARGB (e.g. `"80FF0000"`)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        case 8: // AARRGGBB (32-bit)
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default: // Invalid format — fallback to transparent black
            (a, r, g, b) = (0, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
