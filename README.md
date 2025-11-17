# Weather Planner (Flutter + BLoC)

Lightweight cross-platform weather planner that shows the current conditions, a five-day forecast, and a Google Maps overlay with OpenWeatherMap precipitation/temperature tiles. Built with the BLoC pattern, a simple repository layer, and clean UI primitives so you can focus on the weather domain instead of boilerplate.

## Features

- Current conditions card with icon, temperature, humidity, and quick metrics.
- Scrollable five-day forecast list plus a sparkline-style chart for trend spotting.
- GPS-based lookup with graceful permission handling and manual city search.
- Google Maps screen that overlays OpenWeatherMap precipitation or temperature tiles and surfaces the latest reading for the selected marker.
- Error-aware UX: snackbars for failures, retry flows, and optimistic refresh support.

## Architecture & State Management

- **State management:** `flutter_bloc` with a single `WeatherBloc` controlling the home + map flows. BLoC was chosen for its predictable streams, excellent tooling (BlocObserver, bloc_test), and the team’s stated preference.
- **Domain separation:** A tiny `WeatherRepo` interface hides HTTP/JSON specifics behind strongly typed models. This keeps the BLoC deterministic and easy to mock in tests.
- **Presentation:** Widgets stay dumb. They react to immutable `WeatherState`s and forward user intents via BLoC events (load, search, refresh).
- **Utilities:** Location checks live in `core/utils/location_service.dart`, while the OpenWeather map overlay uses a dedicated `UrlTileProvider`.

## Getting Started

### 1. Tooling

- Flutter 3.24+ (SDK constraint is `^3.9.2`)
- Xcode 15 / Android Studio Iguana (or newer)
- An OpenWeatherMap API key
- A Google Maps SDK key (Android + iOS)

### 2. Configure secrets

1. **OpenWeatherMap**
   - Copy `env.example` → `.env`
   - Fill in `OWM_API_KEY=your_key`
   - The app loads this via `flutter_dotenv` at startup.

2. **Google Maps**
   - Android: edit `android/app/src/main/res/values/google_maps_api.xml` and replace `YOUR_GOOGLE_MAPS_API_KEY`.
   - iOS: edit `ios/Runner/Info.plist` and replace `YOUR_GOOGLE_MAPS_API_KEY` for the `GMSApiKey` entry.
   - (Optional) Use different keys per build type by leveraging Gradle manifest placeholders or XCConfig files.

> Never commit real keys. Prefer `.env` + secure CI secret injection.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
flutter run -d android      # or ios, chrome, macos, etc.
```

- Grant location permissions when prompted to enable GPS lookup.
- Use the search icon to jump to any city.
- Tap the map icon to open the weather layers.

### 5. Tests (optional bonus)

```bash
flutter test
```

The included BLoC tests cover success/error scenarios to keep regressions low.

## Error Handling & Resilience

- Missing API keys → explicit exception with toasts/snackbars.
- Network/HTTP failures → surfaced via `WeatherError` states with retry guidance.
- Location permission denial → descriptive exceptions from `LocationService`.
- Map overlays degrade gracefully when no OpenWeather key is present (toggle disabled, helper text shown).

## Trade-offs & Future Ideas

- The forecast picks every 8th entry from the 3-hour feed to stay simple; upgrading to the One Call API would unlock daily aggregates.
- Repository is HTTP-based; extracting a data source interface would help add caching or Hive persistence later.
- The chart is a custom painter for zero dependencies. A more advanced solution could use `fl_chart` for extra polish.
- Additional tests (widget golden, repository mocks) can be layered on if time permits.

## Verification

Before sharing a build, run the standard quality gates:

```bash
flutter analyze
flutter test
```

Both commands should complete without issues (tested on Flutter 3.24).

## Deliverables Checklist

- ✅ Flutter source with BLoC architecture
- ✅ Google Maps precipitation/temperature overlay
- ✅ Location search + GPS flow
- ✅ README with setup + architecture notes
- ✅ Sample env file (copy before running)

Happy hacking! Let me know if you need help packaging an APK or hosting the web build.
