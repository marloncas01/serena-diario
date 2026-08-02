import 'package:flutter/material.dart';

import '../models/emotion.dart';
import '../models/journal_entry.dart';

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

  static EmotionDefinition predominantMood(List<JournalEntry> entries) {
    if (entries.isEmpty) return neutralEmotion;
    final counts = <String, int>{};
    for (final entry in entries) {
      counts.update(entry.mood, (count) => count + 1, ifAbsent: () => 1);
    }
    final name = counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    return emotionForLabel(name);
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

  // ── Emociones dominantes (30 emociones) ──

  /// Conteo de entradas por id de emoción dominante (ignora entradas sin
  /// análisis previo al guardado).
  static Map<String, int> dominantEmotionCounts(List<JournalEntry> entries) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final id = entry.dominantEmotionId;
      if (id == null || id.isEmpty) continue;
      counts.update(id, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  /// Conteo de entradas por categoría de la emoción dominante.
  static Map<EmotionCategory, int> categoryCounts(List<JournalEntry> entries) {
    final counts = {
      for (final category in EmotionCategory.values) category: 0,
    };
    for (final entry in entries) {
      final id = entry.dominantEmotionId;
      if (id == null) continue;
      final emotion = emotionById(id);
      if (emotion != null) {
        counts[emotion.category] = counts[emotion.category]! + 1;
      }
    }
    return counts;
  }

  /// Emoción dominante más frecuente (conteo) o null si no hay datos.
  static EmotionDefinition? predominantEmotion(List<JournalEntry> entries) {
    final counts = dominantEmotionCounts(entries);
    if (counts.isEmpty) return null;
    String? bestId;
    var bestCount = 0;
    counts.forEach((id, count) {
      if (count > bestCount) {
        bestCount = count;
        bestId = id;
      }
    });
    return emotionById(bestId!);
  }

  /// Intensidad promedio (0.0-1.0) de las emociones dominantes registradas.
  static double averageIntensity(List<JournalEntry> entries) {
    final values = entries
        .map((entry) => entry.dominantEmotionIntensity)
        .whereType<double>()
        .toList(growable: false);
    if (values.isEmpty) return 0;
    return values.fold(0.0, (sum, value) => sum + value) / values.length;
  }

  /// Entradas con análisis emocional registrado (no nulo).
  static List<JournalEntry> withEmotion(List<JournalEntry> entries) =>
      entries
          .where((entry) =>
              entry.dominantEmotionId != null &&
              entry.dominantEmotionId!.isNotEmpty)
          .toList(growable: false);

  /// Emociones distintas presentes en las entradas, en orden de aparición.
  static List<EmotionDefinition> distinctEmotions(
    List<JournalEntry> entries,
  ) {
    final seen = <String>{};
    final result = <EmotionDefinition>[];
    for (final entry in entries) {
      final emotion = emotionForLabel(entry.mood);
      if (seen.add(emotion.id)) result.add(emotion);
    }
    return result;
  }
}
