// utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const primaryBlue = Color(0xFF1E88E5);
  static const accentBlue = Color(0xFF64B5F6);
  static const darkBg = Color(0xFF0A1628);
  static const darkSurface = Color(0xFF12213A);
  static const darkCard = Color(0xFF1A2F4A);
  static const darkCardLight = Color(0xFF1E3555);
  static const lightBg = Color(0xFFF0F4FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFE8F0FF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0C4DE);
  static const successGreen = Color(0xFF4CAF50);
  static const warningAmber = Color(0xFFFFC107);
  static const errorRed = Color(0xFFF44336);
  static const rainBlue = Color(0xFF1565C0);
  static const snowWhite = Color(0xFFE3F2FD);

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: darkSurface,
        background: darkBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            letterSpacing: -1.5),
        displayMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5),
        displaySmall:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        headlineLarge:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        headlineMedium:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        headlineSmall:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        titleSmall:
            TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: textSecondary),
        bodySmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: lightSurface,
        background: lightBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1A2F4A),
      ),
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Color(0xFF1A2F4A),
            fontWeight: FontWeight.w300,
            letterSpacing: -1.5),
        displayMedium: TextStyle(
            color: Color(0xFF1A2F4A),
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5),
        headlineLarge:
            TextStyle(color: Color(0xFF1A2F4A), fontWeight: FontWeight.w600),
        headlineMedium:
            TextStyle(color: Color(0xFF1A2F4A), fontWeight: FontWeight.w600),
        titleLarge:
            TextStyle(color: Color(0xFF1A2F4A), fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(color: Color(0xFF1A2F4A), fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Color(0xFF1A2F4A)),
        bodyMedium: TextStyle(color: Color(0xFF4A6080)),
        bodySmall: TextStyle(color: Color(0xFF4A6080)),
        labelLarge:
            TextStyle(color: Color(0xFF1A2F4A), fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: Color(0xFF4A6080)),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: const Color(0x1A1E88E5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
            color: Color(0xFF1A2F4A),
            fontSize: 18,
            fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: Color(0xFF1A2F4A)),
      ),
    );
  }
}
