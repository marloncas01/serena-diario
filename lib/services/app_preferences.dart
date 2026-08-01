import 'package:shared_preferences/shared_preferences.dart';

/// Stores lightweight UI preferences separately from journal data.
class AppPreferences {
  static const _onboardingKey = 'onboarding_complete_v1';
  static const _setupKey = 'setup_complete_v1';
  static const _darkModeKey = 'dark_mode_v1';
  static const _seedColorKey = 'seed_color_v1';
  static const _themeStyleKey = 'theme_style_v1';
  static const _backgroundKey = 'background_v1';
  static const _fontKey = 'font_v1';
  static const _draftNoteKey = 'journal_draft_note_v1';
  static const _draftTagsKey = 'journal_draft_tags_v1';
  static const _draftMoodKey = 'journal_draft_mood_v1';

  SharedPreferences? _cached;

  Future<SharedPreferences> get _prefs async {
    _cached ??= await SharedPreferences.getInstance();
    return _cached!;
  }

  Future<bool> get hasCompletedOnboarding async =>
      (await _prefs).getBool(_onboardingKey) ?? false;
  Future<void> completeOnboarding() async =>
      (await _prefs).setBool(_onboardingKey, true);
  Future<bool> get hasCompletedSetup async =>
      (await _prefs).getBool(_setupKey) ?? false;
  Future<void> completeSetup() async =>
      (await _prefs).setBool(_setupKey, true);
  Future<bool?> get darkMode async =>
      (await _prefs).getBool(_darkModeKey);
  Future<void> setDarkMode(bool enabled) async =>
      (await _prefs).setBool(_darkModeKey, enabled);

  Future<int?> get seedColorValue async =>
      (await _prefs).getInt(_seedColorKey);

  Future<void> setSeedColorValue(int value) async =>
      (await _prefs).setInt(_seedColorKey, value);

  Future<String?> get themeStyle async =>
      (await _prefs).getString(_themeStyleKey);
  Future<void> setThemeStyle(String value) async =>
      (await _prefs).setString(_themeStyleKey, value);

  Future<String?> get background async =>
      (await _prefs).getString(_backgroundKey);
  Future<void> setBackground(String value) async =>
      (await _prefs).setString(_backgroundKey, value);

  Future<String?> get font async =>
      (await _prefs).getString(_fontKey);
  Future<void> setFont(String value) async =>
      (await _prefs).setString(_fontKey, value);
  Future<Map<String, String>> get draft async {
    final preferences = await _prefs;
    return {
      'note': preferences.getString(_draftNoteKey) ?? '',
      'tags': preferences.getString(_draftTagsKey) ?? '',
      'mood': preferences.getString(_draftMoodKey) ?? 'Normal',
    };
  }

  Future<void> saveDraft({
    required String note,
    required String tags,
    required String mood,
  }) async {
    final preferences = await _prefs;
    await preferences.setString(_draftNoteKey, note);
    await preferences.setString(_draftTagsKey, tags);
    await preferences.setString(_draftMoodKey, mood);
  }

  Future<void> clearDraft() async {
    final preferences = await _prefs;
    await preferences.remove(_draftNoteKey);
    await preferences.remove(_draftTagsKey);
    await preferences.remove(_draftMoodKey);
  }
}
