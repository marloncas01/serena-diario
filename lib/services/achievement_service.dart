import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emotion.dart';
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
    'streak_60': _AchievementDef(
      title: 'Dos meses de constancia',
      description: '60 días consecutivos escribiendo.',
      emoji: '💫',
    ),
    'streak_100': _AchievementDef(
      title: 'Cien días de hábito',
      description: '100 días seguidos. Un logro extraordinario.',
      emoji: '🏅',
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
    'entries_200': _AchievementDef(
      title: 'Doscientos reflejos',
      description: '200 entradas. Tu historia merece contarse.',
      emoji: '🎖️',
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
    'first_positive': _AchievementDef(
      title: 'Un destello de luz',
      description: 'Registraste tu primera emoción positiva.',
      emoji: '🌤️',
    ),
    'mood_diversity': _AchievementDef(
      title: 'Espectro emocional',
      description: 'Reconociste 10 emociones distintas.',
      emoji: '🌈',
    ),
    'month_days': _AchievementDef(
      title: 'Mes completo',
      description: 'Escribiste 20 días en un mismo mes.',
      emoji: '🗓️',
    ),
    'first_goal': _AchievementDef(
      title: 'Meta cumplida',
      description: 'Completaste tu primer objetivo.',
      emoji: '🎯',
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

/// Motor de logros con persistencia en Hive.
///
/// La caja `achievements` guarda los logros desbloqueados (`{id: {date}}`).
/// Los datos antiguos de SharedPreferences se migran automáticamente en el
/// primer arranque. Los indicadores "nuevo" se mantienen en prefs.
class AchievementService {
  AchievementService._();
  static final AchievementService _instance = AchievementService._();
  factory AchievementService() => _instance;

  static const _boxName = 'achievements';
  static const _achievementsKey = 'achievements_v1';
  static const _newAchievementsKey = 'new_achievements_v1';

  late Box<Map> _box;
  bool _isReady = false;

  Future<void> _ensureBox() async {
    if (_isReady) return;
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Map>(_boxName);
    } else {
      _box = Hive.box<Map>(_boxName);
    }
    await _migrateLegacyAchievements();
    _isReady = true;
  }

  Future<void> _migrateLegacyAchievements() async {
    if (_box.isNotEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    final legacy = preferences.getString(_achievementsKey);
    if (legacy == null || legacy.isEmpty) return;
    final decoded = _decodeMap(legacy);
    for (final entry in decoded.entries) {
      _box.put(entry.key, entry.value);
    }
  }

  Future<Map<String, Achievement>> getAll() async {
    await _ensureBox();
    final newIds = await getNewIds();
    final map = <String, Achievement>{};
    for (final entry in _box.toMap().entries) {
      final data = Map<String, dynamic>.from(entry.value);
      map[entry.key] = Achievement.fromMap(entry.key, data)
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
    await _ensureBox();
    return _box.containsKey(id);
  }

  Future<bool> checkAndUnlock(String id) async {
    if (await isUnlocked(id)) return false;
    await _unlock(id);
    return true;
  }

  Future<void> checkAll(
    List<JournalEntry> entries, {
    int completedGoals = 0,
  }) async {
    if (entries.isEmpty && completedGoals == 0) return;

    await _ensureBox();

    if (entries.isNotEmpty) await checkAndUnlock('first_entry');
    if (entries.length >= 3) await checkAndUnlock('three_entries');
    if (entries.length >= 7) await checkAndUnlock('seven_entries');
    if (entries.length >= 10) await checkAndUnlock('entries_10');
    if (entries.length >= 30) await checkAndUnlock('entries_30');
    if (entries.length >= 50) await checkAndUnlock('entries_50');
    if (entries.length >= 100) await checkAndUnlock('entries_100');
    if (entries.length >= 200) await checkAndUnlock('entries_200');

    final streak = _calculateStreak(entries);
    if (streak >= 3) await checkAndUnlock('streak_3');
    if (streak >= 7) await checkAndUnlock('streak_7');
    if (streak >= 14) await checkAndUnlock('streak_14');
    if (streak >= 30) await checkAndUnlock('streak_30');
    if (streak >= 60) await checkAndUnlock('streak_60');
    if (streak >= 100) await checkAndUnlock('streak_100');

    if (completedGoals >= 1) await checkAndUnlock('first_goal');

    final distinctEmotions = entries
        .map((e) => emotionForLabel(e.mood).id)
        .toSet();
    if (distinctEmotions.length >= 10) await checkAndUnlock('mood_diversity');

    if (entries.any((e) => emotionForLabel(e.mood).category == EmotionCategory.positiva)) {
      await checkAndUnlock('first_positive');
    }

    final now = DateTime.now();
    final daysThisMonth = entries
        .where(
          (e) =>
              e.createdAt.year == now.year && e.createdAt.month == now.month,
        )
        .map((e) => e.createdAt.day)
        .toSet();
    if (daysThisMonth.length >= 20) await checkAndUnlock('month_days');

    final isWeekend = now.weekday == 6 || now.weekday == 7;

    if (entries.isNotEmpty) {
      final lastEntry = entries.first;
      final entryHour = lastEntry.createdAt.hour;

      if (isWeekend && lastEntry.createdAt.day == now.day) {
        await checkAndUnlock('weekend_entry');
      }
      if (entryHour < 8 && lastEntry.createdAt.day == now.day) {
        await checkAndUnlock('morning_entry');
      }
      if (entryHour >= 22 && lastEntry.createdAt.day == now.day) {
        await checkAndUnlock('night_entry');
      }
    }
  }

  Future<void> _unlock(String id) async {
    await _ensureBox();
    _box.put(id, {
      'date': DateTime.now().toIso8601String(),
    });

    final newIds = await getNewIds();
    if (!newIds.contains(id)) {
      newIds.add(id);
      final prefs = await SharedPreferences.getInstance();
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
