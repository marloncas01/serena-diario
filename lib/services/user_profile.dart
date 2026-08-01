import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SerenaPersonality {
  amigable('Amigable', 'Siempre con una palabra cálida.'),
  profesional('Profesional', 'Directa, clara y respetuosa.'),
  motivadora('Motivadora', 'Te empuja a seguir adelante.'),
  tranquila('Tranquila', 'Pausada, como un susurro.'),
  reflexiva('Reflexiva', 'Te invita a pensar más profundo.');

  const SerenaPersonality(this.label, this.description);
  final String label;
  final String description;
}

const avatarCategories = <String, List<String>>{
  'Minimalista': ['🙂', '😊', '😐', '🤔', '😴', '🥳'],
  'Naturaleza': ['🌙', '🌸', '🌿', '🌊', '🌅', '⭐'],
  'Animales': ['🦊', '🐼', '🦋', '🐱', '🐝', '🦉'],
  'Fantasía': ['🔮', '✨', '🌙', '💫', '🎨', '🪄'],
  'Comida': ['☕', '🍵', '🫖', '🧁', '🍩', '🥑'],
  'Corazón': ['💜', '💙', '💚', '🧡', '🤍', '💛'],
};

const availableAvatars = [
  '🙂', '🌙', '🌸', '🌿', '🦊', '⭐', '🐼', '☀️',
  '😊', '🌊', '🦋', '🔮', '☕', '💜', '🌅', '✨',
];

const _userNameKey = 'user_name_v1';
const _diaryNameKey = 'diary_name_v1';
const _avatarKey = 'user_avatar_v1';
const _goalKey = 'user_goal_v1';
const _personalityKey = 'personality_v1';

class UserProfile extends ChangeNotifier {
  String _userName = '';
  String _diaryName = 'Mi diario';
  String _avatar = '🙂';
  String _goal = '';
  SerenaPersonality _personality = SerenaPersonality.amigable;

  String get userName => _userName;
  String get diaryName => _diaryName;
  String get avatar => _avatar;
  String get goal => _goal;
  SerenaPersonality get personality => _personality;
  bool get isComplete => _userName.isNotEmpty;

  String get greetingName => _userName.isNotEmpty ? _userName : 'amiga';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_userNameKey) ?? '';
    _diaryName = prefs.getString(_diaryNameKey) ?? 'Mi diario';
    _avatar = prefs.getString(_avatarKey) ?? '🙂';
    _goal = prefs.getString(_goalKey) ?? '';
    _personality = _parsePersonality(prefs.getString(_personalityKey));
    notifyListeners();
  }

  Future<void> setUserName(String value) async {
    if (_userName == value) return;
    _userName = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_userNameKey, value);
  }

  Future<void> setDiaryName(String value) async {
    if (_diaryName == value) return;
    _diaryName = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_diaryNameKey, value);
  }

  Future<void> setAvatar(String value) async {
    if (_avatar == value) return;
    _avatar = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_avatarKey, value);
  }

  Future<void> setGoal(String value) async {
    if (_goal == value) return;
    _goal = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_goalKey, value);
  }

  Future<void> setPersonality(SerenaPersonality value) async {
    if (_personality == value) return;
    _personality = value;
    notifyListeners();
    await (await SharedPreferences.getInstance())
        .setString(_personalityKey, value.name);
  }

  SerenaPersonality _parsePersonality(String? value) {
    return SerenaPersonality.values.firstWhere(
      (p) => p.name == value,
      orElse: () => SerenaPersonality.amigable,
    );
  }
}
