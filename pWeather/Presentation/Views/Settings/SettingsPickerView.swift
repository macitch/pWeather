/*
*  File: SettingsPickerView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 07.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A reusable settings row that displays a segmented picker for selecting one of several predefined options.
/// Commonly used for selecting units, themes, or other categorical preferences.
struct SettingPickerView: View {

    // MARK: - Input Properties

    /// The title displayed on the leading side of the row.
    let title: String

    /// A binding to the currently selected value.
    @Binding var selection: String

    /// A list of selectable string options for the picker.
    let options: [String]

    /// A closure called whenever the selection changes.
    let onChange: (String) -> Void

    // MARK: - Environment

    /// Accesses the system's current color scheme (light/dark) for dynamic theming.
    @Environment(\.colorScheme) private var scheme

    // MARK: - View Body

    var body: some View {
        HStack {
            // Setting label
            Text(title)
                .font(.appHeadline)
                .foregroundColor(scheme.textPrimary)

            Spacer()

            // Segmented picker
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .font(.appCallout)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selection) { newValue in
                onChange(newValue)
            }
            .frame(maxWidth: 180) // Limits picker width for layout consistency
        }
        .padding(20)
        .background(scheme.surface)
        .cornerRadius(8)
    }
}
