/*
*  File: View+CornerRadius.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

// MARK: - View Extension for Selective Corner Radius & Safe Color Scheme

extension View {
    /// Applies a corner radius to specific corners of a view.
    ///
    /// - Parameters:
    ///   - radius: The radius of the rounded corners.
    ///   - corners: The corners to apply the radius to.
    /// - Returns: A view with the specified corners rounded.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    /// Safely applies `.preferredColorScheme` only on supported OS versions (iOS 15+).
    ///
    /// - Parameter scheme: The desired `ColorScheme` (`.light`, `.dark`, or `nil`).
    /// - Returns: A view that applies the color scheme conditionally.
    @ViewBuilder
    func safePreferredColorScheme(_ scheme: ColorScheme?) -> some View {
        if #available(iOS 15.0, *) {
            self.preferredColorScheme(scheme)
        } else {
            self
        }
    }
}

// MARK: - Custom Shape for Rounding Specific Corners

/// A custom `Shape` that allows rounding specific corners of a view.
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    /// Creates a `Path` for the rounded rectangle with specified corners.
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
