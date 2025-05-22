//
//  MockWeatherManager.swift
//  pWeather
//
//  Created by Macitch on 27.12.2024.
//

import SwiftUI
import CoreLocation

class MockWeatherManager: WeatherManager {
    override func fetchWeatherByCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> WeatherData {
        return previewWeatherData
    }
    
    override func fetchWeatherByCityName(city: String) async throws -> WeatherData {
        return previewWeatherData
    }
}
