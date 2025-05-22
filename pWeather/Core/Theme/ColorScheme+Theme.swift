/*
*  File: ColorScheme+Theme.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Semantic color accessors based on the current system color scheme.
extension ColorScheme {

    // MARK: - Text Colors

    /// Primary text color adapted to light/dark mode.
    var textPrimary: Color {
        self == .light ? SemanticColors.textPrimaryLight : SemanticColors.textPrimaryDark
    }

    /// Secondary text color adapted to light/dark mode.
    var textSecondary: Color {
        self == .light ? SemanticColors.textSecondaryLight : SemanticColors.textSecondaryDark
    }

    // MARK: - Backgrounds

    /// Global background color (used for full screens).
    var background: Color {
        self == .light ? SemanticColors.backgroundLight : SemanticColors.backgroundDark
    }

    /// Surface color (used for cards, panels, etc.).
    var surface: Color {
        self == .light ? SemanticColors.surfaceLight : SemanticColors.surfaceDark
    }

    // MARK: - UI Elements

    /// Separator color (lines/dividers) adjusted for theme.
    var separator: Color {
        self == .light ? SemanticColors.separatorLight : SemanticColors.separatorDark
    }

    /// Overlay color for modals, loading views, etc.
    var overlay: Color {
        self == .light ? SemanticColors.overlayLight : SemanticColors.overlayDark
    }

    // MARK: - Brand Colors (Static)

    /// App’s primary red color for emphasis/highlight.
    var brandRed: Color {
        SemanticColors.brandRed
    }

    /// App’s blue accent, often used for actions or links.
    var brandBlue: Color {
        SemanticColors.brandBlue
    }

    /// Purple tint used for secondary branding or status.
    var brandPurple: Color {
        SemanticColors.brandPurple
    }

    /// Accent color used for buttons, tags, highlights.
    var accent: Color {
        SemanticColors.accent
    }
}
