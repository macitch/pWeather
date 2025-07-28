/*
*  File: Weatherutils.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 05.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI

// MARK: - Unit Types

/// Units of temperature supported by the app.
enum TemperatureUnit: String, CaseIterable {
    case celsius = "C"
    case fahrenheit = "F"
}

/// Units of wind speed supported by the app.
enum WindSpeedUnit: String, CaseIterable {
    case metersPerSecond = "m/s"
    case kilometersPerHour = "km/h"
    case milesPerHour = "mph"
}

/// Units of atmospheric pressure supported by the app.
enum PressureUnit: String, CaseIterable {
    case millimetersOfMercury = "mmHg"
    case hectopascals = "hPa"
}

// MARK: - UnitConvertible Protocol

/// A generic protocol for converting and formatting metric/imperial weather units.
protocol UnitConvertible {
    associatedtype Unit: RawRepresentable where Unit.RawValue == String
    var metricValue: Double { get }
    var imperialValue: Double { get }

    /// Returns a formatted string using the provided unit and decimal precision.
    func formattedValue(for unit: Unit, decimals: Int) -> String
}

extension UnitConvertible {
    /// Converts a unit string to a typed unit and formats the value; falls back to a default.
    func formatted(for unit: String, defaultUnit: Unit, decimals: Int = 0) -> String {
        guard let validUnit = Unit(rawValue: unit) else {
            return formattedValue(for: defaultUnit, decimals: decimals)
        }
        return formattedValue(for: validUnit, decimals: decimals)
    }
}

// MARK: - Implementations for Units

/// Temperature unit converter and formatter.
struct Temperature: UnitConvertible {
    typealias Unit = TemperatureUnit
    let metricValue: Double
    let imperialValue: Double

    func formattedValue(for unit: TemperatureUnit, decimals: Int) -> String {
        let value = unit == .celsius ? metricValue : imperialValue
        return String(format: "%.\(decimals)f°%@", value, unit.rawValue)
    }
}

/// Wind speed unit converter and formatter.
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

/// Pressure unit converter and formatter.
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

/// Utility class for formatting and converting weather-related data like wind, pressure, temperature, and dates.
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

    // MARK: - Wind and Pressure Formatting

    /// Returns a formatted wind speed string based on user unit preference.
    static func formattedWindSpeed(speedKph: Double, speedMph: Double, unit: String) -> String {
        let wind = WindSpeed(metricValue: speedKph, imperialValue: speedMph)
        return wind.formatted(for: unit, defaultUnit: .kilometersPerHour)
    }

    /// Returns a formatted pressure string based on user unit preference.
    static func formattedPressure(pressureMb: Double, pressureIn: Double, unit: String) -> String {
        let pressure = Pressure(metricValue: pressureMb, imperialValue: pressureIn)
        return pressure.formatted(for: unit, defaultUnit: .hectopascals)
    }

    // MARK: - Time Formatting

    /// Converts API date string to `HH:mm` time format.
    static func formatToTime(_ dateString: String) -> String {
        guard let date = inputFormatter.date(from: dateString) else {
            return "--:--"
        }
        return timeFormatter.string(from: date)
    }

    /// Converts API date string to full day name and short date format (e.g., "Tuesday, 28 Jul").
    static func formatToDayAndDate(_ dateString: String) -> String? {
        guard let date = inputFormatter.date(from: dateString) else { return nil }
        return dayDateFormatter.string(from: date)
    }

    /// Extracts time from a local time string formatted as `"yyyy-MM-dd HH:mm"`.
    static func formatLocalTime(from localTime: String) -> String {
        let components = localTime.split(separator: " ")
        return components.last.map { String($0) } ?? "--:--"
    }

    // MARK: - Image Mapping

    /// Resolves appropriate weather image name based on condition code and day/night state.
    static func getImageName(forConditionCode code: String, isDay: Int) -> String {
        if isDay == 0 {
            let nightImageName = "\(code)_night"
            return UIImage(named: nightImageName) != nil ? nightImageName : code
        }
        return code
    }

    // MARK: - Temperature Formatting

    private static func formatTemperature(tempC: Double, tempF: Double, unit: String, decimals: Int = 0) -> String {
        let temp = Temperature(metricValue: tempC, imperialValue: tempF)
        return temp.formatted(for: unit, defaultUnit: .celsius, decimals: decimals)
    }

    // MARK: - Convenience Formatters for WeatherData

    /// Returns the current temperature from weather data in user-selected units.
    static func formattedTemperature(from data: WeatherData, unit: String) -> String {
        return formatTemperature(tempC: data.current.temp_c, tempF: data.current.temp_f, unit: unit)
    }

    /// Returns the high temperature forecast for the current day.
    static func highTemperature(from data: WeatherData, unit: String) -> String {
        guard let day = data.forecast.forecastday.first?.day else { return "--" }
        return formatTemperature(tempC: day.maxtemp_c, tempF: day.maxtemp_f, unit: unit)
    }

    /// Returns the low temperature forecast for the current day.
    static func lowTemperature(from data: WeatherData, unit: String) -> String {
        guard let day = data.forecast.forecastday.first?.day else { return "--" }
        return formatTemperature(tempC: day.mintemp_c, tempF: day.mintemp_f, unit: unit)
    }

    /// Formats any arbitrary temperature values in selected units.
    static func formattedTemperature(tempC: Double, tempF: Double, unit: String) -> String {
        return formatTemperature(tempC: tempC, tempF: tempF, unit: unit)
    }
}
