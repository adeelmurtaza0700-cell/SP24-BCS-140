import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum TempUnit { celsius, fahrenheit }
enum AppThemeMode { light, dark, auto }
enum LoadState { idle, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  WeatherService? _service;
  String _apiKey = '';

  WeatherData? _currentWeather;
  List<HourlyWeather> _hourlyForecast = [];
  List<DailyForecast> _dailyForecast = [];
  AirQuality? _airQuality;

  // City comparison
  WeatherData? _compareWeather1;
  WeatherData? _compareWeather2;
  List<HourlyWeather> _compareHourly1 = [];
  List<HourlyWeather> _compareHourly2 = [];

  LoadState _loadState = LoadState.idle;
  String _error = '';
  String _currentCity = '';
  List<String> _recentSearches = [];
  List<String> _favorites = [];

  TempUnit _tempUnit = TempUnit.celsius;
  AppThemeMode _themeMode = AppThemeMode.auto;
  bool _useLocation = false;

  // Getters
  WeatherData? get currentWeather => _currentWeather;
  List<HourlyWeather> get hourlyForecast => _hourlyForecast;
  List<DailyForecast> get dailyForecast => _dailyForecast;
  AirQuality? get airQuality => _airQuality;
  WeatherData? get compareWeather1 => _compareWeather1;
  WeatherData? get compareWeather2 => _compareWeather2;
  List<HourlyWeather> get compareHourly1 => _compareHourly1;
  List<HourlyWeather> get compareHourly2 => _compareHourly2;
  LoadState get loadState => _loadState;
  String get error => _error;
  String get currentCity => _currentCity;
  List<String> get recentSearches => _recentSearches;
  List<String> get favorites => _favorites;
  TempUnit get tempUnit => _tempUnit;
  AppThemeMode get themeMode => _themeMode;
  bool get useLocation => _useLocation;
  String get apiKey => _apiKey;
  bool get isLoading => _loadState == LoadState.loading;
  bool get hasData => _loadState == LoadState.loaded && _currentWeather != null;
  bool get hasError => _loadState == LoadState.error;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('api_key') ?? '';
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    _favorites = prefs.getStringList('favorites') ?? [];
    _currentCity = prefs.getString('last_city') ?? 'London';
    final unitStr = prefs.getString('temp_unit') ?? 'celsius';
    _tempUnit = unitStr == 'fahrenheit' ? TempUnit.fahrenheit : TempUnit.celsius;
    final themeStr = prefs.getString('theme_mode') ?? 'auto';
    _themeMode = themeStr == 'light' ? AppThemeMode.light : themeStr == 'dark' ? AppThemeMode.dark : AppThemeMode.auto;

    if (_apiKey.isNotEmpty) {
      _service = WeatherService(apiKey: _apiKey);
      await fetchWeather(_currentCity);
    }
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    _service = WeatherService(apiKey: key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', key);
    notifyListeners();
    if (key.isNotEmpty) await fetchWeather(_currentCity);
  }

  Future<void> fetchWeather(String city) async {
    if (_service == null) return;
    _loadState = LoadState.loading;
    _error = '';
    notifyListeners();

    try {
      _currentWeather = await _service!.getCurrentWeather(city);
      _currentCity = city;
      final lat = _currentWeather!.lat;
      final lon = _currentWeather!.lon;

      final results = await Future.wait([
        _service!.getHourlyForecast(city),
        _service!.getDailyForecast(lat, lon),
        _service!.getAirQuality(lat, lon),
      ]);

      _hourlyForecast = results[0] as List<HourlyWeather>;
      _dailyForecast = results[1] as List<DailyForecast>;
      _airQuality = results[2] as AirQuality;
      _loadState = LoadState.loaded;

      _addRecentSearch(city);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_city', city);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _loadState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> fetchCompareCity(String city, int slot) async {
    if (_service == null) return;
    try {
      if (slot == 1) {
        _compareWeather1 = await _service!.getCurrentWeather(city);
        _compareHourly1 = await _service!.getHourlyForecast(city);
      } else {
        _compareWeather2 = await _service!.getCurrentWeather(city);
        _compareHourly2 = await _service!.getHourlyForecast(city);
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<List<String>> searchCities(String query) async {
    if (_service == null) return [];
    return _service!.searchCities(query);
  }

  void _addRecentSearch(String city) {
    _recentSearches.remove(city);
    _recentSearches.insert(0, city);
    if (_recentSearches.length > 10) _recentSearches = _recentSearches.take(10).toList();
    SharedPreferences.getInstance().then((p) => p.setStringList('recent_searches', _recentSearches));
  }

  void toggleFavorite(String city) {
    if (_favorites.contains(city)) {
      _favorites.remove(city);
    } else {
      _favorites.add(city);
    }
    SharedPreferences.getInstance().then((p) => p.setStringList('favorites', _favorites));
    notifyListeners();
  }

  bool isFavorite(String city) => _favorites.contains(city);

  Future<void> setTempUnit(TempUnit unit) async {
    _tempUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_unit', unit == TempUnit.fahrenheit ? 'fahrenheit' : 'celsius');
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode == AppThemeMode.light ? 'light' : mode == AppThemeMode.dark ? 'dark' : 'auto');
    notifyListeners();
  }

  double convertTemp(double celsius) {
    return _tempUnit == TempUnit.fahrenheit ? celsius * 9 / 5 + 32 : celsius;
  }

  String formatTemp(double celsius) {
    final val = convertTemp(celsius).round();
    return '$val°${_tempUnit == TempUnit.fahrenheit ? 'F' : 'C'}';
  }

  String get tempUnitSymbol => _tempUnit == TempUnit.fahrenheit ? '°F' : '°C';
}
