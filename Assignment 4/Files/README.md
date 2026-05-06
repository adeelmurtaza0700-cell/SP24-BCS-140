# Aura Weather — Flutter (nabeel/)

A complete Flutter conversion of the Aura Weather Expo app. Every feature from the original is replicated using native Flutter/Dart.

## Features

| Feature | Details |
|---|---|
| **Current weather hero** | Large temp, condition icon, H/L, feels-like |
| **Hourly forecast** | 24-hour horizontal scroll with precip% |
| **7-day forecast** | Daily H/L with animated temp bar |
| **Precipitation chart** | fl_chart line chart for 24h rain probability |
| **Sun arc** | Sunrise/sunset arc with animated sun position |
| **UV index card** | Gradient bar with pointer, category label |
| **Wind compass** | Custom-painted dial with cardinal directions |
| **Details grid** | Humidity, pressure, visibility, cloud cover |
| **AQI badge** | Air quality index when available |
| **Compare cities** | 2×2 grid comparing up to 4 cities |
| **Animated background** | Gradient background transitions with weather |
| **Map tab** | flutter_map (OpenStreetMap) + RainViewer radar animation |
| **News tab** | Google News RSS via API server, pull-to-refresh |
| **Saved locations** | Persist with SharedPreferences |
| **Settings** | °C/°F, km/h/mph/m/s, notifications, haptics |
| **Search** | Photon autocomplete with recent history |

## Architecture

```
lib/
├── main.dart                  ← App entry, providers, navigation shell
├── theme/
│   ├── app_theme.dart         ← Colors, text styles, ThemeData
│   └── weather_codes.dart     ← Code → emoji/description/gradient helpers
├── models/
│   ├── weather.dart           ← WeatherBundle, CurrentWeather, Hourly, Daily
│   ├── location.dart          ← SavedLocation, PlaceInfo
│   └── news.dart              ← NewsArticle + timeAgo helper
├── services/
│   ├── weather_service.dart   ← fetchWeather, searchLocations, reverseGeocode
│   ├── news_service.dart      ← fetchNews (API server)
│   └── location_service.dart  ← GPS via geolocator
├── providers/
│   ├── weather_provider.dart  ← Selected location, bundle, saved list
│   └── settings_provider.dart ← Units, notifications, haptics
├── screens/
│   ├── home_screen.dart       ← Main weather scroll
│   ├── map_screen.dart        ← flutter_map + radar layer picker
│   ├── news_screen.dart       ← Full news list
│   ├── saved_screen.dart      ← Saved locations manager
│   └── settings_screen.dart   ← Settings controls
└── widgets/
    ├── animated_background.dart
    ├── current_hero.dart
    ├── hourly_forecast.dart
    ├── daily_forecast.dart
    ├── weather_details.dart
    ├── uv_card.dart
    ├── wind_compass.dart
    ├── sun_arc.dart
    ├── rain_chart.dart
    ├── compare_section.dart
    ├── search_sheet.dart
    ├── news_card.dart
    └── glass_card.dart
```

## API Server

The Flutter app points to the same API server as the Expo app. Update `_kApiBase` in `lib/services/weather_service.dart` and `lib/services/news_service.dart` with your deployment URL:

```dart
const String _kApiBase = 'https://YOUR-REPLIT-DOMAIN.replit.dev';
```

## Running Locally

```bash
# Install Flutter SDK (https://flutter.dev/docs/get-started/install)
cd nabeel
flutter pub get
flutter run          # connects to a device/emulator
flutter run -d chrome  # web preview
```

## Key Packages

| Package | Purpose |
|---|---|
| `provider` | State management (WeatherProvider, SettingsProvider) |
| `http` | REST calls to API server |
| `flutter_map` | OpenStreetMap tile rendering |
| `fl_chart` | Precipitation probability line chart |
| `geolocator` | GPS location |
| `shared_preferences` | Persist saved locations + settings |
| `url_launcher` | Open news articles in browser |
| `intl` | Date/time formatting |
| `shimmer` | Loading skeleton animations |
