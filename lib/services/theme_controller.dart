import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

// ── Appearance enums ──

enum SerenaThemeStyle {
  lavanda('Lavanda', Color(0xFF7C6FF0), Color(0xFF14121C)),
  azul('Azul', Color(0xFF5B8DEF), Color(0xFF0F1720)),
  verde('Verde', Color(0xFF4CAF50), Color(0xFF0F1A14)),
  rosa('Rosa', Color(0xFFE91E8C), Color(0xFF1C0F1A)),
  amoled('Negro', Color(0xFF6C5CE7), Color(0xFF000000));

  const SerenaThemeStyle(this.label, this.seedColor, this.darkScaffold);
  final String label;
  final Color seedColor;
  final Color darkScaffold;
}

enum SerenaBackground {
  minimalista('Minimalista', Icons.crop_square_rounded),
  bosque('Bosque', Icons.forest_outlined),
  montanas('Montañas', Icons.terrain_rounded),
  lluvia('Lluvia', Icons.grain_rounded),
  noche('Noche', Icons.nights_stay_rounded),
  aurora('Aurora', Icons.auto_awesome_outlined),
  galaxia('Galaxia', Icons.public_outlined);

  const SerenaBackground(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum SerenaFont {
  inter('Inter', 'Inter', 'Inter'),
  poppins('Poppins', 'Poppins', 'Poppins'),
  roboto('Roboto', 'Roboto', 'Roboto'),
  nunito('Nunito', 'Nunito', 'Nunito');

  const SerenaFont(this.label, this.displayFamily, this.bodyFamily);
  final String label;
  final String displayFamily;
  final String bodyFamily;
}

// Legacy compat
SerenaThemeStyle _parseThemeStyle(String? value) {
  return SerenaThemeStyle.values.firstWhere(
    (s) => s.name == value,
    orElse: () => SerenaThemeStyle.lavanda,
  );
}

SerenaThemeStyle _migrateFromThemeColor(String? label) {
  return switch (label) {
    'Azul' => SerenaThemeStyle.azul,
    'Verde' => SerenaThemeStyle.verde,
    'Rosa' => SerenaThemeStyle.rosa,
    'Naranja' => SerenaThemeStyle.rosa,
    _ => SerenaThemeStyle.lavanda,
  };
}

SerenaBackground _parseBackground(String? value) {
  return SerenaBackground.values.firstWhere(
    (b) => b.name == value,
    orElse: () => SerenaBackground.minimalista,
  );
}

SerenaFont _parseFont(String? value) {
  return SerenaFont.values.firstWhere(
    (f) => f.name == value,
    orElse: () => SerenaFont.inter,
  );
}

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  SerenaThemeStyle _themeStyle = SerenaThemeStyle.lavanda;
  SerenaBackground _background = SerenaBackground.minimalista;
  SerenaFont _font = SerenaFont.inter;

  ThemeMode get mode => _mode;
  SerenaThemeStyle get themeStyle => _themeStyle;
  Color get seedColor => _themeStyle.seedColor;
  SerenaBackground get background => _background;
  SerenaFont get font => _font;

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

    final savedStyle = await prefs.themeStyle;
    if (savedStyle != null && savedStyle.isNotEmpty) {
      _themeStyle = _parseThemeStyle(savedStyle);
    } else {
      final legacy = await SharedPreferences.getInstance();
      final legacyColor = legacy.getString('theme_color_v1');
      if (legacyColor != null && legacyColor.isNotEmpty) {
        _themeStyle = _migrateFromThemeColor(legacyColor);
        await prefs.setThemeStyle(_themeStyle.name);
      }
    }

    final savedBg = await prefs.background;
    if (savedBg != null && savedBg.isNotEmpty) {
      _background = _parseBackground(savedBg);
    }

    final savedFont = await prefs.font;
    if (savedFont != null && savedFont.isNotEmpty) {
      _font = _parseFont(savedFont);
    }

    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    final newMode = enabled ? ThemeMode.dark : ThemeMode.light;
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
    await AppPreferences().setDarkMode(enabled);
  }

  Future<void> setThemeStyle(SerenaThemeStyle value) async {
    if (_themeStyle == value) return;
    _themeStyle = value;
    notifyListeners();
    await AppPreferences().setThemeStyle(value.name);
  }

  Future<void> setBackground(SerenaBackground value) async {
    if (_background == value) return;
    _background = value;
    notifyListeners();
    await AppPreferences().setBackground(value.name);
  }

  Future<void> setFont(SerenaFont value) async {
    if (_font == value) return;
    _font = value;
    notifyListeners();
    await AppPreferences().setFont(value.name);
  }
}
