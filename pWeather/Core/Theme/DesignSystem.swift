/*
*  File: DesignSystem.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

// MARK: – Base Palette

/// Base brand and neutral colors used throughout the app.
struct AppColors {
    static let appBlue         = Color(hex: "#446df6")
    static let appPurple       = Color(hex: "#5635E0")
    static let appYellow       = Color(hex: "#F5C652")
    static let appRed          = Color(hex: "#E55039")
    static let appBlack        = Color(hex: "#1C1E21")
    static let appWhite        = Color(hex: "#F0F0F0")
    static let appGray         = Color(hex: "#AFAFAF")
    static let appLightSurface = Color(hex: "#DEE4E7")
    static let appDarkSurface  = Color(hex: "#22262A")
}

// MARK: – Font Styles

/// Centralized custom font definitions for semantic styling.
struct AppFont {
    // Body Text
    static let body        = Font.custom("BROmega-Regular", size: 17)
    static let callout     = Font.custom("BROmega-Regular", size: 16)
    static let footnote    = Font.custom("BROmega-Regular", size: 13)
    static let caption     = Font.custom("BROmega-Regular", size: 12)

    // Headlines
    static let headline    = Font.custom("BROmega-Bold", size: 17)
    static let subheadline = Font.custom("BROmega-Regular", size: 15)

    // Titles
    static let title3      = Font.custom("BROmega-Bold", size: 20)
    static let title2      = Font.custom("BROmega-Bold", size: 22)
    static let title1      = Font.custom("BROmega-Bold", size: 28)

    // Large Display
    static let largeTitle  = Font.custom("BROmega-Black", size: 34)
    static let hugeTemp    = Font.custom("BROmega-Black", size: 144)
}

// MARK: – Semantic Colors

/// Semantic color tokens mapped to light/dark variants.
struct SemanticColors {
    // Backgrounds
    static let backgroundLight = AppColors.appWhite
    static let backgroundDark  = AppColors.appBlack

    static let surfaceLight    = AppColors.appLightSurface
    static let surfaceDark     = AppColors.appDarkSurface

    // Text Colors
    static let textPrimaryLight   = AppColors.appBlack
    static let textPrimaryDark    = AppColors.appWhite
    static let textSecondaryLight = AppColors.appGray
    static let textSecondaryDark  = AppColors.appGray

    // Brand & Accent
    static let accent      = AppColors.appYellow
    static let brandBlue   = AppColors.appBlue
    static let brandPurple = AppColors.appPurple
    static let brandRed    = AppColors.appRed

    // Separators
    static let separatorLight = Color(hex: "#D1D1D6")
    static let separatorDark  = Color(hex: "#2C2C2E")

    // Overlay Backgrounds
    static let overlayLight   = AppColors.appWhite.opacity(0.75)
    static let overlayDark    = AppColors.appBlack.opacity(0.75)
}

// MARK: – Adaptive Color Helpers

extension SemanticColors {

    /// Returns the primary text color for the given color scheme.
    static func primaryText(for scheme: ColorScheme) -> Color {
        scheme == .light ? textPrimaryLight : textPrimaryDark
    }

    /// Returns the secondary text color for the given color scheme.
    static func secondaryText(for scheme: ColorScheme) -> Color {
        scheme == .light ? textSecondaryLight : textSecondaryDark
    }

    /// Returns the surface color for cards/panels based on scheme.
    static func surface(for scheme: ColorScheme) -> Color {
        scheme == .light ? surfaceLight : surfaceDark
    }

    /// Returns the screen background color for the given scheme.
    static func background(for scheme: ColorScheme) -> Color {
        scheme == .light ? backgroundLight : backgroundDark
    }

    /// Returns the separator color for list or UI dividers.
    static func separator(for scheme: ColorScheme) -> Color {
        scheme == .light ? separatorLight : separatorDark
    }

    /// Returns a semi-transparent overlay color based on scheme.
    static func overlay(for scheme: ColorScheme) -> Color {
        scheme == .light ? overlayLight : overlayDark
    }
}
