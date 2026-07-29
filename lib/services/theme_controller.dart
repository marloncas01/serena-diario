import 'package:flutter/material.dart';

import 'app_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  Color _seedColor = const Color(0xFF7562B4);

  ThemeMode get mode => _mode;
  Color get seedColor => _seedColor;

  Future<void> initialize() async {
    final prefs = AppPreferences();
    final darkMode = await prefs.darkMode;
    if (darkMode == null) {
      final platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _mode = platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    } else {
      _mode = darkMode ? ThemeMode.dark : ThemeMode.light;
    }

    final savedColor = await prefs.seedColorValue;
    if (savedColor != null) _seedColor = Color(savedColor);

    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _mode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await AppPreferences().setDarkMode(enabled);
  }

  Future<void> updateSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();
    await AppPreferences().setSeedColorValue(color.toARGB32());
  }
}
