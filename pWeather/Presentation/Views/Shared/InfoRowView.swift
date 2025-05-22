/*
*  File: InfoRowView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A reusable view that displays a labeled piece of information in a horizontal layout.
/// Typically used for metadata display (e.g., temperature, humidity).
struct InfoRowView: View {
    
    /// The descriptor or category name (e.g., "Humidity").
    let label: String
    
    /// The associated value for the label (e.g., "82%").
    let value: String

    /// Accesses the current system color scheme (light or dark mode).
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack {
            // Display the label with a custom footnote font and dynamic color.
            Text(label)
                .font(.appFootnote)
                .foregroundColor(scheme.textPrimary)

            // Display the value using a custom headline font and matching color.
            Text(value)
                .font(.appHeadline)
                .foregroundColor(scheme.textPrimary)
        }
        // Treats both label and value as a single accessibility element.
        .accessibilityElement(children: .combine)
        
        // Provides a readable accessibility label (e.g., "Humidity 82 percent").
        .accessibilityLabel("\(label) \(value)")
    }
}
