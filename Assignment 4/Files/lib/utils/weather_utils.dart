import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherUtils {
  static String formatTime(int timestamp, {int timezone = 0}) {
    final dt = DateTime.fromMillisecondsSinceEpoch((timestamp + timezone) * 1000, isUtc: true);
    return DateFormat('h:mm a').format(dt);
  }

  static String formatDay(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('EEE').format(dt);
  }

  static String formatFullDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('MMM d').format(dt);
  }

  static String formatHour(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('ha').format(dt).toLowerCase();
  }

  static String formatDateTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('EEE, MMM d · h:mm a').format(dt);
  }

  static String getWeatherIconUrl(String icon) {
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }

  static Color getWeatherColor(String main, bool isDark) {
    switch (main.toLowerCase()) {
      case 'clear':
        return isDark ? const Color(0xFF1A3A5C) : const Color(0xFF2196F3);
      case 'clouds':
        return isDark ? const Color(0xFF2D3748) : const Color(0xFF607D8B);
      case 'rain':
      case 'drizzle':
        return isDark ? const Color(0xFF1A2744) : const Color(0xFF1565C0);
      case 'thunderstorm':
        return isDark ? const Color(0xFF1A1A2E) : const Color(0xFF37474F);
      case 'snow':
        return isDark ? const Color(0xFF2C3E50) : const Color(0xFF90A4AE);
      case 'mist':
      case 'fog':
      case 'haze':
        return isDark ? const Color(0xFF2D3748) : const Color(0xFF78909C);
      default:
        return isDark ? const Color(0xFF1A3A5C) : const Color(0xFF2196F3);
    }
  }

  static List<Color> getWeatherGradient(String main, bool isDark, {bool isNight = false}) {
    if (isNight) {
      switch (main.toLowerCase()) {
        case 'rain':
        case 'drizzle':
          return [const Color(0xFF0D1B2A), const Color(0xFF1B2A3B)];
        case 'thunderstorm':
          return [const Color(0xFF0A0A1A), const Color(0xFF1A1A2E)];
        case 'snow':
          return [const Color(0xFF1A2030), const Color(0xFF2A3040)];
        case 'clear':
          return [const Color(0xFF0D1B3E), const Color(0xFF162447)];
        default:
          return [const Color(0xFF0D1B2A), const Color(0xFF1B2A3B)];
      }
    }
    switch (main.toLowerCase()) {
      case 'clear':
        return [const Color(0xFF1E88E5), const Color(0xFF42A5F5), const Color(0xFF64B5F6)];
      case 'clouds':
        return [const Color(0xFF546E7A), const Color(0xFF78909C), const Color(0xFF90A4AE)];
      case 'rain':
      case 'drizzle':
        return [const Color(0xFF0D47A1), const Color(0xFF1565C0), const Color(0xFF1976D2)];
      case 'thunderstorm':
        return [const Color(0xFF212121), const Color(0xFF37474F), const Color(0xFF455A64)];
      case 'snow':
        return [const Color(0xFF607D8B), const Color(0xFF90A4AE), const Color(0xFFB0BEC5)];
      case 'mist':
      case 'fog':
      case 'haze':
        return [const Color(0xFF546E7A), const Color(0xFF607D8B), const Color(0xFF78909C)];
      default:
        return [const Color(0xFF1E88E5), const Color(0xFF42A5F5)];
    }
  }

  static String getWindDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((degrees + 22.5) / 45).floor() % 8];
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String getAqiLabel(int aqi) {
    switch (aqi) {
      case 1: return 'Good';
      case 2: return 'Fair';
      case 3: return 'Moderate';
      case 4: return 'Poor';
      case 5: return 'Very Poor';
      default: return 'Unknown';
    }
  }

  static Color getAqiColor(int aqi) {
    switch (aqi) {
      case 1: return const Color(0xFF4CAF50);
      case 2: return const Color(0xFF8BC34A);
      case 3: return const Color(0xFFFFC107);
      case 4: return const Color(0xFFFF9800);
      case 5: return const Color(0xFFF44336);
      default: return Colors.grey;
    }
  }

  static String getUvLabel(double uvi) {
    if (uvi < 3) return 'Low';
    if (uvi < 6) return 'Moderate';
    if (uvi < 8) return 'High';
    if (uvi < 11) return 'Very High';
    return 'Extreme';
  }

  static Color getUvColor(double uvi) {
    if (uvi < 3) return const Color(0xFF4CAF50);
    if (uvi < 6) return const Color(0xFFFFC107);
    if (uvi < 8) return const Color(0xFFFF9800);
    if (uvi < 11) return const Color(0xFFF44336);
    return const Color(0xFF9C27B0);
  }

  static bool isNightTime(int sunrise, int sunset) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now < sunrise || now > sunset;
  }

  static double getSunProgress(int sunrise, int sunset) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (now <= sunrise) return 0.0;
    if (now >= sunset) return 1.0;
    return (now - sunrise) / (sunset - sunrise);
  }
}
