import 'package:flutter/material.dart';

class AppTheme {
  // Gradient colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFF43E97B);
  static const Color bgDark = Color(0xFF1A1A2E);
  static const Color bgCard = Color(0xFF16213E);
  static const Color surface = Color(0xFF0F3460);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0CC);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDark, Color(0xFF16213E), Color(0xFF0F3460)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primary, secondary],
  );

  static const LinearGradient correctGradient = LinearGradient(
    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
  );

  static const LinearGradient highGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );

  static const LinearGradient lowGradient = LinearGradient(
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
      );
}