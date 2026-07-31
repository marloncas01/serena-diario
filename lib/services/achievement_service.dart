import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.unlockedAt,
    this.isNew = false,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final DateTime unlockedAt;
  final bool isNew;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': unlockedAt.toIso8601String(),
      };

  factory Achievement.fromMap(String id, Map<String, dynamic> m) =>
      Achievement(
        id: id,
        title: _definitions[id]?.title ?? '',
        description: _definitions[id]?.description ?? '',
        emoji: _definitions[id]?.emoji ?? '',
        unlockedAt: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
      );

  static const _definitions = <String, _AchievementDef>{
    'first_entry': _AchievementDef(
      title: 'Primera entrada',
      description: 'Escribiste tu primera reflexión.',
      emoji: '🌱',
    ),
    'three_entries': _AchievementDef(
      title: 'Primeros pasos',
      description: 'Llevas 3 entradas escritas.',
      emoji: '📝',
    ),
    'seven_entries': _AchievementDef(
      title: 'Una semana',
      description: 'Llevas 7 entradas. El hábito está creciendo.',
      emoji: '🌿',
    ),
    'streak_3': _AchievementDef(
      title: 'Tres días seguidos',
      description: 'Escribiste 3 días consecutivos.',
      emoji: '🔥',
    ),
    'streak_7': _AchievementDef(
      title: 'Una semana constante',
      description: '7 días seguidos escribiendo.',
      emoji: '⭐',
    ),
    'streak_14': _AchievementDef(
      title: 'Quince días',
      description: 'Dos semanas de constancia.',
      emoji: '🌟',
    ),
    'streak_30': _AchievementDef(
      title: 'Un mes cuidándote',
      description: '30 días consecutivos. Tu dedicación es admirable.',
      emoji: '💎',
    ),
    'entries_10': _AchievementDef(
      title: 'Diez reflexiones',
      description: 'Has escrito 10 entradas.',
      emoji: '📖',
    ),
    'entries_30': _AchievementDef(
      title: '30 entradas',
      description: 'Un mes de reflexiones.',
      emoji: '📚',
    ),
    'entries_50': _AchievementDef(
      title: 'Medio centenar',
      description: '50 entradas. Tu diario es un tesoro.',
      emoji: '🏆',
    ),
    'entries_100': _AchievementDef(
      title: 'Cien entradas',
      description: '100 reflexiones. Un logro extraordinario.',
      emoji: '👑',
    ),
    'help_requested': _AchievementDef(
      title: 'Pediste ayuda',
      description: 'Reconocer que necesitas apoyo es valiente.',
      emoji: '💙',
    ),
    'memory_created': _AchievementDef(
      title: 'Serena te recuerda',
      description: 'Serena guardó un recuerdo importante.',
      emoji: '💭',
    ),
    'crisis_handled': _AchievementDef(
      title: 'Superaste un momento difícil',
      description: 'Pasaste por algo difícil y sigues aquí.',
      emoji: '💪',
    ),
    'mood_reflected': _AchievementDef(
      title: 'Autoconocimiento',
      description: 'Reflexionaste sobre tus emociones.',
      emoji: '🪞',
    ),
    'weekend_entry': _AchievementDef(
      title: 'Fin de semana reflexivo',
      description: 'Escribiste un sábado o domingo.',
      emoji: '🌅',
    ),
    'morning_entry': _AchievementDef(
      title: 'Madrugador',
      description: 'Escribiste antes de las 8 AM.',
      emoji: '☀️',
    ),
    'night_entry': _AchievementDef(
      title: 'Nocturno reflexivo',
      description: 'Escribiste después de las 10 PM.',
      emoji: '🌙',
    ),
  };
}

class _AchievementDef {
  const _AchievementDef({
    required this.title,
    required this.description,
    required this.emoji,
  });
  final String title;
  final String description;
  final String emoji;
}

class AchievementService {
  AchievementService._();
  static final AchievementService _instance = AchievementService._();
  factory AchievementService() => _instance;

  static const _achievementsKey = 'achievements_v1';
  static const _newAchievementsKey = 'new_achievements_v1';

  Future<Map<String, Achievement>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_achievementsKey);
    if (data == null || data.isEmpty) return {};

    final newIds = await getNewIds();
    final map = <String, Achievement>{};
    final decoded = _decodeMap(data);
    for (final entry in decoded.entries) {
      map[entry.key] = Achievement.fromMap(entry.key, entry.value)
          .copyWith(isNew: newIds.contains(entry.key));
    }
    return map;
  }

  Future<List<Achievement>> getUnlocked() async {
    final all = await getAll();
    final list = all.values.toList();
    list.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    return list;
  }

  Future<List<Achievement>> getNewAchievements() async {
    final all = await getAll();
    return all.values.where((a) => a.isNew).toList();
  }

  Future<void> clearNewFlags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_newAchievementsKey);
  }

  Future<bool> isUnlocked(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_achievementsKey);
    if (data == null) return false;
    final decoded = _decodeMap(data);
    return decoded.containsKey(id);
  }

  Future<bool> checkAndUnlock(String id) async {
    if (await isUnlocked(id)) return false;
    await _unlock(id);
    return true;
  }

  Future<void> checkAll(List<JournalEntry> entries) async {
    if (entries.isEmpty) return;

    if (entries.isNotEmpty) await checkAndUnlock('first_entry');
    if (entries.length >= 3) await checkAndUnlock('three_entries');
    if (entries.length >= 7) await checkAndUnlock('seven_entries');
    if (entries.length >= 10) await checkAndUnlock('entries_10');
    if (entries.length >= 30) await checkAndUnlock('entries_30');
    if (entries.length >= 50) await checkAndUnlock('entries_50');
    if (entries.length >= 100) await checkAndUnlock('entries_100');

    final streak = _calculateStreak(entries);
    if (streak >= 3) await checkAndUnlock('streak_3');
    if (streak >= 7) await checkAndUnlock('streak_7');
    if (streak >= 14) await checkAndUnlock('streak_14');
    if (streak >= 30) await checkAndUnlock('streak_30');

    final now = DateTime.now();
    final isWeekend = now.weekday == 6 || now.weekday == 7;

    if (entries.isNotEmpty) {
      final lastEntry = entries.first;
      final entryHour = lastEntry.createdAt.hour;

      if (isWeekend &&
          lastEntry.createdAt.day == now.day &&
          (now.weekday == 6 || now.weekday == 7)) {
        await checkAndUnlock('weekend_entry');
      }
      if (entryHour < 8 &&
          lastEntry.createdAt.day == now.day) {
        await checkAndUnlock('morning_entry');
      }
      if (entryHour >= 22 &&
          lastEntry.createdAt.day == now.day) {
        await checkAndUnlock('night_entry');
      }
    }
  }

  Future<void> _unlock(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_achievementsKey);
    final decoded = data != null && data.isNotEmpty ? _decodeMap(data) : <String, dynamic>{};

    decoded[id] = {
      'date': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_achievementsKey, _encodeMap(decoded));

    final newIds = await getNewIds();
    if (!newIds.contains(id)) {
      newIds.add(id);
      await prefs.setStringList(_newAchievementsKey, newIds);
    }
  }

  int _calculateStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    final now = DateTime.now();
    var streak = 0;
    var checkDate = DateTime(now.year, now.month, now.day);

    final dates = entries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet();

    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<List<String>> getNewIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_newAchievementsKey) ?? [];
  }

  int get totalAchievements => Achievement._definitions.length;

  String _encodeMap(Map<String, dynamic> m) {
    final parts = <String>[];
    for (final e in m.entries) {
      parts.add('${e.key}=${e.value['date']}');
    }
    return parts.join('&');
  }

  Map<String, dynamic> _decodeMap(String s) {
    final map = <String, dynamic>{};
    if (s.isEmpty) return map;
    final parts = s.split('&');
    for (final part in parts) {
      final kv = part.split('=');
      if (kv.length >= 2) {
        map[kv[0]] = {'date': kv[1]};
      }
    }
    return map;
  }
}

extension _AchievementCopyWith on Achievement {
  Achievement copyWith({bool? isNew}) => Achievement(
        id: id,
        title: title,
        description: description,
        emoji: emoji,
        unlockedAt: unlockedAt,
        isNew: isNew ?? this.isNew,
      );
}
