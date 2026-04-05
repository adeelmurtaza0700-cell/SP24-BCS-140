import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.accentIndex,
    required this.notificationSound,
  });

  final ThemeMode themeMode;
  final int accentIndex;
  final String notificationSound;

  static const palette = <Color>[
    Color(0xFF1D6F5F),
    Color(0xFF7A4DFF),
    Color(0xFFE86F2C),
    Color(0xFF0077B6),
  ];

  Color get accentColor => palette[accentIndex % palette.length];

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? accentIndex,
    String? notificationSound,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentIndex: accentIndex ?? this.accentIndex,
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }

  factory AppSettings.fromMap(Map<String, Object?> map) {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == map['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      accentIndex: map['accentIndex'] as int? ?? 0,
      notificationSound: map['notificationSound'] as String? ?? 'default',
    );
  }

  factory AppSettings.defaults() {
    return const AppSettings(
      themeMode: ThemeMode.system,
      accentIndex: 0,
      notificationSound: 'default',
    );
  }
}
