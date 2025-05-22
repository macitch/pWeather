/*
*  File: String+TimeFormat.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// String extensions for parsing and formatting time values.
extension String {

    /// Extracts just the time (e.g., `"14:20"`) from a full timestamp like `"2025-01-01 14:20"`.
    ///
    /// - Returns: A string in `"HH:mm"` format, or `nil` if the input can't be parsed.
    func extractTime() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = formatter.date(from: self) else { return nil }

        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// Converts a 12-hour formatted time string like `"6:45 AM"` into `"06:45"` (24-hour format).
    ///
    /// - Returns: A string in `"HH:mm"` format, or `nil` if parsing fails.
    func convert12HourTo24Hour() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = formatter.date(from: self) else { return nil }

        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// Converts a time string to match the user's system preference (12h/24h).
    ///
    /// - Parameter inputFormat: Format of the current string (default `"HH:mm"`).
    /// - Returns: A localized string like `"6:45 PM"` or `"18:45"`.
    func localizedTimeFormatted(fromFormat inputFormat: String = "HH:mm") -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: self) else { return self }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale.current
        outputFormatter.setLocalizedDateFormatFromTemplate("j:mm") // Auto-selects based on device settings

        return outputFormatter.string(from: date)
    }

    /// Utility: Converts `"6:30 AM"` to the user's local time format (e.g., `"6:30"` or `"06:30"`).
    ///
    /// - Returns: A localized time string, or the original if conversion fails.
    func formattedToLocalTime() -> String {
        return convert12HourTo24Hour()?.localizedTimeFormatted() ?? self
    }
}
