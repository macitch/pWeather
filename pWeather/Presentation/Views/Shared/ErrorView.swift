/*
*  File: ErrorView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 06.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A reusable error view that presents a title, message, and action buttons.
/// Designed to be used across the app for handling and displaying error states.
struct ErrorView: View {

    // MARK: - Input Properties

    /// The main title displayed at the top of the error view.
    let title: String

    /// A detailed message explaining the error or providing user guidance.
    let message: String

    /// Action executed when the user taps the "Retry" button.
    let retryAction: () -> Void

    /// Whether to display a "Settings" button (e.g., for permissions-related errors).
    var showSettingsButton: Bool = false

    /// Optional action executed when the user taps the "Settings" button.
    var openSettingsAction: (() -> Void)? = nil

    // MARK: - Environment

    /// Accesses the system's current color scheme to apply adaptive styling.
    @Environment(\.colorScheme) private var scheme

    // MARK: - View Body

    var body: some View {
        VStack(spacing: 20) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(scheme.brandRed)
                .padding(.bottom, 8)

            // Error title
            Text(title)
                .font(.appTitle2)
                .foregroundColor(scheme.textPrimary)

            // Error message
            Text(message)
                .font(.appBody)
                .foregroundColor(scheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Action buttons
            HStack(spacing: 16) {
                // Retry button
                Button(action: retryAction) {
                    Text("Retry")
                        .font(.appCallout)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(scheme.brandPurple)
                        .foregroundColor(scheme.textPrimary)
                        .cornerRadius(8)
                }

                // Optional Settings button
                if showSettingsButton, let openSettingsAction {
                    Button(action: openSettingsAction) {
                        Text("Settings")
                            .font(.appCallout)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(scheme.accent)
                            .foregroundColor(scheme.textPrimary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(scheme.surface)
    }
}
