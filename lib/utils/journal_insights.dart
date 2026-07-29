import 'package:flutter/material.dart';

import '../models/journal_entry.dart';
import '../models/mood.dart';

class JournalInsights {
  const JournalInsights._();

  static int words(JournalEntry entry) => wordCount(entry.note);

  static int wordCount(String text) {
    final normalized = text.trim();
    return normalized.isEmpty ? 0 : normalized.split(RegExp(r'\s+')).length;
  }

  static int totalWords(List<JournalEntry> entries) =>
      entries.fold(0, (total, entry) => total + words(entry));

  static int streak(List<JournalEntry> entries) {
    final days = entries
        .map((entry) => DateUtils.dateOnly(entry.createdAt))
        .toSet();
    var day = DateUtils.dateOnly(DateTime.now());
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  static Mood predominantMood(List<JournalEntry> entries) {
    if (entries.isEmpty) return moodByName('Normal');
    final counts = <String, int>{};
    for (final entry in entries) {
      counts.update(entry.mood, (count) => count + 1, ifAbsent: () => 1);
    }
    final name = counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    return moodByName(name);
  }

  static Map<String, int> moodCounts(List<JournalEntry> entries) {
    final result = <String, int>{};
    for (final entry in entries) {
      result.update(entry.mood, (count) => count + 1, ifAbsent: () => 1);
    }
    return result;
  }

  static List<int> dailyCounts(List<JournalEntry> entries, {int days = 7}) {
    final today = DateUtils.dateOnly(DateTime.now());
    return List.generate(days, (index) {
      final date = today.subtract(Duration(days: days - index - 1));
      return entries
          .where((entry) => DateUtils.isSameDay(entry.createdAt, date))
          .length;
    }, growable: false);
  }

  static String weeklyInsight(List<JournalEntry> entries) {
    final current = dailyCounts(
      entries,
    ).fold<int>(0, (sum, value) => sum + value);
    final previous = entries.where((entry) {
      final age = DateTime.now().difference(entry.createdAt).inDays;
      return age >= 7 && age < 14;
    }).length;
    if (current == 0) {
      return 'Un pequeño registro hoy puede abrir una nueva semana.';
    }
    if (current > previous) {
      return 'Tu actividad aumentó respecto a la semana anterior.';
    }
    if (current < previous) {
      return 'Ve a tu ritmo: escribir poco también cuenta.';
    }
    return 'Mantienes un ritmo constante esta semana.';
  }
}
