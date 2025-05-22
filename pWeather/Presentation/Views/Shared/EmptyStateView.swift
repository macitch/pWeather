/*
*  File: EmptyStateView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 06.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A simple, reusable view used to display an empty state message when there is no content to show.
/// Commonly used for scenarios like empty lists, missing search results, or initial onboarding.
struct EmptyStateView: View {
    
    // MARK: - Input Properties

    /// The message to display to the user (e.g., "No data available").
    let message: String

    // MARK: - Environment

    /// Provides access to the current system color scheme to apply appropriate styling.
    @Environment(\.colorScheme) private var scheme

    // MARK: - View Body

    var body: some View {
        VStack {
            Text(message)
                .font(.appHeadline)
                .foregroundColor(scheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(scheme.surface)
    }
}
