/*
*  File: SettingButtonView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 07.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A reusable setting row view that displays a labeled button aligned to the leading edge.
/// Useful for settings menus where each row performs a different action (e.g., toggles, navigations).
struct SettingButtonView: View {

    // MARK: - Input Properties

    /// The title text displayed in the button.
    let title: String

    /// The action executed when the button is tapped.
    let action: () -> Void

    /// The highlight color for the button (default is `.accentColor`).
    let color: Color

    // MARK: - Environment

    /// Accesses the system's color scheme for theming.
    @Environment(\.colorScheme) private var scheme

    // MARK: - Initializer

    init(title: String, action: @escaping () -> Void, color: Color = .accentColor) {
        self.title = title
        self.action = action
        self.color = color
    }

    // MARK: - View Body

    var body: some View {
        HStack {
            Button(action: action) {
                Text(title)
                    .font(.appHeadline)
                    .foregroundColor(scheme.textPrimary)
            }
            Spacer()
        }
        .padding(20)
        .background(scheme.surface)
        .cornerRadius(8)
    }
}
