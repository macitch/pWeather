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

        let locationTitle = app.staticTexts["Location Access Needed"]
        XCTAssertTrue(
            locationTitle.waitForExistence(timeout: 10),
            "Expected location request screen to appear."
        )

        let grantAccessButton = app.buttons["Grant Access"]
        XCTAssertTrue(
            grantAccessButton.waitForExistence(timeout: 5),
            "Expected Grant Access button to appear."
        )
        grantAccessButton.tap()

        let possiblePostTapStates = [
            app.staticTexts["Fetching data for your location…"],
            app.staticTexts["Something went wrong"],
            app.staticTexts["Location Access Needed"],
            app.staticTexts["No cities available."]
        ]

        let stateAppeared = possiblePostTapStates.contains { $0.waitForExistence(timeout: 10) }
        XCTAssertTrue(
            stateAppeared,
            "Expected app to transition to a valid post-permission state."
        )
    }
}
