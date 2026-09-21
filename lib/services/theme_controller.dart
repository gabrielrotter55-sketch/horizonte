
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HorizonteThemePreference { system, light, dark }

class ThemeController extends ChangeNotifier {
  static const _key = 'horizonte_theme_mode_v1';

  HorizonteThemePreference _preference = HorizonteThemePreference.system;
  bool _loaded = false;

  HorizonteThemePreference get preference => _preference;
  bool get loaded => _loaded;

  ThemeMode get themeMode {
    switch (_preference) {
      case HorizonteThemePreference.system:
        return ThemeMode.system;
      case HorizonteThemePreference.light:
        return ThemeMode.light;
      case HorizonteThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    _preference = HorizonteThemePreference.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HorizonteThemePreference.system,
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> setPreference(HorizonteThemePreference value) async {
    _preference = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}
