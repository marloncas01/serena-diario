import 'dart:math';

import '../models/emotion.dart';
import '../models/journal_entry.dart';
import '../models/memory_item.dart';
import 'emotional_profile_service.dart';
import 'emotional_history_service.dart';
import 'emotional_pattern_analyzer.dart';
import 'response_variation_tracker.dart';

class SmartAdvice {
  const SmartAdvice({
    required this.title,
    required this.message,
    required this.category,
    required this.emoji,
    this.priority = 0,
  });

  final String title;
  final String message;
  final String category;
  final String emoji;
  final int priority;
}

class SmartAdviceEngine {
  SmartAdviceEngine._();
  static final SmartAdviceEngine _instance = SmartAdviceEngine._();
  factory SmartAdviceEngine() => _instance;

  final _random = Random();
  final _variation = ResponseVariationTracker();

  SmartAdvice generate({
    required List<JournalEntry> entries,
    required List<EmotionAnalysis> emotionHistory,
    required EmotionalProfile? profile,
    required EmotionalHistoryReport? historyReport,
    required List<MemoryItem> memories,
    required int streak,
    String? sleepQuality,
    String? recentActivity,
    EmotionalPatternReport? patterns,
    String? currentEmotionId,
    DateTime? now,
  }) {
    final candidates = _dedupe(
      _collectCandidates(
        entries: entries,
        emotionHistory: emotionHistory,
        profile: profile,
        historyReport: historyReport,
        memories: memories,
        streak: streak,
        sleepQuality: sleepQuality,
        recentActivity: recentActivity,
        patterns: patterns,
        currentEmotionId: currentEmotionId,
        now: now,
      ),
    );

    if (candidates.isEmpty) {
      final fallback = _fallbackAdvice();
      _recordUsed([fallback]);
      return fallback;
    }

    candidates.sort((a, b) => b.priority.compareTo(a.priority));
    final top = candidates.take(3).toList();
    final chosen = top[_random.nextInt(top.length)];
    _recordUsed([chosen]);
    return chosen;
  }

  List<SmartAdvice> generateMultiple({
    required List<EmotionAnalysis> emotionHistory,
    required EmotionalProfile? profile,
    required EmotionalHistoryReport? historyReport,
    required List<MemoryItem> memories,
    required int streak,
    String? sleepQuality,
    String? recentActivity,
    EmotionalPatternReport? patterns,
    String? currentEmotionId,
    DateTime? now,
  }) {
    final candidates = _dedupe(
      _collectCandidates(
        entries: const [],
        emotionHistory: emotionHistory,
        profile: profile,
        historyReport: historyReport,
        memories: memories,
        streak: streak,
        sleepQuality: sleepQuality,
        recentActivity: recentActivity,
        patterns: patterns,
        currentEmotionId: currentEmotionId,
        now: now,
      ),
    );

    candidates.sort((a, b) => b.priority.compareTo(a.priority));
    final selected = candidates.take(5).toList();
    _recordUsed(selected);
    return selected;
  }

  List<SmartAdvice> _collectCandidates({
    required List<JournalEntry> entries,
    required List<EmotionAnalysis> emotionHistory,
    required EmotionalProfile? profile,
    required EmotionalHistoryReport? historyReport,
    required List<MemoryItem> memories,
    required int streak,
    String? sleepQuality,
    String? recentActivity,
    EmotionalPatternReport? patterns,
    String? currentEmotionId,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final candidates = <SmartAdvice>[];

    candidates.addAll(_fromCurrentEmotion(currentEmotionId));
    candidates.addAll(_fromEmotionContext(emotionHistory, profile));
    candidates.addAll(_fromPatterns(patterns, reference));
    candidates.addAll(_fromTimeOfDay(reference));
    candidates.addAll(_fromStreak(streak));
    candidates.addAll(_fromMemories(memories));
    candidates.addAll(_fromProfile(profile));
    candidates.addAll(_fromHistoryReport(historyReport));
    candidates.addAll(_fromSleep(sleepQuality));
    candidates.addAll(_fromActivity(recentActivity));

    return candidates;
  }

  /// Filtra consejos ya entregados recientemente para priorizar alternativas.
  List<SmartAdvice> _dedupe(List<SmartAdvice> candidates) {
    final kept = <SmartAdvice>[];
    for (final candidate in candidates) {
      if (_variation.wasRecentlyUsed('advice', candidate.title)) continue;
      kept.add(candidate);
    }
    return kept.isNotEmpty ? kept : candidates;
  }

  void _recordUsed(List<SmartAdvice> advices) {
    for (final advice in advices) {
      _variation.record('advice', advice.title);
    }
  }

  /// Limpia el historial anti-repetición de consejos (útil en tests).
  void resetHistory() => _variation.resetAll();

  List<SmartAdvice> _fromCurrentEmotion(String? currentEmotionId) {
    switch (currentEmotionId) {
      case 'ansiedad':
      case 'miedo':
        return const [
          SmartAdvice(
            title: 'Ancla con la respiración',
            message: 'Sientes ansiedad o miedo ahora mismo. Respira lento 4 veces: inhala, retén, exhala.',
            category: 'mindfulness',
            emoji: '🫁',
            priority: 6,
          ),
        ];
      case 'tristeza':
      case 'soledad':
        return const [
          SmartAdvice(
            title: 'Date un abrazo',
            message: 'Hoy sientes tristeza. Permítete sentirla sin juicio; escribirla ya es un acto valiente.',
            category: 'apoyo',
            emoji: '🤍',
            priority: 5,
          ),
        ];
      case 'estres':
      case 'frustracion':
        return const [
          SmartAdvice(
            title: 'Suelta la presión',
            message: 'El estrés está alto. Un descanso breve de 5 minutos puede ayudarte a recuperar claridad.',
            category: 'bienestar',
            emoji: '🍃',
            priority: 5,
          ),
        ];
      case 'alegria':
      case 'felicidad':
      case 'gratitud':
      case 'entusiasmo':
        return const [
          SmartAdvice(
            title: 'Atesora este momento',
            message: 'Hoy te sientes bien. Guarda un detalle de este momento para los días grises.',
            category: 'motivacion',
            emoji: '☀️',
            priority: 3,
          ),
        ];
      default:
        return const [];
    }
  }

  List<SmartAdvice> _fromPatterns(
    EmotionalPatternReport? patterns,
    DateTime reference,
  ) {
    if (patterns == null || patterns.totalEntries < 3) return [];
    final advices = <SmartAdvice>[];

    if (patterns.trend == TrendDirection.worsening) {
      advices.add(const SmartAdvice(
        title: 'Cuidado con la tendencia',
        message: 'He notado que tu ánimo viene bajando. Una pausa y respirar puede ayudarte a estabilizarte.',
        category: 'cuidado',
        emoji: '🌊',
        priority: 6,
      ));
    }

    if (patterns.negativeStreak >= 3) {
      advices.add(SmartAdvice(
        title: 'Varios días difíciles',
        message: 'Llevas ${patterns.negativeStreak} días con emociones negativas. Contarlo aquí, aunque sea breve, ya ayuda.',
        category: 'apoyo',
        emoji: '🤍',
        priority: 5,
      ));
    }

    final todayCounts = patterns.emotionsByWeekday[reference.weekday];
    if (todayCounts != null && _negativeCount(todayCounts) >= 2) {
      final dayLabel =
          EmotionalPatternAnalyzer.weekdayLabels[reference.weekday] ?? 'hoy';
      advices.add(SmartAdvice(
        title: 'Día difícil por patrón',
        message: 'Los $dayLabel suelen ser difíciles para ti. Sé especialmente amable contigo hoy.',
        category: 'cuidado',
        emoji: '🌦️',
        priority: 4,
      ));
    }

    final nightCounts = patterns.emotionsByHour[EmotionalPatternAnalyzer.noche];
    if (nightCounts != null && _negativeCount(nightCounts) >= 2) {
      advices.add(const SmartAdvice(
        title: 'Noches difíciles',
        message: 'Tus emociones negativas suelen aparecer por la noche. Una rutina de descanso puede ayudarte.',
        category: 'sueno',
        emoji: '🌙',
        priority: 4,
      ));
    }

    if (patterns.positiveStreak >= 2) {
      advices.add(SmartAdvice(
        title: 'Momentum positivo',
        message: 'Llevas ${patterns.positiveStreak} días de emociones positivas. Aprovecha para fijar una meta pequeña.',
        category: 'motivacion',
        emoji: '⚡',
        priority: 4,
      ));
    }

    if (patterns.stabilityScore <= 0.4) {
      advices.add(const SmartAdvice(
        title: 'Altibajos frecuentes',
        message: 'Tu ánimo cambia mucho entre días. Registrar desencadenantes puede ayudarte a entenderlos.',
        category: 'autoconocimiento',
        emoji: '🎢',
        priority: 3,
      ));
    }

    return advices;
  }

  int _negativeCount(Map<String, int> counts) =>
      EmotionalPatternAnalyzer.countNegative(counts);

  List<SmartAdvice> _fromEmotionContext(
    List<EmotionAnalysis> history,
    EmotionalProfile? profile,
  ) {
    if (history.isEmpty) return [];
    final recent = history.length > 5 ? history.sublist(history.length - 5) : history;
    final counts = <String, int>{};
    for (final a in recent) {
      for (final r in a.rankings.take(2)) {
        counts[r.emotion.id] = (counts[r.emotion.id] ?? 0) + 1;
      }
    }

    final advices = <SmartAdvice>[];
    final ansiedadCount = (counts['ansiedad'] ?? 0) + (counts['miedo'] ?? 0);
    final tristezaCount = (counts['tristeza'] ?? 0) + (counts['soledad'] ?? 0);
    final estresCount = (counts['estres'] ?? 0) + (counts['frustracion'] ?? 0);
    final alegriaCount = (counts['alegria'] ?? 0) + (counts['felicidad'] ?? 0);
    final calmaCount = counts['calma'] ?? 0;

    if (ansiedadCount >= 3) {
      advices.add(const SmartAdvice(
        title: 'Calma interior',
        message: 'Llevas varios días con ansiedad. Hoy intenta 5 minutos de respiración profunda. Pequeños momentos de calma hacen gran diferencia.',
        category: 'bienestar',
        emoji: '🧘',
        priority: 8,
      ));
      advices.add(const SmartAdvice(
        title: 'Reducir el ritmo',
        message: 'La ansiedad puede ser señal de que estás cargando mucho. ¿Puedes delegar algo hoy o tomarte un descanso?',
        category: 'bienestar',
        emoji: '🌿',
        priority: 7,
      ));
    }

    if (tristezaCount >= 3) {
      advices.add(const SmartAdvice(
        title: 'Conexión humana',
        message: 'La tristeza persistente mejora con conexión. Llama a alguien que te importe, aunque sea por 5 minutos.',
        category: 'relaciones',
        emoji: '💙',
        priority: 8,
      ));
      advices.add(const SmartAdvice(
        title: 'Permítete sentir',
        message: 'Está bien estar triste. No necesitas forzar la alegría. Escribe lo que sientes sin juzgarte.',
        category: 'autoconocimiento',
        emoji: '📝',
        priority: 7,
      ));
    }

    if (estresCount >= 3) {
      advices.add(const SmartAdvice(
        title: 'Pausa necesaria',
        message: 'El estrés acumulado necesita liberación. Sal a caminar 10 minutos o haz una pausa sin pantallas.',
        category: 'bienestar',
        emoji: '🚶',
        priority: 8,
      ));
    }

    if (alegriaCount >= 3) {
      advices.add(const SmartAdvice(
        title: 'Aprovecha el impulso',
        message: 'Estás en un momento positivo. Escribir ahora te ayudará a recordar esta sensación en días difíciles.',
        category: 'motivacion',
        emoji: '✨',
        priority: 6,
      ));
    }

    if (calmaCount >= 2) {
      advices.add(const SmartAdvice(
        title: 'Momento de serenidad',
        message: 'Tu calma actual es una fortaleza. Úsala para reflexionar o planificar algo que te ilusione.',
        category: 'autoconocimiento',
        emoji: '🍃',
        priority: 5,
      ));
    }

    return advices;
  }

  List<SmartAdvice> _fromTimeOfDay(DateTime reference) {
    final hour = reference.hour;
    final advices = <SmartAdvice>[];

    if (hour < 7) {
      advices.add(const SmartAdvice(
        title: 'Amanecer tranquilo',
        message: 'Es temprano. Aprovecha este momento de silencio para una reflexión breve.',
        category: 'mindfulness',
        emoji: '🌅',
        priority: 2,
      ));
    } else if (hour < 12) {
      advices.add(const SmartAdvice(
        title: 'Energía matutina',
        message: 'La mañana es buen momento para escribir. Tu mente está fresca y tus ideas más claras.',
        category: 'escritura',
        emoji: '☀️',
        priority: 2,
      ));
    } else if (hour < 15) {
      advices.add(const SmartAdvice(
        title: 'Mediodía',
        message: 'Un respiro entre horas. ¿Cómo va tu día? Una entrada corta cuenta.',
        category: 'escritura',
        emoji: '🌤️',
        priority: 1,
      ));
    } else if (hour < 19) {
      advices.add(const SmartAdvice(
        title: 'Tarde de reflexión',
        message: 'La tarde invita a pensar. ¿Qué momentos te marcaron hoy?',
        category: 'escritura',
        emoji: '🌇',
        priority: 2,
      ));
    } else {
      advices.add(const SmartAdvice(
        title: 'Cierre del día',
        message: 'Antes de dormir, escribe algo breve. Cerrar el día con una reflexión mejora tu descanso.',
        category: 'sueno',
        emoji: '🌙',
        priority: 3,
      ));
    }

    return advices;
  }

  List<SmartAdvice> _fromStreak(int streak) {
    final advices = <SmartAdvice>[];

    if (streak == 0) {
      advices.add(const SmartAdvice(
        title: 'Nuevo comienzo',
        message: 'No importa cuándo empezaste. Hoy es buen día para escribir tu primera entrada.',
        category: 'motivacion',
        emoji: '🌱',
        priority: 3,
      ));
    } else if (streak == 1) {
      advices.add(const SmartAdvice(
        title: 'Primer día',
        message: '¡Bien por empezar! La constancia se construye día a día.',
        category: 'motivacion',
        emoji: '🌟',
        priority: 2,
      ));
    } else if (streak >= 3 && streak < 7) {
      advices.add(SmartAdvice(
        title: '$streak días seguidos',
        message: 'Llevas $streak días escribiendo. Tu hábito se está formando. ¡Sigue así!',
        category: 'motivacion',
        emoji: '🔥',
        priority: 3,
      ));
    } else if (streak >= 7 && streak < 30) {
      advices.add(SmartAdvice(
        title: '¡Una semana completa!',
        message: 'Llevas $streak días. La escritura se está convirtiendo en parte de tu vida.',
        category: 'motivacion',
        emoji: '🏆',
        priority: 4,
      ));
    } else if (streak >= 30) {
      advices.add(SmartAdvice(
        title: '$streak días de constancia',
        message: 'Tu dedicación es admirable. La escritura es tu refugio.',
        category: 'motivacion',
        emoji: '💎',
        priority: 5,
      ));
    }

    return advices;
  }

  List<SmartAdvice> _fromMemories(List<MemoryItem> memories) {
    final advices = <SmartAdvice>[];
    if (memories.isEmpty) return advices;

    final important = memories.where((m) => m.importance > 0.5 || m.timesMentioned >= 2).toList();
    if (important.isEmpty) return advices;

    final memory = important[_random.nextInt(important.length)];
    final categoryEmoji = memory.category.emoji;

    advices.add(SmartAdvice(
      title: 'Recuerdo importante',
      message: '$categoryEmoji ${memory.value} es algo que te importa. ¿Quieres escribir más sobre esto?',
      category: 'autoconocimiento',
      emoji: '💭',
      priority: 3,
    ));

    return advices;
  }

  List<SmartAdvice> _fromProfile(EmotionalProfile? profile) {
    if (profile == null) return [];
    final advices = <SmartAdvice>[];

    if (profile.nivelAnsiedad > 0.5) {
      advices.add(const SmartAdvice(
        title: 'Cuidar tu ansiedad',
        message: 'Tu nivel de ansiedad ha sido alto. Una actividad física ligera puede ayudarte a regularla.',
        category: 'bienestar',
        emoji: '🏃',
        priority: 4,
      ));
    }

    if (profile.frecuenciaTristeza > 0.4) {
      advices.add(const SmartAdvice(
        title: 'Momentos de luz',
        message: 'Has sentido tristeza con frecuencia. Intenta anotar 3 cosas buenas de hoy, por pequeñas que sean.',
        category: 'autoconocimiento',
        emoji: '🌟',
        priority: 4,
      ));
    }

    if (profile.promedioPalabras < 30 && profile.promedioPalabras > 0) {
      advices.add(const SmartAdvice(
        title: 'Profundizar',
        message: 'Tus entradas son breves. Intenta escribir un poco más: ¿por qué sientes lo que sientes?',
        category: 'escritura',
        emoji: '📖',
        priority: 2,
      ));
    }

    if (profile.estabilidadEmocional > 0.7) {
      advices.add(const SmartAdvice(
        title: 'Estabilidad emocional',
        message: 'Tu estabilidad es una fortaleza. Úsala para enfrentar nuevos retos con confianza.',
        category: 'motivacion',
        emoji: '💪',
        priority: 2,
      ));
    }

    if (profile.nivelProgreso > 0.6) {
      advices.add(const SmartAdvice(
        title: 'Progreso notable',
        message: 'Estás avanzando. Reconocer tu progreso es parte del camino.',
        category: 'motivacion',
        emoji: '🎯',
        priority: 3,
      ));
    }

    return advices;
  }

  List<SmartAdvice> _fromHistoryReport(EmotionalHistoryReport? report) {
    if (report == null) return [];
    final advices = <SmartAdvice>[];

    if (report.hayMejora) {
      advices.add(const SmartAdvice(
        title: 'Tendencia positiva',
        message: 'Tu historial muestra mejora. Lo que estás haciendo está funcionando.',
        category: 'motivacion',
        emoji: '📈',
        priority: 4,
      ));
    }

    if (report.hayRecaida) {
      advices.add(const SmartAdvice(
        title: 'Momento difícil',
        message: 'Parece que estás pasando por un momento complicado. Está bien pedir ayuda.',
        category: 'bienestar',
        emoji: '🤝',
        priority: 7,
      ));
    }

    if (report.ciclosDetectados.isNotEmpty) {
      advices.add(const SmartAdvice(
        title: 'Patrones detectados',
        message: 'Serena notó un patrón en tus emociones. Hablar de esto puede ayudarte a entenderlo mejor.',
        category: 'autoconocimiento',
        emoji: '🔍',
        priority: 4,
      ));
    }

    return advices;
  }

  List<SmartAdvice> _fromSleep(String? quality) {
    if (quality == null) return [];
    final advices = <SmartAdvice>[];

    if (quality == 'malo' || quality == 'regular') {
      advices.add(const SmartAdvice(
        title: 'Descanso importante',
        message: 'Dormiste mal. Reduce la cafeína hoy, evita pantallas antes de dormir y trata de acostarte temprano.',
        category: 'sueno',
        emoji: '😴',
        priority: 4,
      ));
    }

    return advices;
  }

  List<SmartAdvice> _fromActivity(String? activity) {
    if (activity == null) return [];
    final advices = <SmartAdvice>[];

    if (activity == 'caminata') {
      advices.add(const SmartAdvice(
        title: 'Movimiento activo',
        message: 'Caminar es excelente para tu bienestar. ¿Notaste cómo te sentiste durante el paseo?',
        category: 'ejercicio',
        emoji: '🚶',
        priority: 2,
      ));
    } else if (activity == 'meditacion') {
      advices.add(const SmartAdvice(
        title: 'Mente en calma',
        message: 'La meditación reduce el estrés. Practicarla regularmente transforma tu día a día.',
        category: 'mindfulness',
        emoji: '🧘',
        priority: 2,
      ));
    }

    return advices;
  }

  SmartAdvice _fallbackAdvice() {
    final fallbacks = [
      const SmartAdvice(
        title: 'Bienvenida',
        message: 'Escribe cómo te sientes hoy. Cada entrada es un paso para conocerte mejor.',
        category: 'escritura',
        emoji: '📝',
        priority: 1,
      ),
      const SmartAdvice(
        title: 'Un momento para ti',
        message: 'Reservar unos minutos para escribir es un acto de cuidado personal.',
        category: 'bienestar',
        emoji: '💜',
        priority: 1,
      ),
      const SmartAdvice(
        title: 'Tu espacio seguro',
        message: 'Este es tu espacio. Escribe sin filtro, sin juicio. Solo tú leerás esto.',
        category: 'autoconocimiento',
        emoji: '🌿',
        priority: 1,
      ),
    ];
    return fallbacks[_random.nextInt(fallbacks.length)];
  }
}
