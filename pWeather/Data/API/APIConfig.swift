/*
*  File: ApiConfig.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 02.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A configuration structure for accessing the Weather API.
struct APIConfig {

    /// Your API key for authenticating with the Weather API.
    /// ⚠️ Note: In production, avoid hardcoding API keys. Use secure storage or remote config.
    static let apiKey = "YOUR_API_KEY"

    /// The base endpoint URL for fetching forecast data.
    static let baseURL = "https://api.weatherapi.com/v1/forecast.json"
}
