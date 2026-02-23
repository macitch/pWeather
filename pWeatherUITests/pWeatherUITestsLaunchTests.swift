/*
*  File: pWeatherUITestsLaunchTests.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/


import XCTest

class pWeatherUITestsLaunchTests: XCTestCase {
    func testAppLaunch() {
        let app = XCUIApplication()
        app.launch()

        let launchIndicators = [
            app.staticTexts["Location Access Needed"],
            app.staticTexts["Fetching data for your location…"],
            app.staticTexts["Something went wrong"],
            app.staticTexts["No cities available."]
        ]

        let launched = launchIndicators.contains { $0.waitForExistence(timeout: 10) }
        XCTAssertTrue(launched, "Expected one of the root app states to appear after launch.")
    }
}
