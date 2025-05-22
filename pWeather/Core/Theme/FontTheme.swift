/*
*  File: FontTheme.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// Custom font aliases used throughout the app for visual consistency.
extension Font {
    // MARK: - Small Text Styles
    static var appBody: Font        { AppFont.body }
    static var appCallout: Font     { AppFont.callout }
    static var appFootnote: Font    { AppFont.footnote }
    static var appCaption: Font     { AppFont.caption }

    // MARK: - Medium Text Styles
    static var appHeadline: Font    { AppFont.headline }
    static var appSubheadline: Font { AppFont.subheadline }

    // MARK: - Title Styles
    static var appTitle3: Font      { AppFont.title3 }
    static var appTitle2: Font      { AppFont.title2 }
    static var appTitle1: Font      { AppFont.title1 }

    // MARK: - Large Display Styles
    static var appLargeTitle: Font  { AppFont.largeTitle }
    static var appHugeTemp: Font    { AppFont.hugeTemp } // e.g., large weather temperature
}
