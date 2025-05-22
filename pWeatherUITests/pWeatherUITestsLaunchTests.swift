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
        
        // Assert the app launched successfully
        XCTAssertTrue(app.otherElements["MainView"].exists)
    }
}
