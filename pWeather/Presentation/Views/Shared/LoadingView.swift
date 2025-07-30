/*
*  File: LoadingView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 06.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A full-screen loading overlay view with a translucent background and circular progress indicator.
/// Commonly used to block user interaction during asynchronous operations.
struct LoadingView: View {

    // MARK: - Environment

    /// Accesses the system's color scheme to apply dynamic theming.
    @Environment(\.colorScheme) private var scheme

    // MARK: - Customization Options

    /// The tint color of the progress spinner. Default is white.
    var tintColor: Color = .white

    /// The opacity level of the background overlay. Default is 0.5.
    var backgroundOpacity: Double = 0.5

    // MARK: - View Body

    var body: some View {
        ZStack {
            // Semi-transparent overlay that fills the screen.
            Color.black
                .opacity(backgroundOpacity)
                .ignoresSafeArea()

            // Centered loading spinner with customizable tint.
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
        }
    }
}
