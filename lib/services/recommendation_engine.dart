import '../models/emotion.dart';
import '../models/memory_item.dart';
import 'emotional_profile_service.dart';
import 'emotional_history_service.dart';

class Recommendation {
  const Recommendation({
    required this.titulo,
    required this.descripcion,
    required this.razon,
    required this.categoria,
    required this.prioridad,
  });

  final String titulo;
  final String descripcion;
  final String razon;
  final String categoria;
  final int prioridad;
}

class RecommendationEngine {
  List<Recommendation> generate({
    required EmotionalProfile profile,
    required EmotionalHistoryReport history,
    required List<MemoryItem> memories,
    required List<EmotionAnalysis> emotionHistory,
  }) {
    final recs = <Recommendation>[];
    recs.addAll(_fromProfile(profile));
    recs.addAll(_fromHistory(history));
    recs.addAll(_fromMemories(memories));
    recs.addAll(_fromPatterns(emotionHistory));
    recs.sort((a, b) => b.prioridad.compareTo(a.prioridad));
    return recs.take(6).toList();
  }

  List<Recommendation> _fromProfile(EmotionalProfile profile) {
    final recs = <Recommendation>[];

    if (profile.nivelAnsiedad > 0.4) {
      recs.add(const Recommendation(
        titulo: 'Respiración consciente',
        descripcion:
            'Hoy podrías dedicar 3 minutos a respirar profundo. '
            'Inhala en 4 tiempos, sostén 4, exhala 4.',
        razon: 'Tu nivel de ansiedad ha sido elevated.',
        categoria: 'bienestar',
        prioridad: 3,
      ));
    }

    if (profile.frecuenciaTristeza > 0.3) {
      recs.add(const Recommendation(
        titulo: 'Conexión social',
        descripcion:
            'Llama a esa persona que tanto mencionas. '
            'A veces hablar con alguien de confianza marca la diferencia.',
        razon: 'La tristeza ha sido frecuente en tus entradas.',
        categoria: 'social',
        prioridad: 3,
      ));
    }

    if (profile.promedioPalabras < 50) {
      recs.add(const Recommendation(
        titulo: 'Profundizar la escritura',
        descripcion:
            'Intenta escribir un poco más en tu próxima entrada. '
            'No tiene que ser perfecto, solo sincero.',
        razon: 'Tus entradas suelen ser cortas.',
        categoria: 'escritura',
        prioridad: 2,
      ));
    }

    if (profile.nivelProgreso > 0.6) {
      recs.add(const Recommendation(
        titulo: 'Celebrar el progreso',
        descripcion:
            'Has tenido un progreso notable. '
            'Date permiso para reconocerlo.',
        razon: 'Tu nivel de progreso es alto.',
        categoria: 'autoestima',
        prioridad: 2,
      ));
    }

    return recs;
  }

  List<Recommendation> _fromHistory(EmotionalHistoryReport history) {
    final recs = <Recommendation>[];

    if (history.hayMejora) {
      recs.add(const Recommendation(
        titulo: 'Mantener el impulso',
        descripcion:
            'Sigue escribiendo. Lo que estás haciendo está funcionando.',
        razon: 'Has mostrado una tendencia positiva reciente.',
        categoria: 'motivacion',
        prioridad: 2,
      ));
    }

    if (history.hayRecaida) {
      recs.add(const Recommendation(
        titulo: 'Permitirte sentir',
        descripcion:
            'No está mal sentirse mal. '
            'Date espacio y recuerda que los malos momentos pasan.',
        razon: 'Detecté un retroceso emocional reciente.',
        categoria: 'bienestar',
        prioridad: 3,
      ));
    }

    if (history.ciclosDetectados.contains('Altibajos emocionales')) {
      recs.add(const Recommendation(
        titulo: 'Buscar estabilidad',
        descripcion:
            'Intenta establecer una rutina de escritura constante. '
            'Escribir a la misma hora puede ayudar.',
        razon: 'Se detectaron ciclos emocionales.',
        categoria: 'rutina',
        prioridad: 2,
      ));
    }

    return recs;
  }

  List<Recommendation> _fromMemories(List<MemoryItem> memories) {
    final recs = <Recommendation>[];

    final problems = memories
        .where((m) => m.active && m.category == MemoryCategory.problema)
        .toList()
      ..sort((a, b) => b.timesMentioned.compareTo(a.timesMentioned));

    if (problems.isNotEmpty) {
      recs.add(Recommendation(
        titulo: 'Abordar un tema pendiente',
        descripcion:
            'Has mencionado "${problems.first.value}" varias veces. '
            '¿Qué tal si escribes sobre ello con más detalle?',
        razon: 'Un problema aparece de forma recurrente.',
        categoria: 'autoconocimiento',
        prioridad: 2,
      ));
    }

    final logros = memories
        .where((m) => m.active && m.category == MemoryCategory.logro)
        .toList();
    if (logros.isNotEmpty) {
      recs.add(Recommendation(
        titulo: 'Recordar tus logros',
        descripcion:
            'No olvides que lograste: "${logros.first.value}". '
            'Eso demuestra tu fortaleza.',
        razon: 'Tienes logros registrados que vale la pena recordar.',
        categoria: 'autoestima',
        prioridad: 1,
      ));
    }

    return recs;
  }

  List<Recommendation> _fromPatterns(List<EmotionAnalysis> history) {
    final recs = <Recommendation>[];

    if (history.isEmpty) return recs;

    final keywordFreq = <String, int>{};
    for (final a in history) {
      for (final kw in a.detectedKeywords) {
        keywordFreq[kw] = (keywordFreq[kw] ?? 0) + 1;
      }
    }

    final sleepWords = {'dormir', 'insomnio', 'despierto', 'sueño', 'noche'};
    final hasSleep = keywordFreq.entries
        .any((e) => sleepWords.contains(e.key.toLowerCase()));
    if (hasSleep) {
      recs.add(const Recommendation(
        titulo: 'Mejorar el descanso',
        descripcion:
            'Intenta dormir un poco antes esta semana. '
            'El descanso impacta directamente en cómo te sientes.',
        razon: 'Has mencionado temas relacionados con el sueño.',
        categoria: 'bienestar',
        prioridad: 2,
      ));
    }

    final hasExercise = keywordFreq.entries.any(
      (e) => {'caminar', 'ejercicio', 'correr', 'gimnasio'}
          .contains(e.key.toLowerCase()),
    );
    if (hasExercise) {
      recs.add(const Recommendation(
        titulo: 'Actividad física',
        descripcion:
            'Hoy podrías salir a caminar 20 minutos. '
            'El ejercicio ayuda a mejorar el ánimo.',
        razon: 'El ejercicio aparece en tus escritos.',
        categoria: 'bienestar',
        prioridad: 1,
      ));
    }

    return recs;
  }
}
