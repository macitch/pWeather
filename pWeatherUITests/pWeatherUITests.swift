/*
*  File: pWeatherUITests.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 01.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/


import XCTest

class pWeatherUITests: XCTestCase {
    func testLocationRequestFlow() {
        let app = XCUIApplication()
        app.launch()
        
        // Verify location request view is displayed
        XCTAssertTrue(app.staticTexts["Grant location access to find nearby places"].exists)
        
        // Simulate "Allow Location" button tap
        app.buttons["Allow Location"].tap()
        
        // Verify that weather view is displayed
        XCTAssertTrue(app.staticTexts["Weather"].exists)
    }
}
