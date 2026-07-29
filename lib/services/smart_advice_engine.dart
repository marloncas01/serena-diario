import 'dart:math';

import '../models/emotion.dart';
import '../models/journal_entry.dart';
import '../models/memory_item.dart';
import 'emotional_profile_service.dart';
import 'emotional_history_service.dart';

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

  SmartAdvice generate({
    required List<JournalEntry> entries,
    required List<EmotionAnalysis> emotionHistory,
    required EmotionalProfile? profile,
    required EmotionalHistoryReport? historyReport,
    required List<MemoryItem> memories,
    required int streak,
    String? sleepQuality,
    String? recentActivity,
  }) {
    final candidates = <SmartAdvice>[];

    candidates.addAll(_fromEmotionContext(emotionHistory, profile));
    candidates.addAll(_fromTimeOfDay());
    candidates.addAll(_fromStreak(streak));
    candidates.addAll(_fromMemories(memories));
    candidates.addAll(_fromProfile(profile));
    candidates.addAll(_fromHistoryReport(historyReport));
    candidates.addAll(_fromSleep(sleepQuality));
    candidates.addAll(_fromActivity(recentActivity));

    if (candidates.isEmpty) {
      return _fallbackAdvice();
    }

    candidates.sort((a, b) => b.priority.compareTo(a.priority));
    final top = candidates.take(3).toList();
    return top[_random.nextInt(top.length)];
  }

  List<SmartAdvice> generateMultiple({
    required List<EmotionAnalysis> emotionHistory,
    required EmotionalProfile? profile,
    required EmotionalHistoryReport? historyReport,
    required List<MemoryItem> memories,
    required int streak,
    String? sleepQuality,
    String? recentActivity,
  }) {
    final candidates = <SmartAdvice>[];

    candidates.addAll(_fromEmotionContext(emotionHistory, profile));
    candidates.addAll(_fromTimeOfDay());
    candidates.addAll(_fromStreak(streak));
    candidates.addAll(_fromMemories(memories));
    candidates.addAll(_fromProfile(profile));
    candidates.addAll(_fromHistoryReport(historyReport));
    candidates.addAll(_fromSleep(sleepQuality));
    candidates.addAll(_fromActivity(recentActivity));

    candidates.sort((a, b) => b.priority.compareTo(a.priority));
    return candidates.take(5).toList();
  }

  List<SmartAdvice> _fromEmotionContext(
    List<EmotionAnalysis> history,
    EmotionalProfile? profile,
  ) {
    if (history.isEmpty) return [];
    final recent = history.length > 5 ? history.sublist(history.length - 5) : history;
    final counts = <String, int>{};
    for (final a in recent) {
      for (final r in a.rankings.take(2)) {
        counts[r.emotion.name] = (counts[r.emotion.name] ?? 0) + 1;
      }
    }

    final advices = <SmartAdvice>[];
    final ansiedadCount = (counts['ansiedad'] ?? 0) + (counts['miedo'] ?? 0);
    final tristezaCount = (counts['tristeza'] ?? 0) + (counts['soledad'] ?? 0);
    final estresCount = (counts['estres'] ?? 0) + (counts['frustracion'] ?? 0);
    final alegriaCount = (counts['alegria'] ?? 0) + (counts['felicidad'] ?? 0);
    final calmaCount = (counts['calma'] ?? 0) + (counts['serenidad'] ?? 0);

    if (ansiedadCount >= 3) {
      advices.add(SmartAdvice(
        title: 'Calma interior',
        message: 'Llevas varios días con ansiedad. Hoy intenta 5 minutos de respiración profunda. Pequeños momentos de calma hacen gran diferencia.',
        category: 'bienestar',
        emoji: '🧘',
        priority: 5,
      ));
      advices.add(SmartAdvice(
        title: 'Reducir el ritmo',
        message: 'La ansiedad puede ser señal de que estás cargando mucho. ¿Puedes delegar algo hoy o tomarte un descanso?',
        category: 'bienestar',
        emoji: '🌿',
        priority: 4,
      ));
    }

    if (tristezaCount >= 3) {
      advices.add(SmartAdvice(
        title: 'Conexión humana',
        message: 'La tristeza persistente mejora con conexión. Llama a alguien que te importe, aunque sea por 5 minutos.',
        category: 'relaciones',
        emoji: '💙',
        priority: 5,
      ));
      advices.add(SmartAdvice(
        title: 'Permítete sentir',
        message: 'Está bien estar triste. No necesitas forzar la alegría. Escribe lo que sientes sin juzgarte.',
        category: 'autoconocimiento',
        emoji: '📝',
        priority: 4,
      ));
    }

    if (estresCount >= 3) {
      advices.add(SmartAdvice(
        title: 'Pausa necesaria',
        message: 'El estrés acumulado necesita liberación. Sal a caminar 10 minutos o haz una pausa sin pantallas.',
        category: 'bienestar',
        emoji: '🚶',
        priority: 5,
      ));
    }

    if (alegriaCount >= 3) {
      advices.add(SmartAdvice(
        title: 'Aprovecha el impulso',
        message: 'Estás en un momento positivo. Escribir ahora te ayudará a recordar esta sensación en días difíciles.',
        category: 'motivacion',
        emoji: '✨',
        priority: 3,
      ));
    }

    if (calmaCount >= 2) {
      advices.add(SmartAdvice(
        title: 'Momento de serenidad',
        message: 'Tu calma actual es una fortaleza. Úsala para reflexionar o planificar algo que te ilusione.',
        category: 'autoconocimiento',
        emoji: '🍃',
        priority: 2,
      ));
    }

    return advices;
  }

  List<SmartAdvice> _fromTimeOfDay() {
    final hour = DateTime.now().hour;
    final advices = <SmartAdvice>[];

    if (hour < 7) {
      advices.add(SmartAdvice(
        title: 'Amanecer tranquilo',
        message: 'Es temprano. Aprovecha este momento de silencio para una reflexión breve.',
        category: 'mindfulness',
        emoji: '🌅',
        priority: 2,
      ));
    } else if (hour < 12) {
      advices.add(SmartAdvice(
        title: 'Energía matutina',
        message: 'La mañana es buen momento para escribir. Tu mente está fresca y tus ideas más claras.',
        category: 'escritura',
        emoji: '☀️',
        priority: 2,
      ));
    } else if (hour < 15) {
      advices.add(SmartAdvice(
        title: 'Mediodía',
        message: 'Un respiro entre horas. ¿Cómo va tu día? Una entrada corta cuenta.',
        category: 'escritura',
        emoji: '🌤️',
        priority: 1,
      ));
    } else if (hour < 19) {
      advices.add(SmartAdvice(
        title: 'Tarde de reflexión',
        message: 'La tarde invita a pensar. ¿Qué momentos te marcaron hoy?',
        category: 'escritura',
        emoji: '🌇',
        priority: 2,
      ));
    } else {
      advices.add(SmartAdvice(
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
      advices.add(SmartAdvice(
        title: 'Nuevo comienzo',
        message: 'No importa cuándo empezaste. Hoy es buen día para escribir tu primera entrada.',
        category: 'motivacion',
        emoji: '🌱',
        priority: 3,
      ));
    } else if (streak == 1) {
      advices.add(SmartAdvice(
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
      advices.add(SmartAdvice(
        title: 'Cuidar tu ansiedad',
        message: 'Tu nivel de ansiedad ha sido alto. Una actividad física ligera puede ayudarte a regularla.',
        category: 'bienestar',
        emoji: '🏃',
        priority: 4,
      ));
    }

    if (profile.frecuenciaTristeza > 0.4) {
      advices.add(SmartAdvice(
        title: 'Momentos de luz',
        message: 'Has sentido tristeza con frecuencia. Intenta anotar 3 cosas buenas de hoy, por pequeñas que sean.',
        category: 'autoconocimiento',
        emoji: '🌟',
        priority: 4,
      ));
    }

    if (profile.promedioPalabras < 30 && profile.promedioPalabras > 0) {
      advices.add(SmartAdvice(
        title: 'Profundizar',
        message: 'Tus entradas son breves. Intenta escribir un poco más: ¿por qué sientes lo que sientes?',
        category: 'escritura',
        emoji: '📖',
        priority: 2,
      ));
    }

    if (profile.estabilidadEmocional > 0.7) {
      advices.add(SmartAdvice(
        title: 'Estabilidad emocional',
        message: 'Tu estabilidad es una fortaleza. Úsala para enfrentar nuevos retos con confianza.',
        category: 'motivacion',
        emoji: '💪',
        priority: 2,
      ));
    }

    if (profile.nivelProgreso > 0.6) {
      advices.add(SmartAdvice(
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
      advices.add(SmartAdvice(
        title: 'Tendencia positiva',
        message: 'Tu historial muestra mejora. Lo que estás haciendo está funcionando.',
        category: 'motivacion',
        emoji: '📈',
        priority: 3,
      ));
    }

    if (report.hayRecaida) {
      advices.add(SmartAdvice(
        title: 'Momento difícil',
        message: 'Parece que estás pasando por un momento complicado. Está bien pedir ayuda.',
        category: 'bienestar',
        emoji: '🤝',
        priority: 5,
      ));
    }

    if (report.ciclosDetectados.isNotEmpty) {
      advices.add(SmartAdvice(
        title: 'Patrones detectados',
        message: 'Serena notó un patrón en tus emociones. Hablar de esto puede ayudarte a entenderlo mejor.',
        category: 'autoconocimiento',
        emoji: '🔍',
        priority: 3,
      ));
    }

    return advices;
  }

  List<SmartAdvice> _fromSleep(String? quality) {
    if (quality == null) return [];
    final advices = <SmartAdvice>[];

    if (quality == 'malo' || quality == 'regular') {
      advices.add(SmartAdvice(
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
      advices.add(SmartAdvice(
        title: 'Movimiento activo',
        message: 'Caminar es excelente para tu bienestar. ¿Notaste cómo te sentiste durante el paseo?',
        category: 'ejercicio',
        emoji: '🚶',
        priority: 2,
      ));
    } else if (activity == 'meditacion') {
      advices.add(SmartAdvice(
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
      SmartAdvice(
        title: 'Bienvenida',
        message: 'Escribe cómo te sientes hoy. Cada entrada es un paso para conocerte mejor.',
        category: 'escritura',
        emoji: '📝',
        priority: 1,
      ),
      SmartAdvice(
        title: 'Un momento para ti',
        message: 'Reservar unos minutos para escribir es un acto de cuidado personal.',
        category: 'bienestar',
        emoji: '💜',
        priority: 1,
      ),
      SmartAdvice(
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
