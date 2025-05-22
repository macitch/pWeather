/*
*  File: Helpers.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 02.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

// MARK: - File Loading Error

/// Represents errors that can occur while loading and decoding local files.
enum FileLoadingError: Error, LocalizedError {
    /// The specified file was not found in the main bundle.
    case fileNotFound(String)
    
    /// JSON decoding failed with a decoding error.
    case decodingFailed(Error)
    
    /// An unknown error occurred during file loading or decoding.
    case unknownError(Error)
    
    /// User-facing error message for display/debugging.
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "File '\(filename)' not found in the main bundle."
        case .decodingFailed(let error):
            return "Failed to decode JSON: \(error.localizedDescription)"
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Generic JSON File Loader

/// Loads and decodes a JSON file from the app bundle.
///
/// - Parameters:
///   - filename: The name of the file (e.g., `"weatherData.json"`).
///   - type: The expected `Decodable` type.
/// - Returns: An instance of `T` parsed from the file.
/// - Throws: A `FileLoadingError` if the file is missing or invalid.
func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) throws -> T {
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        throw FileLoadingError.fileNotFound(filename)
    }

    do {
        let data = try Data(contentsOf: file)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    } catch let decodingError as DecodingError {
        throw FileLoadingError.decodingFailed(decodingError)
    } catch {
        throw FileLoadingError.unknownError(error)
    }
}

// MARK: - Convenience Loader for Hourly Forecast Preview

/// Attempts to load and extract hourly forecast data from a sample file.
///
/// - Parameter filename: The JSON file containing `WeatherData`.
/// - Returns: A `Result` with either `[Hour]` data or a `FileLoadingError`.
func loadHourlyData(from filename: String) -> Result<[Hour], FileLoadingError> {
    do {
        let weatherData: WeatherData = try load(filename)
        return .success(weatherData.forecast.forecastday.first?.hour ?? [])
    } catch let error as FileLoadingError {
        return .failure(error)
    } catch {
        return .failure(.unknownError(error))
    }
}

// MARK: - Preloaded Preview Data

/// Static preview weather data for use in SwiftUI previews.
/// Will cause a fatal error if the data cannot be loaded.
var previewWeatherData: WeatherData = {
    do {
        return try load("weatherData.json")
    } catch {
        fatalError("❌ Failed to load preview data: \(error.localizedDescription)")
    }
}()
