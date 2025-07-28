# 🌤️ pWeather – SwiftUI Weather App

**pWeather** is a beautifully designed, SwiftUI-based weather app inspired by Apple's native Weather app. It supports light/dark themes, custom units, location-based weather, and a rich user experience with smooth transitions, detailed forecasts, and offline support.

---
## 📸 Screenshots

<table>
<tr>
<td><img src="https://github.com/user-attachments/assets/41821c20-474b-484e-8722-7e346dad83d0" width="250"/></td>
<td><img src="https://github.com/user-attachments/assets/205b8215-c5db-4fd9-ba28-7a65b7a36eff" width="250"/></td>
</tr>
</table>

## ✨ Features

- 📍 **Current Location & Saved Cities**  
  View weather details for your current location and a custom list of saved cities.

- 🌦 **7-Day & Hourly Forecasts**  
  Displayed in a scrollable, card-based UI with real-time temperature, wind, pressure, humidity, and UV data.

- 🎨 **Dynamic Theming**  
  Supports Light, Dark, and System modes with semantic colors and custom typography.

- 📊 **Unit Customization**  
  Choose preferred units for temperature (°C/°F), wind speed (km/h, mph, m/s), and pressure (hPa, mmHg).

- 💾 **Persistence via UserDefaults**  
  Cities and user preferences are stored locally and automatically restored.

- 🔄 **Pull-to-Refresh & Live Updates**  
  Ensure your data stays fresh with manual refresh and background updates.

---

## 🧱 Tech Stack

- **SwiftUI** – Declarative UI framework
- **Combine** – State management and bindings
- **CoreLocation** – Location services
- **MapKit** – For map rendering
- **Lottie** – For smooth animations (e.g., loading states)
- **WeatherAPI.com** – Forecast data via REST API

---

## 🧰 Project Structure

```text
pWeather/
├── Models/           # Codable data models (WeatherData, Forecast, Location, etc.)
├── ViewModels/       # ObservableObject classes for weather, city list, location
├── Views/            # All SwiftUI views and UI components
├── Data/             # Persistence (UserDefaultsService, preview data)
├── Domain/           # Services (WeatherManager, LocationManager, etc.)
├── Shared/           # UI Extensions, Utilities, Colors, Fonts
└── Assets/           # App icon, Lottie animations, and weather icons
```
---

## ⚙️ Setup Instructions

1. Clone the repository:
   ```
   git clone [https://github.com/macithc/pWeather.git](https://github.com/macitch/pWeather.git)
   cd pweather
   ```

2. Open the project in Xcode:
   ```
   open pWeather.xcodeproj
   ```
3. Install Lottie if using Swift Package Manager:
   ```
   .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.3.0")
   ```

4. Add your API key from [https://www.weatherapi.com](https://www.weatherapi.com) to APIConfig.swift:
   ```
   static let apiKey = "YOUR_API_KEY"
   ```
5.	Run the app on a **simulator** or **device**.

## 🧪 Testing Preview Data

- The file weatherData.json contains bundled preview data.
-	Modify or extend it to simulate API results in offline mode.

## 🛠 Customization
-	🎨 Fonts and Colors: Update AppFont.swift and AppColors.swift.
-	📍 Saved cities logic is handled by AppSettings.swift and persisted via UserDefaultsService.
-	🧪 Add .PreviewProvider entries to quickly preview any view in light/dark mode.

## 📄 License
MIT License. See the [LICENSE](https://raw.githubusercontent.com/macitch/pWeather/refs/heads/main/LICENSE) for details.

## 🙌 Acknowledgements
-	Weather data powered by **[WeatherAPI](https://www.weatherapi.com/)**
- Animation support via **[Lottie](https://github.com/airbnb/lottie-ios)** by Airbnb

## 🚀 TODO
- Offline caching
- Air quality breakdown
- Advanced charts (humidity, UV, pressure)
- iPad layout support


