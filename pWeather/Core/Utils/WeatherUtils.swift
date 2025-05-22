/*
*  File: Weatherutils.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

// MARK: - Unit Types

/// Temperature units used in the app.
enum TemperatureUnit: String, CaseIterable {
    case celsius = "C"
    case fahrenheit = "F"
}

/// Wind speed units used in the app.
enum WindSpeedUnit: String, CaseIterable {
    case metersPerSecond = "m/s"
    case kilometersPerHour = "km/h"
    case milesPerHour = "mph"
}

/// Pressure units used in the app.
enum PressureUnit: String, CaseIterable {
    case millimetersOfMercury = "mmHg"
    case hectopascals = "hPa"
}

// MARK: - UnitConvertible Protocol

/// Protocol for converting and formatting metric/imperial values based on user preferences.
protocol UnitConvertible {
    associatedtype Unit: RawRepresentable where Unit.RawValue == String
    var metricValue: Double { get }
    var imperialValue: Double { get }
    func formattedValue(for unit: Unit, decimals: Int) -> String
}

extension UnitConvertible {
    /// Fallback-aware formatter using string input for user-configured unit.
    func formatted(for unit: String, defaultUnit: Unit, decimals: Int = 0) -> String {
        guard let validUnit = Unit(rawValue: unit) else {
            return formattedValue(for: defaultUnit, decimals: decimals)
        }
        return formattedValue(for: validUnit, decimals: decimals)
    }
}

// MARK: - Implementations for Units

/// Temperature conversion and formatting logic.
struct Temperature: UnitConvertible {
    typealias Unit = TemperatureUnit
    let metricValue: Double
    let imperialValue: Double

    func formattedValue(for unit: TemperatureUnit, decimals: Int) -> String {
        let value = unit == .celsius ? metricValue : imperialValue
        return String(format: "%.\(decimals)f°%@", value, unit.rawValue)
    }
}

/// Wind speed conversion and formatting logic.
struct WindSpeed: UnitConvertible {
    typealias Unit = WindSpeedUnit
    let metricValue: Double
    let imperialValue: Double

    func formattedValue(for unit: WindSpeedUnit, decimals _: Int) -> String {
        switch unit {
        case .kilometersPerHour:
            return "\(Int(metricValue)) \(unit.rawValue)"
        case .milesPerHour:
            return "\(Int(imperialValue)) \(unit.rawValue)"
        case .metersPerSecond:
            let speedMs = metricValue * 1000 / 3600
            return "\(Int(speedMs)) \(unit.rawValue)"
        }
    }
}

/// Pressure conversion and formatting logic.
struct Pressure: UnitConvertible {
    typealias Unit = PressureUnit
    let metricValue: Double
    let imperialValue: Double

    func formattedValue(for unit: PressureUnit, decimals _: Int) -> String {
        let value = unit == .millimetersOfMercury ? metricValue : imperialValue
        return "\(Int(value)) \(unit.rawValue)"
    }
}

// MARK: - WeatherUtils

/// Utility class for formatting and converting weather-related data.
class WeatherUtils {

    // MARK: - Date Formatters

    private static let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let dayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        return formatter
    }()

    // MARK: - Wind and Pressure

    /// Returns a formatted wind speed string based on user preference.
    static func formattedWindSpeed(speedKph: Double, speedMph: Double, unit: String) -> String {
        let wind = WindSpeed(metricValue: speedKph, imperialValue: speedMph)
        return wind.formatted(for: unit, defaultUnit: .kilometersPerHour)
    }

    /// Returns a formatted pressure string based on user preference.
    static func formattedPressure(pressureMb: Double, pressureIn: Double, unit: String) -> String {
        let pressure = Pressure(metricValue: pressureMb, imperialValue: pressureIn)
        return pressure.formatted(for: unit, defaultUnit: .hectopascals)
    }

    // MARK: - Time Formatting

    /// Converts API date string to `HH:mm` format.
    static func formatToTime(_ dateString: String) -> String {
        guard let date = inputFormatter.date(from: dateString) else {
            return "--:--"
        }
        return timeFormatter.string(from: date)
    }

    /// Converts API date string to a readable weekday + date format.
    static func formatToDayAndDate(_ dateString: String) -> String? {
        guard let date = inputFormatter.date(from: dateString) else { return nil }
        return dayDateFormatter.string(from: date)
    }

    /// Extracts only the time portion from a localtime string like `"2024-06-10 18:20"`.
    static func formatLocalTime(from localTime: String) -> String {
        let components = localTime.split(separator: " ")
        return components.last.map { String($0) } ?? "--:--"
    }

    // MARK: - Image Mapping

    /// Returns the appropriate condition image name based on condition code and day/night status.
    static func getImageName(forConditionCode code: String, isDay: Int) -> String {
        if isDay == 0 {
            let nightImageName = "\(code)_night"
            return UIImage(named: nightImageName) != nil ? nightImageName : code
        }
        return code
    }

    // MARK: - Temperature Helpers

    private static func formatTemperature(tempC: Double, tempF: Double, unit: String, decimals: Int = 0) -> String {
        let temp = Temperature(metricValue: tempC, imperialValue: tempF)
        return temp.formatted(for: unit, defaultUnit: .celsius, decimals: decimals)
    }

    // MARK: - WeatherData Extensions

    static func formattedTemperature(from data: WeatherData, unit: String) -> String {
        return formatTemperature(tempC: data.current.temp_c, tempF: data.current.temp_f, unit: unit)
    }

    static func highTemperature(from data: WeatherData, unit: String) -> String {
        guard let day = data.forecast.forecastday.first?.day else { return "--" }
        return formatTemperature(tempC: day.maxtemp_c, tempF: day.maxtemp_f, unit: unit)
    }

    static func lowTemperature(from data: WeatherData, unit: String) -> String {
        guard let day = data.forecast.forecastday.first?.day else { return "--" }
        return formatTemperature(tempC: day.mintemp_c, tempF: day.mintemp_f, unit: unit)
    }

    static func formattedTemperature(tempC: Double, tempF: Double, unit: String) -> String {
        return formatTemperature(tempC: tempC, tempF: tempF, unit: unit)
    }
}
