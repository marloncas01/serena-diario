import 'package:shared_preferences/shared_preferences.dart';

/// Stores lightweight UI preferences separately from journal data.
class AppPreferences {
  static const _onboardingKey = 'onboarding_complete_v1';
  static const _setupKey = 'setup_complete_v1';
  static const _darkModeKey = 'dark_mode_v1';
  static const _seedColorKey = 'seed_color_v1';
  static const _draftNoteKey = 'journal_draft_note_v1';
  static const _draftTagsKey = 'journal_draft_tags_v1';
  static const _draftMoodKey = 'journal_draft_mood_v1';
  Future<bool> get hasCompletedOnboarding async =>
      (await SharedPreferences.getInstance()).getBool(_onboardingKey) ?? false;
  Future<void> completeOnboarding() async =>
      (await SharedPreferences.getInstance()).setBool(_onboardingKey, true);
  Future<bool> get hasCompletedSetup async =>
      (await SharedPreferences.getInstance()).getBool(_setupKey) ?? false;
  Future<void> completeSetup() async =>
      (await SharedPreferences.getInstance()).setBool(_setupKey, true);
  Future<bool?> get darkMode async =>
      (await SharedPreferences.getInstance()).getBool(_darkModeKey);
  Future<void> setDarkMode(bool enabled) async =>
      (await SharedPreferences.getInstance()).setBool(_darkModeKey, enabled);

  Future<int?> get seedColorValue async =>
      (await SharedPreferences.getInstance()).getInt(_seedColorKey);

  Future<void> setSeedColorValue(int value) async =>
      (await SharedPreferences.getInstance()).setInt(_seedColorKey, value);
  Future<Map<String, String>> get draft async {
    final preferences = await SharedPreferences.getInstance();
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
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_draftNoteKey, note);
    await preferences.setString(_draftTagsKey, tags);
    await preferences.setString(_draftMoodKey, mood);
  }

  Future<void> clearDraft() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_draftNoteKey);
    await preferences.remove(_draftTagsKey);
    await preferences.remove(_draftMoodKey);
  }
}
