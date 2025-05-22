//
//  AppDependencies.swift
//  pWeather
//
//  Created by Macitch on 27.12.2024.
//

import SwiftUI

final class AppDependencies {
    static let shared = AppDependencies()
    
    private init() {} 
    
    lazy var appSettings: AppSettings = AppSettings()
    lazy var locationManager: LocationManager = LocationManager()
    lazy var weatherManager: WeatherManager = WeatherManager()
    lazy var weatherViewModel: WeatherViewModel = WeatherViewModel(
        weatherManager: weatherManager,
        appSettings: appSettings
    )
    lazy var locationViewModel: LocationViewModel = LocationViewModel(
        weatherManager: weatherManager
    )
}
