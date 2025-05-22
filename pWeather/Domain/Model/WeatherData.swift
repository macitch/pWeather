/*
*  File: WeatherData.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 02.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import CoreLocation

// MARK: - Location Metadata

/// Represents the geographic and time-related metadata for a location.
struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tz_id: String
    let localtime_epoch: Int
    let localtime: String
}

// MARK: - Condition

/// Describes weather condition details like description, icon, and condition code.
struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}

// MARK: - Air Quality

/// Represents pollutant levels and regional air quality indexes.
struct AirQuality: Codable {
    let co: Double?
    let no2: Double?
    let o3: Double?
    let so2: Double?
    let pm2_5: Double?
    let pm10: Double?
    let us_epa_index: Int?
    let gb_defra_index: Int?

    enum CodingKeys: String, CodingKey {
        case co, no2, o3, so2, pm2_5 = "pm2_5", pm10
        case us_epa_index = "us-epa-index"
        case gb_defra_index = "gb-defra-index"
    }
}

// MARK: - Current Weather

/// Represents the current weather conditions at the location.
struct Current: Codable {
    let last_updated_epoch: Int
    let last_updated: String
    let temp_c: Double
    let temp_f: Double
    let is_day: Int
    let condition: Condition
    let wind_mph: Double
    let wind_kph: Double
    let wind_degree: Int
    let wind_dir: String
    let pressure_mb: Double
    let pressure_in: Double
    let precip_mm: Double
    let precip_in: Double
    let humidity: Int
    let cloud: Int
    let feelslike_c: Double
    let feelslike_f: Double
    let vis_km: Double
    let vis_miles: Double
    let uv: Double
    let gust_mph: Double
    let gust_kph: Double
    let air_quality: AirQuality
}

// MARK: - Daily Forecast

/// Daily aggregated weather data (used in forecasts).
struct Day: Codable {
    let maxtemp_c: Double
    let maxtemp_f: Double
    let mintemp_c: Double
    let mintemp_f: Double
    let avgtemp_c: Double
    let avgtemp_f: Double
    let maxwind_mph: Double
    let maxwind_kph: Double
    let totalprecip_mm: Double
    let totalprecip_in: Double
    let avgvis_km: Double
    let avgvis_miles: Double
    let avghumidity: Int
    let daily_will_it_rain: Int
    let daily_chance_of_rain: Int
    let daily_will_it_snow: Int
    let daily_chance_of_snow: Int
    let condition: Condition
    let uv: Double
}

// MARK: - Astronomical Data

/// Represents sunrise, sunset, moon phase and illumination for a forecast day.
struct Astro: Codable {
    let sunrise: String
    let sunset: String
    let moonrise: String
    let moonset: String
    let moon_phase: String
    let moon_illumination: String

    enum CodingKeys: String, CodingKey {
        case sunrise, sunset, moonrise, moonset, moon_phase, moon_illumination
    }

    /// Custom decoding to handle `moon_illumination` being either a string or numeric value.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sunrise = try container.decode(String.self, forKey: .sunrise)
        sunset = try container.decode(String.self, forKey: .sunset)
        moonrise = try container.decode(String.self, forKey: .moonrise)
        moonset = try container.decode(String.self, forKey: .moonset)
        moon_phase = try container.decode(String.self, forKey: .moon_phase)

        do {
            moon_illumination = try container.decode(String.self, forKey: .moon_illumination)
        } catch DecodingError.typeMismatch {
            if let numeric = try? container.decode(Double.self, forKey: .moon_illumination) {
                moon_illumination = String(Int(numeric))
            } else {
                throw DecodingError.typeMismatch(
                    String.self,
                    DecodingError.Context(
                        codingPath: [CodingKeys.moon_illumination],
                        debugDescription: "Expected String or Double for moon_illumination"
                    )
                )
            }
        }
    }
}

// MARK: - Hourly Forecast

/// Hourly forecast data for a given day.
struct Hour: Codable {
    let time_epoch: Int
    let time: String
    let temp_c: Double
    let temp_f: Double
    let is_day: Int
    let condition: Condition
    let wind_mph: Double
    let wind_kph: Double
}

// MARK: - Forecast Aggregates

/// One full forecast day, including daily/astro/hourly.
struct ForecastDay: Codable {
    let date: String
    let date_epoch: Int
    let day: Day
    let astro: Astro
    let hour: [Hour]
}

/// Forecast container containing multiple forecast days.
struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

// MARK: - Alerts

/// Describes a single weather alert.
struct Alert: Codable {
    let headline: String
    let category: String
    let event: String
    let effective: String
    let expires: String
    let desc: String
    let instruction: String
}

/// Container for alert data returned by the API.
struct Alerts: Codable {
    let alert: [Alert]
}

// MARK: - Full Weather Model

/// Top-level container representing the full weather response from the API.
struct WeatherData: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
    let alerts: Alerts
}

// MARK: - Identifiable Conformance

extension WeatherData: Identifiable {
    /// A stable identifier used for rendering or caching.
    var id: String {
        return location.name + "\(location.lat)\(location.lon)"
    }
}
