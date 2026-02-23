/*
*  File: pWeatherTests.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import XCTest
@testable import pWeather

class WeatherManagerTests: XCTestCase {
    func testFetchWeatherByCityName() async throws {
        let manager = WeatherManager()
        let weather = try await manager.fetch(byCityName: "Zurich")
        XCTAssertNotNil(weather, "Weather data should not be nil.")
    }
}
