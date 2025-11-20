# Weather App

Built with Flutter & BLoC

A cross-platform Flutter weather application featuring real-time weather data, interactive maps, and forecast visualization. Built with clean architecture and BLoC pattern for scalable state management.

## Features

- **Real-time Weather Data** — Current conditions with temperature, humidity, weather icons, and detailed metrics
- **5-Day Forecast** — Comprehensive daily forecasts with conditions, temperature ranges, and sunrise/sunset times
- **GPS Location Detection** — Automatic location-based weather with permission handling
- **City Search** — Manual search functionality for any city worldwide
- **Interactive Google Maps** — Tap anywhere on the map to view weather for that location
- **Weather Layer Overlays** — OpenWeatherMap precipitation and temperature tile layers
- **Dynamic Marker Updates** — Real-time weather information displayed on map markers
- **Material Design 3** — Modern, responsive UI with smooth animations

## Technical Stack

### State Management
- **Flutter BLoC** for predictable, reactive state management
- Clean separation of business logic from UI
- Testable architecture with well-defined events and states

### Architecture
- **Repository Pattern** — Abstract data layer for easy testing and maintainability
- **Clean Architecture** — Clear separation between data, domain, and presentation layers
- **Dependency Injection** — Decoupled components for better scalability

### APIs & Integration
- **WeatherAPI.com** — Real-time weather data and forecasts
- **OpenWeatherMap** — Map tile overlays for precipitation and temperature layers
- **Google Maps SDK** — Interactive map interface with custom markers

### Performance
- **Optimized Rendering** — Efficient widget rebuilds with BLoC state management
- **Minimal Lag** — Smooth transitions and fast data fetching
- **Responsive UI** — Adapts seamlessly across different screen sizes and orientations

### Platform Support
- Android
- iOS
- Web

## Setup

### Prerequisites
- Flutter 3.24+ (SDK ^3.9.2)
- WeatherAPI.com API key
- Google Maps API key (for Android and iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <https://github.com/poorna-nag/WeatherApp.git>
   cd weatherapp
   ```

2. **Configure API keys**
   - Make an `.env`
   - Add your WeatherAPI.com key: `OWM_API_KEY=your_key`
   - Add OpenWeatherMap key for overlays: `MAP_API_KEY=your_key`
   - Configure Google Maps keys in platform-specific files:
     - Android: `android/app/src/main/res/values/google_maps_api.xml`
     - iOS: `ios/Runner/Info.plist`

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

