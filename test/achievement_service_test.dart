import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:serena_diario/models/journal_entry.dart';
import 'package:serena_diario/services/achievement_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    Hive.init(Directory.systemTemp.createTempSync('achievements_test').path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    if (Hive.isBoxOpen('achievements')) {
      await Hive.box<Map>('achievements').clear();
    }
  });

  JournalEntry entry(String id, DateTime date, String mood) =>
      JournalEntry(id: id, createdAt: date, mood: mood, note: 'reflexión');

  List<JournalEntry> consecutive(int days) => List.generate(days, (i) {
        final date = DateTime.now().subtract(Duration(days: days - 1 - i));
        return entry('e$i', date, 'Normal');
      });

  test('desbloquea logros por conteo de entradas y racha', () async {
    final service = AchievementService();
    await service.checkAll(consecutive(30));

    expect(await service.isUnlocked('first_entry'), isTrue);
    expect(await service.isUnlocked('three_entries'), isTrue);
    expect(await service.isUnlocked('entries_30'), isTrue);
    expect(await service.isUnlocked('streak_30'), isTrue);
    expect(await service.isUnlocked('entries_10'), isTrue);
  });

  test('racha larga desbloquea streak_60 y streak_100', () async {
    final service = AchievementService();
    await service.checkAll(consecutive(100));

    expect(await service.isUnlocked('streak_60'), isTrue);
    expect(await service.isUnlocked('streak_100'), isTrue);
    expect(await service.isUnlocked('entries_100'), isTrue);
  });

  test('primera emoción positiva desbloquea first_positive', () async {
    final service = AchievementService();
    await service.checkAll([entry('p1', DateTime.now(), 'Felicidad')]);
    expect(await service.isUnlocked('first_positive'), isTrue);
  });

  test('diversidad de emociones desbloquea mood_diversity', () async {
    const moods = [
      'Alegría',
      'Felicidad',
      'Amor',
      'Gratitud',
      'Esperanza',
      'Calma',
      'Orgullo',
      'Motivación',
      'Inspiración',
      'Entusiasmo',
    ];
    final now = DateTime.now();
    final entries = moods
        .asMap()
        .entries
        .map((e) => entry('d${e.key}', now.subtract(Duration(days: e.key)), e.value))
        .toList();

    final service = AchievementService();
    await service.checkAll(entries);
    expect(await service.isUnlocked('mood_diversity'), isTrue);
  });

  test('20 días con escritura en el mes desbloquea month_days', () async {
    final now = DateTime.now();
    final entries = List.generate(
      20,
      (i) => entry('m$i', DateTime(now.year, now.month, i + 1), 'Calma'),
    );

    final service = AchievementService();
    await service.checkAll(entries);
    expect(await service.isUnlocked('month_days'), isTrue);
  });

  test('completar un objetivo desbloquea first_goal', () async {
    final service = AchievementService();
    await service.checkAll(
      [entry('g0', DateTime.now(), 'Calma')],
      completedGoals: 1,
    );
    expect(await service.isUnlocked('first_goal'), isTrue);
  });

  test('los logros recién desbloqueados se marcan como nuevos', () async {
    final service = AchievementService();
    await service.checkAll([entry('n0', DateTime.now(), 'Calma')]);

    final fresh = await service.getNewAchievements();
    expect(fresh.map((a) => a.id), contains('first_entry'));

    await service.clearNewFlags();
    expect(await service.getNewAchievements(), isEmpty);
  });
}
