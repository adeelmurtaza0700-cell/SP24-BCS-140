import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  static const _themeModeKey = 'themeMode';
  static const _accentIndexKey = 'accentIndex';
  static const _notificationSoundKey = 'notificationSound';

  Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppSettings.fromMap({
      'themeMode':
          preferences.getString(_themeModeKey) ?? AppSettings.defaults().themeMode.name,
      'accentIndex': preferences.getInt(_accentIndexKey) ?? 0,
      'notificationSound':
          preferences.getString(_notificationSoundKey) ?? 'default',
    });
  }

  Future<void> save(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, settings.themeMode.name);
    await preferences.setInt(_accentIndexKey, settings.accentIndex);
    await preferences.setString(
      _notificationSoundKey,
      settings.notificationSound,
    );
  }
}
