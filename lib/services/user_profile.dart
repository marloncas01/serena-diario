import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserSex {
  prefieroNoDecirlo('Prefiero no decirlo'),
  hombre('Hombre'),
  mujer('Mujer');

  const UserSex(this.label);
  final String label;
}

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
  'Minimalista': ['🙂', '😊', '😀', '😎', '🤓', '😐', '🤔', '😴', '🥳'],
  'Naturaleza': ['🌙', '🌸', '🌿', '🌊', '🌅', '⭐'],
  'Animales': ['🦊', '🐼', '🐶', '🐱', '🦋', '🐝', '🦉'],
  'Fantasía': ['🔮', '✨', '🌌', '💫', '🎨', '🪄'],
  'Comida': ['☕', '🍵', '🫖', '🧁', '🍩', '🥑'],
  'Hobbies': ['🎧', '📚', '🎮', '⚽', '🎬', '✏️'],
  'Corazón': ['💜', '💙', '💚', '🧡', '🤍', '💛'],
};

const availableAvatars = [
  '🙂', '🌙', '🌸', '🌿', '🦊', '⭐', '🐼', '☀️',
  '😊', '🌊', '🦋', '🔮', '☕', '💜', '🌅', '✨',
  '😀', '😎', '🤓', '🐶', '🎧', '📚',
];

const _userNameKey = 'user_name_v1';
const _avatarKey = 'user_avatar_v1';
const _goalKey = 'user_goal_v1';
const _personalityKey = 'personality_v1';
const _sexKey = 'user_sex_v1';
const _avatarBoxName = 'user_profile';
const _avatarFieldName = 'avatar';

class UserProfile extends ChangeNotifier {
  String _userName = '';
  String _avatar = '🙂';
  String _goal = '';
  SerenaPersonality _personality = SerenaPersonality.amigable;
  UserSex _sex = UserSex.prefieroNoDecirlo;

  String get userName => _userName;
  String get avatar => _avatar;
  String get goal => _goal;
  SerenaPersonality get personality => _personality;
  UserSex get sex => _sex;

  String get greetingName => _userName.isNotEmpty ? _userName : 'amiga';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_userNameKey) ?? '';
    _avatar = await _readHiveAvatar() ?? prefs.getString(_avatarKey) ?? '🙂';
    _goal = prefs.getString(_goalKey) ?? '';
    _personality = _parsePersonality(prefs.getString(_personalityKey));
    _sex = _parseSex(prefs.getString(_sexKey));
    notifyListeners();
  }

  Future<void> setUserName(String value) async {
    if (_userName == value) return;
    _userName = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_userNameKey, value);
  }

  Future<void> setAvatar(String value) async {
    if (_avatar == value) return;
    _avatar = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_avatarKey, value);
    await _writeHiveAvatar(value);
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

  Future<void> setSex(UserSex value) async {
    if (_sex == value) return;
    _sex = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_sexKey, value.name);
  }

  SerenaPersonality _parsePersonality(String? value) {
    return SerenaPersonality.values.firstWhere(
      (p) => p.name == value,
      orElse: () => SerenaPersonality.amigable,
    );
  }

  UserSex _parseSex(String? value) {
    return UserSex.values.firstWhere(
      (s) => s.name == value,
      orElse: () => UserSex.prefieroNoDecirlo,
    );
  }

  Future<String?> _readHiveAvatar() async {
    try {
      final box = await Hive.openBox<String>(_avatarBoxName);
      return box.get(_avatarFieldName);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeHiveAvatar(String value) async {
    try {
      final box = await Hive.openBox<String>(_avatarBoxName);
      await box.put(_avatarFieldName, value);
    } catch (_) {
      // Hive puede no estar inicializado en el arranque; SharedPreferences
      // actúa como respaldo y Hive se reescribe en la siguiente edición.
    }
  }
}
