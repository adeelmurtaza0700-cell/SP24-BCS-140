import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _oneCallUrl = 'https://api.openweathermap.org/data/3.0';

  final String apiKey;

  WeatherService({required this.apiKey});

  Future<WeatherData> getCurrentWeather(String city) async {
    final url = Uri.parse(
      '$_baseUrl/weather?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('City not found: $city');
    } else {
      throw Exception('Failed to fetch weather: ${response.statusCode}');
    }
  }

  Future<WeatherData> getCurrentWeatherByCoords(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch weather: ${response.statusCode}');
    }
  }

  Future<List<HourlyWeather>> getHourlyForecast(String city) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric&cnt=40',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['list'] as List<dynamic>;
      return list.map((e) => HourlyWeather.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch hourly forecast: ${response.statusCode}');
    }
  }

  Future<List<HourlyWeather>> getHourlyForecastByCoords(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&cnt=40',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['list'] as List<dynamic>;
      return list.map((e) => HourlyWeather.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch hourly forecast: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getOneCall(double lat, double lon) async {
    final url = Uri.parse(
      '$_oneCallUrl/onecall?lat=$lat&lon=$lon&appid=$apiKey&units=metric&exclude=minutely,alerts',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // Fallback to free tier forecast
      return {};
    }
  }

  Future<List<DailyForecast>> getDailyForecast(double lat, double lon) async {
    try {
      final oneCallData = await getOneCall(lat, lon);
      if (oneCallData.isNotEmpty && oneCallData.containsKey('daily')) {
        final dailyList = oneCallData['daily'] as List<dynamic>;
        return dailyList
            .take(30)
            .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // Fallback: use 5-day forecast and derive daily data
    final url = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&cnt=40',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['list'] as List<dynamic>;
      return _aggregateDailyFromHourly(list);
    } else {
      throw Exception('Failed to fetch daily forecast: ${response.statusCode}');
    }
  }

  List<DailyForecast> _aggregateDailyFromHourly(List<dynamic> hourlyList) {
    final Map<String, List<dynamic>> grouped = {};
    for (final item in hourlyList) {
      final dt = DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
      final key = '${dt.year}-${dt.month}-${dt.day}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final result = <DailyForecast>[];
    grouped.forEach((key, items) {
      final temps = items.map((e) => (e['main']['temp'] as num).toDouble()).toList();
      final weather = items.first['weather'][0] as Map<String, dynamic>;
      final dtFirst = items.first['dt'] as int;

      result.add(DailyForecast(
        dt: dtFirst,
        tempMin: temps.reduce((a, b) => a < b ? a : b),
        tempMax: temps.reduce((a, b) => a > b ? a : b),
        tempDay: temps[temps.length ~/ 2],
        tempNight: temps.last,
        description: weather['description'] as String,
        icon: weather['icon'] as String,
        main: weather['main'] as String,
        humidity: items.first['main']['humidity'] as int,
        windSpeed: (items.first['wind']['speed'] as num).toDouble(),
        pop: (items.map((e) => (e['pop'] as num?)?.toDouble() ?? 0.0).reduce((a, b) => a > b ? a : b)),
        sunrise: dtFirst,
        sunset: dtFirst + 43200,
        uvi: 0,
      ));
    });

    return result;
  }

  Future<AirQuality> getAirQuality(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return AirQuality.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch air quality: ${response.statusCode}');
    }
  }

  Future<List<String>> searchCities(String query) async {
    if (query.length < 2) return [];
    final url = Uri.parse(
      'https://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(query)}&limit=5&appid=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) {
        final city = e as Map<String, dynamic>;
        final name = city['name'] as String;
        final country = city['country'] as String;
        final state = city['state'] as String? ?? '';
        return state.isNotEmpty ? '$name, $state, $country' : '$name, $country';
      }).toList();
    }
    return [];
  }
}
