/*
*  File: ApiService.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 02.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

/// A lightweight, retry-capable HTTP client for fetching and decoding JSON APIs.
actor APIService {

    // MARK: - Singleton

    /// Shared instance of the API service (singleton pattern).
    static let shared = APIService()

    /// Private initializer to enforce singleton usage.
    private init() {}

    // MARK: - JSON Fetch Method

    /// Fetches and decodes JSON from the specified URL into a `Decodable` model.
    ///
    /// - Parameters:
    ///   - url:          The endpoint URL to request.
    ///   - responseType: The expected `Decodable` type.
    ///   - retries:      The number of retry attempts for transient failures (default: 2).
    ///
    /// - Returns: A decoded instance of the requested type `T`.
    /// - Throws: `APIError` if the request fails or decoding fails.
    func fetch<T: Decodable>(
        _ url: URL,
        responseType: T.Type,
        retries: Int = 2
    ) async throws -> T {
        var attempt = 0

        while true {
            do {
                print("🌐 DEBUG: APIService.request → \(url) (attempt \(attempt + 1))")

                // Perform the HTTP request
                let (data, response) = try await URLSession.shared.data(from: url)

                // Ensure we received an HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ DEBUG: APIService.invalidResponse")
                    throw APIError.invalidResponse(statusCode: -1)
                }

                // Check for a successful 2xx status code
                guard (200..<300).contains(httpResponse.statusCode) else {
                    print("❌ DEBUG: APIService.statusCode \(httpResponse.statusCode)")
                    throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
                }

                // Attempt to decode the response into the expected model
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    print("❌ DEBUG: APIService.decodingError \(error)")
                    throw APIError.decodingError(error)
                }

            } catch {
                attempt += 1
                if attempt > retries {
                    print("⚠️ DEBUG: APIService failed after \(attempt) attempts → \(error)")
                    throw APIError.requestFailed(error)
                }

                // Exponential backoff (200ms)
                try await Task.sleep(nanoseconds: 200_000_000)
            }
        }
    }
}
