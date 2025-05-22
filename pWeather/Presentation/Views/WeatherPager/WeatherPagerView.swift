//
//  WeatherPagerView.swift
//  pWeather
//
//  Created by Petrit Vosha on 14.04.2025.
//

import SwiftUI

struct WeatherPagerView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var locationViewModel: LocationViewModel

    @State private var selectedIndex = 0
    @State private var loadedCities: [CityInfo] = []
    @State private var weatherCache: [String: WeatherData] = [:]

    var body: some View {
        VStack {
            TabView(selection: $selectedIndex) {
                ForEach(Array(loadedCities.enumerated()), id: \.1.id) { index, city in
                    WeatherView(
                        city: city,
                        weatherData: weatherCache[city.id],
                        onAppear: {
                            loadWeather(for: city)
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .onAppear(perform: prepareCities)
        }
    }

    private func prepareCities() {
        var cities: [CityInfo] = []

        if let loc = locationManager.userLocation {
            let current = CityInfo(
                name: "Current Location",
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                isCurrent: true
            )
            cities.append(current)
        }

        // Add saved cities after current location
        cities.append(contentsOf: locationViewModel.savedCities)

        loadedCities = cities
    }

    private func loadWeather(for city: CityInfo) {
        guard weatherCache[city.id] == nil else { return }

        Task {
            do {
                let weather: WeatherData

                if city.isCurrent {
                    weather = try await AppDependencies.shared.weatherManager.fetchWeatherByCoordinates(
                        latitude: city.latitude,
                        longitude: city.longitude
                    )
                } else {
                    weather = try await AppDependencies.shared.weatherManager.fetchWeatherByCityName(
                        city: city.name
                    )
                }

                await MainActor.run {
                    weatherCache[city.id] = weather
                    weatherViewModel.updateWeatherData(weather) // cache only last viewed
                }
            } catch {
                print("⚠️ Failed to load weather for \(city.name): \(error)")
            }
        }
    }
}
