import 'dart:math' as math;

import '../models/emotion.dart';
import '../models/journal_entry.dart';

enum TrendDirection { improving, worsening, stable }

class ConsecutiveEmotionPattern {
  const ConsecutiveEmotionPattern({
    required this.emotionId,
    required this.count,
    required this.startAt,
    required this.endAt,
  });

  final String emotionId;
  final int count;
  final DateTime startAt;
  final DateTime endAt;
}

class AbruptEmotionChange {
  const AbruptEmotionChange({
    required this.fromEmotion,
    required this.toEmotion,
    required this.at,
    required this.intensityDelta,
    required this.categoryFlip,
  });

  final EmotionDefinition fromEmotion;
  final EmotionDefinition toEmotion;
  final DateTime at;
  final double intensityDelta;
  final bool categoryFlip;
}

class EmotionalPatternReport {
  const EmotionalPatternReport({
    required this.totalEntries,
    required this.emotionFrequency,
    required this.predominantEmotion,
    required this.predominantEmotionCount,
    required this.emotionsByWeekday,
    required this.emotionsByHour,
    required this.consecutiveRuns,
    required this.abruptChanges,
    required this.biggestMoodChange,
    required this.stabilityScore,
    required this.trendScore,
    required this.trend,
    required this.positiveStreak,
    required this.negativeStreak,
    required this.emotionalDiversity,
    required this.mostActiveWeekday,
    required this.predominantHourSlot,
  });

  final int totalEntries;

  /// Frecuencia de emociones dominantes no neutras: emotionId -> recuento.
  final Map<String, int> emotionFrequency;

  final EmotionDefinition? predominantEmotion;
  final int predominantEmotionCount;

  /// weekday (1 = lunes ... 7 = domingo) -> emotionId -> recuento.
  final Map<int, Map<String, int>> emotionsByWeekday;

  /// franja horaria -> emotionId -> recuento.
  final Map<String, Map<String, int>> emotionsByHour;

  final List<ConsecutiveEmotionPattern> consecutiveRuns;
  final List<AbruptEmotionChange> abruptChanges;

  /// El mayor salto de ánimo detectado entre entradas consecutivas.
  final AbruptEmotionChange? biggestMoodChange;

  /// 0 = muy inestable, 1 = muy estable.
  final double stabilityScore;

  /// -1 (empeorando) ... +1 (mejorando).
  final double trendScore;
  final TrendDirection trend;

  /// Racha actual de entradas consecutivas positivas.
  final int positiveStreak;

  /// Racha actual de entradas consecutivas negativas.
  final int negativeStreak;

  /// Número de emociones distintas registradas como dominantes.
  final int emotionalDiversity;

  /// Etiqueta del día de la semana con más entradas (p. ej. "lunes").
  final String? mostActiveWeekday;

  /// Etiqueta de la franja horaria con más entradas (p. ej. "noche").
  final String? predominantHourSlot;
}

class EmotionalPatternAnalyzer {
  const EmotionalPatternAnalyzer._();

  static const String madrugada = 'madrugada';
  static const String manana = 'mañana';
  static const String tarde = 'tarde';
  static const String noche = 'noche';

  static const Map<int, String> weekdayLabels = {
    1: 'lunes',
    2: 'martes',
    3: 'miércoles',
    4: 'jueves',
    5: 'viernes',
    6: 'sábado',
    7: 'domingo',
  };

  static const double trendThreshold = 0.15;
  static const double abruptIntensityThreshold = 0.45;

  /// Suma las menciones de emociones de categoría negativa en un mapa de
  /// recuentos (emotionId -> cantidad). Utilizado por recomendaciones e
  /// insights para detectar días, franjas o semanas difíciles.
  static int countNegative(Map<String, int> counts) {
    var total = 0;
    for (final entry in counts.entries) {
      final emotion = emotionById(entry.key);
      if (emotion != null && emotion.category == EmotionCategory.negativa) {
        total += entry.value;
      }
    }
    return total;
  }

  static EmotionalPatternReport analyze(List<JournalEntry> entries) {
    final chronological = List<JournalEntry>.from(entries)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final emotionFrequency = <String, int>{};
    final emotionsByWeekday = <int, Map<String, int>>{};
    final emotionsByHour = <String, Map<String, int>>{};
    final byWeekdayEntries = <int, int>{};
    final byHourEntries = <String, int>{};

    for (final entry in chronological) {
      final emotion = _dominantEmotion(entry);
      final weekday = entry.createdAt.weekday;
      final hourSlot = _hourSlot(entry.createdAt.hour);

      byWeekdayEntries[weekday] = (byWeekdayEntries[weekday] ?? 0) + 1;
      byHourEntries[hourSlot] = (byHourEntries[hourSlot] ?? 0) + 1;

      if (emotion == null || emotion.id == 'neutral') continue;

      emotionFrequency[emotion.id] = (emotionFrequency[emotion.id] ?? 0) + 1;

      emotionsByWeekday.putIfAbsent(weekday, () => {}).update(
        emotion.id,
        (v) => v + 1,
        ifAbsent: () => 1,
      );
      emotionsByHour.putIfAbsent(hourSlot, () => {}).update(
        emotion.id,
        (v) => v + 1,
        ifAbsent: () => 1,
      );
    }

    final predominant = _predominant(emotionFrequency);
    final runs = _consecutiveRuns(chronological);
    final changes = _abruptChanges(chronological);
    final biggestChange = _biggestChange(changes);
    final stability = _stability(chronological);
    final trendScore = _trendScore(chronological);
    final trend = trendScore > trendThreshold
        ? TrendDirection.improving
        : trendScore < -trendThreshold
            ? TrendDirection.worsening
            : TrendDirection.stable;

    return EmotionalPatternReport(
      totalEntries: chronological.length,
      emotionFrequency: emotionFrequency,
      predominantEmotion: predominant?.$1,
      predominantEmotionCount: predominant?.$2 ?? 0,
      emotionsByWeekday: emotionsByWeekday,
      emotionsByHour: emotionsByHour,
      consecutiveRuns: runs,
      abruptChanges: changes,
      biggestMoodChange: biggestChange,
      stabilityScore: stability,
      trendScore: trendScore,
      trend: trend,
      positiveStreak: _streak(chronological, EmotionCategory.positiva),
      negativeStreak: _streak(chronological, EmotionCategory.negativa),
      emotionalDiversity: emotionFrequency.length,
      mostActiveWeekday: _mostActiveKey(byWeekdayEntries, labels: weekdayLabels),
      predominantHourSlot: _mostActiveKey(byHourEntries),
    );
  }

  static EmotionDefinition? _dominantEmotion(JournalEntry entry) {
    if (entry.dominantEmotionId != null &&
        entry.dominantEmotionId!.isNotEmpty) {
      return emotionById(entry.dominantEmotionId!);
    }
    return emotionForLabel(entry.mood);
  }

  static String _hourSlot(int hour) {
    if (hour < 6) return madrugada;
    if (hour < 12) return manana;
    if (hour < 18) return tarde;
    return noche;
  }

  static (EmotionDefinition, int)? _predominant(Map<String, int> frequency) {
    if (frequency.isEmpty) return null;
    String? bestId;
    var bestCount = 0;
    for (final entry in frequency.entries) {
      if (entry.value > bestCount) {
        bestId = entry.key;
        bestCount = entry.value;
      }
    }
    final emotion = bestId == null ? null : emotionById(bestId);
    if (emotion == null) return null;
    return (emotion, bestCount);
  }

  static List<ConsecutiveEmotionPattern> _consecutiveRuns(
    List<JournalEntry> chronological,
  ) {
    final runs = <ConsecutiveEmotionPattern>[];
    ConsecutiveEmotionPattern? current;

    for (final entry in chronological) {
      final emotion = _dominantEmotion(entry);
      if (emotion == null || emotion.id == 'neutral') {
        if (current != null) {
          runs.add(current);
          current = null;
        }
        continue;
      }
      if (current != null && current.emotionId == emotion.id) {
        current = ConsecutiveEmotionPattern(
          emotionId: current.emotionId,
          count: current.count + 1,
          startAt: current.startAt,
          endAt: entry.createdAt,
        );
        continue;
      }
      if (current != null) runs.add(current);
      current = ConsecutiveEmotionPattern(
        emotionId: emotion.id,
        count: 1,
        startAt: entry.createdAt,
        endAt: entry.createdAt,
      );
    }

    if (current != null) runs.add(current);

    // Descarta rachas de longitud 1 y conserva las más recientes.
    return runs.where((r) => r.count >= 2).toList().reversed.toList();
  }

  static List<AbruptEmotionChange> _abruptChanges(
    List<JournalEntry> chronological,
  ) {
    final changes = <AbruptEmotionChange>[];

    for (var i = 1; i < chronological.length; i++) {
      final from = _dominantEmotion(chronological[i - 1]);
      final to = _dominantEmotion(chronological[i]);
      if (from == null || from.id == 'neutral') continue;
      if (to == null || to.id == 'neutral') continue;

      final categoryFlip =
          from.category == EmotionCategory.positiva &&
              to.category == EmotionCategory.negativa ||
          from.category == EmotionCategory.negativa &&
              to.category == EmotionCategory.positiva;

      final fromIntensity =
          chronological[i - 1].dominantEmotionIntensity ?? 0.5;
      final toIntensity = chronological[i].dominantEmotionIntensity ?? 0.5;
      final delta = (toIntensity - fromIntensity).abs();

      if (categoryFlip || delta >= abruptIntensityThreshold) {
        changes.add(AbruptEmotionChange(
          fromEmotion: from,
          toEmotion: to,
          at: chronological[i].createdAt,
          intensityDelta: delta,
          categoryFlip: categoryFlip,
        ));
      }
    }

    return changes.reversed.toList();
  }

  static AbruptEmotionChange? _biggestChange(
    List<AbruptEmotionChange> changes,
  ) {
    if (changes.isEmpty) return null;
    AbruptEmotionChange? best;
    for (final change in changes) {
      if (best == null) {
        best = change;
        continue;
      }
      final changeScore = change.categoryFlip
          ? 1.0 + change.intensityDelta
          : change.intensityDelta;
      final bestScore = best.categoryFlip
          ? 1.0 + best.intensityDelta
          : best.intensityDelta;
      if (changeScore > bestScore) best = change;
    }
    return best;
  }

  static double _valence(EmotionDefinition emotion) => switch (emotion.category) {
        EmotionCategory.positiva => 1.0,
        EmotionCategory.negativa => -1.0,
        EmotionCategory.mixta => 0.0,
      };

  static double _trendScore(List<JournalEntry> chronological) {
    final valences = <double>[];
    for (final entry in chronological) {
      final emotion = _dominantEmotion(entry);
      if (emotion == null || emotion.id == 'neutral') continue;
      valences.add(_valence(emotion));
    }
    if (valences.length < 4) return 0;

    final half = valences.length ~/ 2;
    final first = valences.take(half).toList();
    final second = valences.skip(half).toList();
    final firstAvg = first.reduce((a, b) => a + b) / first.length;
    final secondAvg = second.reduce((a, b) => a + b) / second.length;
    return (secondAvg - firstAvg).clamp(-1.0, 1.0);
  }

  static double _stability(List<JournalEntry> chronological) {
    final valences = <double>[];
    final intensities = <double>[];

    for (final entry in chronological) {
      final emotion = _dominantEmotion(entry);
      if (emotion == null || emotion.id == 'neutral') continue;
      valences.add(_valence(emotion));
      intensities.add(entry.dominantEmotionIntensity ?? 0.5);
    }

    if (valences.length < 2) return 0.5;

    var flips = 0;
    for (var i = 1; i < valences.length; i++) {
      if (valences[i - 1] * valences[i] < 0) flips++;
    }
    final flipRate = flips / (valences.length - 1);

    final mean = intensities.reduce((a, b) => a + b) / intensities.length;
    final variance =
            intensities
                    .map((v) => (v - mean) * (v - mean))
                    .reduce((a, b) => a + b) /
                intensities.length;
    final spread = variance > 0 ? math.sqrt(variance) / 0.5 : 0.0;

    final score = 1 - (flipRate * 0.6 + spread.clamp(0.0, 1.0) * 0.4);
    return double.parse(score.clamp(0.0, 1.0).toStringAsFixed(2));
  }

  static int _streak(
    List<JournalEntry> chronological,
    EmotionCategory category,
  ) {
    var streak = 0;
    for (final entry in chronological.reversed) {
      final emotion = _dominantEmotion(entry);
      if (emotion == null || emotion.id == 'neutral') break;
      if (emotion.category != category) break;
      streak++;
    }
    return streak;
  }

  static String? _mostActiveKey<K>(
    Map<K, int> byKey, {
    Map<K, String>? labels,
  }) {
    if (byKey.isEmpty) return null;
    K? bestKey;
    var bestCount = 0;
    for (final entry in byKey.entries) {
      if (entry.value > bestCount) {
        bestKey = entry.key;
        bestCount = entry.value;
      }
    }
    if (bestKey == null) return null;
    return labels?[bestKey] ?? '$bestKey';
  }
}
