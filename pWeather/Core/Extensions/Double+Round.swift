/*
*  File: Double+Round.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Utility extension for rounding a `Double` to a whole number string.
extension Double {
    /// Rounds the double to the nearest whole number and returns it as a string.
    ///
    /// Example:
    /// ```swift
    /// let value = 23.7
    /// print(value.roundDouble()) // "24"
    /// ```
    func roundDouble() -> String {
        String(format: "%.0f", self)
    }
}
