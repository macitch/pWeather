/*
*  File: ApiError.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 02.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A comprehensive list of API-related errors that can occur during network requests.
enum APIError: Error {

    /// Indicates the URL could not be constructed correctly.
    case badURL

    /// Represents an underlying system or network error, such as timeout or lost connection.
    case requestFailed(Error)

    /// Indicates an HTTP response with a non-success status code (e.g., 404, 500).
    case invalidResponse(statusCode: Int)

    /// Represents a failure to decode the response data into the expected model.
    case decodingError(Error)
}
