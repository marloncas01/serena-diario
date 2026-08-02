import '../models/emotion.dart';
import 'emotional_pattern_analyzer.dart';
import 'response_variation_tracker.dart';

enum PatternInsightCategory {
  frecuencia,
  semana,
  horario,
  tendencia,
  racha,
  diversidad,
  estabilidad,
  cambio,
}

class PatternInsight {
  const PatternInsight({
    required this.id,
    required this.category,
    required this.message,
    required this.emoji,
    required this.priority,
  });

  final String id;
  final PatternInsightCategory category;
  final String message;
  final String emoji;
  final int priority;
}

/// Convierte un [EmotionalPatternReport] en observaciones legibles con
/// redacción variada y sin repetir frases recientes.
class PatternInsightGenerator {
  PatternInsightGenerator({ResponseVariationTracker? tracker})
    : _tracker = tracker ?? ResponseVariationTracker.instance;

  final ResponseVariationTracker _tracker;

  static const int _maxInsights = 8;

  List<PatternInsight> generate(EmotionalPatternReport report) {
    final insights = <PatternInsight>[
      ..._frequencyInsights(report),
      ..._weekdayInsights(report),
      ..._hourInsights(report),
      ..._trendInsights(report),
      ..._streakInsights(report),
      ..._diversityInsights(report),
      ..._stabilityInsights(report),
      ..._changeInsights(report),
    ];

    insights.sort((a, b) => b.priority.compareTo(a.priority));

    final unique = <String>[];
    final result = <PatternInsight>[];
    for (final insight in insights) {
      if (unique.contains(insight.message)) continue;
      unique.add(insight.message);
      result.add(insight);
      if (result.length >= _maxInsights) break;
    }
    return result;
  }

  List<PatternInsight> _frequencyInsights(EmotionalPatternReport report) {
    final emotion = report.predominantEmotion;
    if (emotion == null) return const [];

    final seed = _seed(report, emotion.id);
    final template = _pick('insight_frecuencia', _frecuenciaTemplates, seed);
    return [
      PatternInsight(
        id: 'frecuencia_${emotion.id}',
        category: PatternInsightCategory.frecuencia,
        message: template.replaceAll('{emotion}', emotion.name).replaceAll(
          '{count}',
          '${report.predominantEmotionCount}',
        ),
        emoji: emotion.emoji,
        priority: 95,
      ),
    ];
  }

  List<PatternInsight> _weekdayInsights(EmotionalPatternReport report) {
    final hardest = _hardestWeekday(report);
    if (hardest == null) return const [];

    final (weekday, emotion) = hardest;
    final seed = _seed(report, 'dia_$weekday');
    final template = _pick('insight_semana', _semanaTemplates, seed);
    return [
      PatternInsight(
        id: 'semana_$weekday',
        category: PatternInsightCategory.semana,
        message: template.replaceAll('{dia}', weekday).replaceAll(
          '{emotion}',
          emotion.name,
        ),
        emoji: '📅',
        priority: 88,
      ),
    ];
  }

  List<PatternInsight> _hourInsights(EmotionalPatternReport report) {
    final slot = _hardestHourSlot(report);
    if (slot == null) return const [];

    final (hourLabel, emotion) = slot;
    final seed = _seed(report, 'hora_$hourLabel');
    final template = _pick('insight_horario', _horarioTemplates, seed);
    return [
      PatternInsight(
        id: 'horario_$hourLabel',
        category: PatternInsightCategory.horario,
        message: template.replaceAll('{franja}', hourLabel).replaceAll(
          '{emotion}',
          emotion.name,
        ),
        emoji: '🕰️',
        priority: 85,
      ),
    ];
  }

  List<PatternInsight> _trendInsights(EmotionalPatternReport report) {
    final seed = _seed(report, 'tendencia');
    switch (report.trend) {
      case TrendDirection.improving:
        return [
          PatternInsight(
            id: 'tendencia_mejora',
            category: PatternInsightCategory.tendencia,
            message: _pick('insight_tendencia_mejora', _mejoraTemplates, seed),
            emoji: '📈',
            priority: 92,
          ),
        ];
      case TrendDirection.worsening:
        return [
          PatternInsight(
            id: 'tendencia_empeora',
            category: PatternInsightCategory.tendencia,
            message: _pick(
              'insight_tendencia_empeora',
              _empeoraTemplates,
              seed,
            ),
            emoji: '📉',
            priority: 94,
          ),
        ];
      case TrendDirection.stable:
        return const [];
    }
  }

  List<PatternInsight> _streakInsights(EmotionalPatternReport report) {
    final insights = <PatternInsight>[];

    if (report.positiveStreak >= 2) {
      final seed = _seed(report, 'racha_positiva');
      final template = _pick(
        'insight_racha_positiva',
        _rachaPositivaTemplates,
        seed,
      );
      insights.add(PatternInsight(
        id: 'racha_positiva',
        category: PatternInsightCategory.racha,
        message: template.replaceAll('{n}', '${report.positiveStreak}'),
        emoji: '🔥',
        priority: 90,
      ));
    }

    if (report.negativeStreak >= 2) {
      final seed = _seed(report, 'racha_negativa');
      final template = _pick(
        'insight_racha_negativa',
        _rachaNegativaTemplates,
        seed,
      );
      insights.add(PatternInsight(
        id: 'racha_negativa',
        category: PatternInsightCategory.racha,
        message: template.replaceAll('{n}', '${report.negativeStreak}'),
        emoji: '🤍',
        priority: 93,
      ));
    }

    return insights;
  }

  List<PatternInsight> _diversityInsights(EmotionalPatternReport report) {
    if (report.emotionalDiversity < 3) return const [];
    final seed = _seed(report, 'diversidad');
    final template = _pick('insight_diversidad', _diversidadTemplates, seed);
    return [
      PatternInsight(
        id: 'diversidad',
        category: PatternInsightCategory.diversidad,
        message: template.replaceAll('{n}', '${report.emotionalDiversity}'),
        emoji: '🌈',
        priority: 70,
      ),
    ];
  }

  List<PatternInsight> _stabilityInsights(EmotionalPatternReport report) {
    if (report.totalEntries < 3) return const [];
    final seed = _seed(report, 'estabilidad');

    if (report.stabilityScore >= 0.75) {
      return [
        PatternInsight(
          id: 'estabilidad_alta',
          category: PatternInsightCategory.estabilidad,
          message: _pick(
            'insight_estabilidad_alta',
            _estabilidadAltaTemplates,
            seed,
          ),
          emoji: '⚖️',
          priority: 75,
        ),
      ];
    }
    if (report.stabilityScore <= 0.4) {
      return [
        PatternInsight(
          id: 'estabilidad_baja',
          category: PatternInsightCategory.estabilidad,
          message: _pick(
            'insight_estabilidad_baja',
            _estabilidadBajaTemplates,
            seed,
          ),
          emoji: '🎢',
          priority: 72,
        ),
      ];
    }
    return const [];
  }

  List<PatternInsight> _changeInsights(EmotionalPatternReport report) {
    final change = report.biggestMoodChange;
    if (change == null) return const [];
    final seed = _seed(report, 'cambio');
    final template = _pick('insight_cambio', _cambioTemplates, seed);
    return [
      PatternInsight(
        id: 'cambio_${change.toEmotion.id}',
        category: PatternInsightCategory.cambio,
        message: template
            .replaceAll('{desde}', change.fromEmotion.name)
            .replaceAll('{hacia}', change.toEmotion.name),
        emoji: '🔀',
        priority: 78,
      ),
    ];
  }

  (String, EmotionDefinition)? _hardestWeekday(
    EmotionalPatternReport report,
  ) {
    String? bestDay;
    var bestNegative = 0;
    EmotionDefinition? bestEmotion;

    for (final entry in report.emotionsByWeekday.entries) {
      final (negative, topEmotion) = _topNegative(entry.value);
      if (negative >= 2 && negative > bestNegative) {
        bestNegative = negative;
        bestDay = EmotionalPatternAnalyzer.weekdayLabels[entry.key];
        bestEmotion = topEmotion;
      }
    }

    if (bestDay == null || bestEmotion == null) return null;
    return (bestDay, bestEmotion);
  }

  (String, EmotionDefinition)? _hardestHourSlot(EmotionalPatternReport report) {
    String? bestSlot;
    var bestNegative = 0;
    EmotionDefinition? bestEmotion;

    for (final entry in report.emotionsByHour.entries) {
      final (negative, topEmotion) = _topNegative(entry.value);
      if (negative >= 2 && negative > bestNegative) {
        bestNegative = negative;
        bestSlot = entry.key;
        bestEmotion = topEmotion;
      }
    }

    if (bestSlot == null || bestEmotion == null) return null;
    return (bestSlot, bestEmotion);
  }

  /// Devuelve (menciones negativas, emoción con más menciones) de un mapa.
  (int, EmotionDefinition?) _topNegative(Map<String, int> counts) {
    var negative = EmotionalPatternAnalyzer.countNegative(counts);
    EmotionDefinition? topEmotion;
    var topCount = 0;
    for (final e in counts.entries) {
      final emotion = emotionById(e.key);
      if (emotion == null) continue;
      if (e.value > topCount) {
        topCount = e.value;
        topEmotion = emotion;
      }
    }
    return (negative, topEmotion);
  }

  int _seed(EmotionalPatternReport report, String salt) =>
      report.totalEntries * 31 +
      report.emotionalDiversity * 17 +
      report.positiveStreak +
      report.negativeStreak * 3 +
      salt.hashCode;

  String _pick(String key, List<String> templates, int seed) =>
      _tracker.pickUnique(key, templates, seed);

  static const List<String> _frecuenciaTemplates = [
    'Tu emoción más frecuente es la {emotion}.',
    'La {emotion} aparece más que ninguna otra en tus entradas.',
    'En este periodo, la {emotion} ha sido tu emoción predominante.',
    'La {emotion} lidera tu registro emocional reciente.',
  ];

  static const List<String> _semanaTemplates = [
    'El día {dia} suele ser el más difícil emocionalmente.',
    'Parece que el día {dia} pesa más para ti.',
    'Los registros del día {dia} suelen venir con {emotion}.',
    'El día {dia} es donde se concentran tus emociones más intensas.',
  ];

  static const List<String> _horarioTemplates = [
    'Durante la {franja} aparecen emociones de {emotion}.',
    'Tus emociones de {emotion} se intensifican por la {franja}.',
    'La {franja} es la franja donde aflora la {emotion}.',
    'Suele ser por la {franja} cuando sientes más {emotion}.',
  ];

  static const List<String> _mejoraTemplates = [
    'Has mostrado una mejoría emocional en los últimos días.',
    'Tus emociones han ido mejorando con el tiempo.',
    'Se nota una evolución positiva en tu estado de ánimo.',
    'Estás en una etapa emocionalmente más ligera que antes.',
  ];

  static const List<String> _empeoraTemplates = [
    'Parece que los últimos días han sido más pesados.',
    'Se percibe una tendencia a empeorar tu estado de ánimo.',
    'Tus emociones han ido volviéndose más difíciles recientemente.',
    'Los últimos registros muestran un ánimo más bajo que antes.',
  ];

  static const List<String> _rachaPositivaTemplates = [
    'Llevas {n} días con emociones positivas.',
    'Llevas una racha de {n} días sintiéndote bien.',
    'Van {n} días seguidos con emociones positivas.',
    'Has acumulado {n} días consecutivos de bienestar.',
  ];

  static const List<String> _rachaNegativaTemplates = [
    'Llevas {n} días con emociones difíciles.',
    'Van {n} días seguidos con emociones negativas.',
    'Llevas una racha de {n} días emocionalmente pesados.',
    'Has tenido {n} días consecutivos complicados.',
  ];

  static const List<String> _diversidadTemplates = [
    'Has expresado {n} emociones distintas en este periodo.',
    'Tu registro refleja {n} emociones diferentes.',
    'Son {n} las emociones que han aparecido en tus entradas.',
    'Has conectado con {n} emociones distintas recientemente.',
  ];

  static const List<String> _estabilidadAltaTemplates = [
    'Tu estado emocional se mantiene bastante estable.',
    'Mantienes una estabilidad emocional notable.',
    'Tus emociones se mantienen equilibradas entre entradas.',
    'El equilibrio emocional de tus últimos registros es alto.',
  ];

  static const List<String> _estabilidadBajaTemplates = [
    'Tu ánimo varía bastante de un día a otro.',
    'Hay altibajos marcados entre tus registros recientes.',
    'Tus emociones cambian mucho entre entradas.',
    'Se notan vaivenes emocionales en tu historial reciente.',
  ];

  static const List<String> _cambioTemplates = [
    'Tu mayor cambio de ánimo fue de {desde} hacia {hacia}.',
    'El salto emocional más fuerte fue de {desde} a {hacia}.',
    'Pasaste de {desde} a {hacia} en un cambio brusco.',
    'El cambio más marcado en tu ánimo fue hacia {hacia}.',
  ];
}
