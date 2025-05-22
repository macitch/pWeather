/*
*  File: PageIndicator.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 03.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A custom view that displays a horizontal row of dots representing pagination.
/// The first dot is replaced by a location icon, indicating the current location.
/// The indicator style adapts to the system or inverted color scheme.
struct PageIndicator: View {
    
    // MARK: - Input Properties

    /// Total number of pages to represent.
    let numberOfPages: Int

    /// The index of the currently active page.
    let currentIndex: Int

    /// If true, inverts the current color scheme (used for visibility over varying backgrounds).
    var forceInvertScheme: Bool = false

    // MARK: - Environment

    /// Accesses the system's current color scheme (light/dark).
    @Environment(\.colorScheme) private var scheme

    // MARK: - View Body

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                if index == 0 {
                    // The first page is the current location, indicated by a filled location icon.
                    Image(systemName: "location.fill")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(index == currentIndex ? activeDotColor : inactiveDotColor)
                } else {
                    // Subsequent pages are represented by simple circles.
                    Circle()
                        .fill(index == currentIndex ? activeDotColor : inactiveDotColor)
                        .frame(width: 8, height: 8)
                }
            }
        }
    }

    // MARK: - Styling Helpers

    /// The color used for the active (currently selected) page indicator.
    private var activeDotColor: Color {
        effectiveScheme == .light ? effectiveScheme.brandRed : effectiveScheme.textPrimary
    }

    /// The color used for inactive page indicators, with reduced opacity.
    private var inactiveDotColor: Color {
        effectiveScheme.surface.opacity(0.4)
    }

    /// Determines the actual color scheme to apply, optionally inverting it.
    private var effectiveScheme: ColorScheme {
        forceInvertScheme
            ? (scheme == .light ? .dark : .light)
            : scheme
    }
}
