import 'dart:math';
import '../models/emotion.dart';
import '../models/memory_item.dart';
import '../models/wellbeing_plan.dart';

class WellbeingCoach {
  WellbeingCoach._();

  static final WellbeingCoach _instance = WellbeingCoach._();
  factory WellbeingCoach() => _instance;

  final List<WellbeingObjective> _objectives = [];
  final List<WellbeingAchievement> _achievements = _buildAllAchievements();
  final List<WellbeingRecommendation> _recommendations = [];

  List<WellbeingObjective> get objectives => List.unmodifiable(_objectives);
  List<WellbeingAchievement> get achievements =>
      List.unmodifiable(_achievements);
  List<WellbeingRecommendation> get recommendations =>
      List.unmodifiable(_recommendations);

  // ─────────────────────────── Análisis de emociones ──────────────────────

  EmotionPatternReport analyzeEmotionPatterns(
    List<EmotionAnalysis> history,
  ) {
    if (history.isEmpty) {
      return const EmotionPatternReport(
        emocionesFrecuentes: [],
        emocionDominante: '',
        intensidadPromedio: 0,
        cambiosDetectados: [],
        tendencia: 0,
        resumen: 'Aún no hay suficientes entradas para analizar.',
      );
    }

    final freq = <String, int>{};
    final totals = <String, double>{};

    for (final analysis in history) {
      for (final score in analysis.rankings) {
        final id = score.emotion.id;
        freq[id] = (freq[id] ?? 0) + 1;
        totals[id] = (totals[id] ?? 0) + score.percentage;
      }
    }

    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).map((e) => e.key).toList();

    String dominant = top3.isNotEmpty ? top3.first : '';
    double avgIntensity = 0;
    if (totals.containsKey(dominant)) {
      avgIntensity = totals[dominant]! / (freq[dominant] ?? 1);
    }

    final cambios = _detectChanges(history);
    final tendencia = _calculateTrend(history);
    final resumen = _buildPatternSummary(top3, tendencia, cambios);

    return EmotionPatternReport(
      emocionesFrecuentes: top3,
      emocionDominante: dominant,
      intensidadPromedio: avgIntensity,
      cambiosDetectados: cambios,
      tendencia: tendencia,
      resumen: resumen,
    );
  }

  List<String> _detectChanges(List<EmotionAnalysis> history) {
    if (history.length < 4) return [];
    final mid = history.length ~/ 2;
    final firstHalf = history.sublist(0, mid);
    final secondHalf = history.sublist(mid);

    final firstScores = _averageScores(firstHalf);
    final secondScores = _averageScores(secondHalf);
    final cambios = <String>[];

    for (final id in secondScores.keys) {
      final prev = firstScores[id] ?? 0;
      final curr = secondScores[id]!;
      final def = emotionById(id);
      final label = def?.name ?? id;
      if (curr - prev > 0.15) {
        cambios.add('Aumento de $label');
      } else if (prev - curr > 0.15) {
        cambios.add('Disminución de $label');
      }
    }
    return cambios;
  }

  Map<String, double> _averageScores(List<EmotionAnalysis> analyses) {
    final counts = <String, int>{};
    final totals = <String, double>{};
    for (final a in analyses) {
      for (final s in a.rankings) {
        counts[s.emotion.id] = (counts[s.emotion.id] ?? 0) + 1;
        totals[s.emotion.id] = (totals[s.emotion.id] ?? 0) + s.percentage;
      }
    }
    return {
      for (final id in totals.keys)
        id: totals[id]! / (counts[id] ?? 1),
    };
  }

  double _calculateTrend(List<EmotionAnalysis> history) {
    if (history.length < 4) return 0;
    final mid = history.length ~/ 2;
    final firstHalf = history.sublist(0, mid);
    final secondHalf = history.sublist(mid);

    final posFirst = _positiveScore(firstHalf);
    final posSecond = _positiveScore(secondHalf);
    return (posSecond - posFirst).clamp(-1.0, 1.0);
  }

  double _positiveScore(List<EmotionAnalysis> analyses) {
    double total = 0;
    int count = 0;
    for (final a in analyses) {
      for (final s in a.rankings) {
        if (s.emotion.category == EmotionCategory.positiva) {
          total += s.percentage;
          count++;
        }
      }
    }
    return count > 0 ? total / count : 0;
  }

  String _buildPatternSummary(
    List<String> top3,
    double tendencia,
    List<String> cambios,
  ) {
    if (top3.isEmpty) return 'Aún no hay suficientes datos.';
    final labels = top3
        .map((id) => emotionById(id)?.name ?? id)
        .toList();
    final base = 'Tus emociones más frecuentes son '
        '${labels.join(", ")}.';
    if (tendencia > 0.1) {
      return '$base He notado una tendencia positiva reciente.';
    }
    if (tendencia < -0.1) {
      return '$base Parece que ha habido días más difíciles.';
    }
    return base;
  }

  // ─────────────────────── Análisis de escritura ─────────────────────────

  WritingReport analyzeWritingFrequency(
    List<DateTime> entryDates,
    List<int> wordCounts,
  ) {
    if (entryDates.isEmpty) {
      return const WritingReport(
        totalEntradas: 0,
        diasConEscritura: 0,
        rachaActual: 0,
        rachaMaxima: 0,
        frecuenciaSemanal: 0,
        promedioPalabras: 0,
      );
    }

    final sorted = List<DateTime>.from(entryDates)
      ..sort((a, b) => b.compareTo(a));
    final uniqueDays = sorted
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final rachaActual = _calculateCurrentStreak(uniqueDays);
    final rachaMaxima = _calculateMaxStreak(uniqueDays);

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeek = uniqueDays.where((d) => !d.isBefore(weekAgo)).length;

    double avgWords = 0;
    if (wordCounts.isNotEmpty) {
      avgWords = wordCounts.reduce((a, b) => a + b) / wordCounts.length;
    }

    return WritingReport(
      totalEntradas: entryDates.length,
      diasConEscritura: uniqueDays.length,
      rachaActual: rachaActual,
      rachaMaxima: rachaMaxima,
      frecuenciaSemanal: thisWeek.toDouble(),
      promedioPalabras: avgWords,
      ultimaEscritura: sorted.first,
    );
  }

  int _calculateCurrentStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    int streak = 0;
    DateTime expected = todayNorm;

    for (final day in sortedDays) {
      if (day == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (day.isAfter(expected)) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateMaxStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;
    int maxStreak = 1;
    int current = 1;
    for (int i = 1; i < sortedDays.length; i++) {
      final diff = sortedDays[i - 1].difference(sortedDays[i]).inDays;
      if (diff == 1) {
        current++;
        if (current > maxStreak) maxStreak = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return maxStreak;
  }

  // ───────────────────── Evolución emocional ─────────────────────────────

  EmotionalEvolution analyzeEvolution(List<EmotionAnalysis> history) {
    if (history.length < 4) {
      return const EmotionalEvolution(
        tendencia: 0,
        descripcion: 'Necesito más entradas para ver tu evolución.',
        emocionesInicio: {},
        emocionesFin: {},
        hayMejora: false,
        hayRecaida: false,
      );
    }

    final mid = history.length ~/ 2;
    final inicio = _countEmotions(history.sublist(0, mid));
    final fin = _countEmotions(history.sublist(mid));

    final posInicio = _posSum(inicio);
    final posFin = _posSum(fin);
    final negInicio = _negSum(inicio);
    final negFin = _negSum(fin);

    final hayMejora = posFin > posInicio && negFin <= negInicio;
    final hayRecaida = negFin > negInicio + 2 && posFin < posInicio;

    double tendencia = 0;
    if (posInicio + negInicio > 0) {
      tendencia = ((posFin - negFin) - (posInicio - negInicio)).toDouble();
      final maxVal = max(posInicio + negInicio, posFin + negFin);
      if (maxVal > 0) tendencia = tendencia / maxVal;
    }
    tendencia = tendencia.clamp(-1.0, 1.0);

    String desc;
    if (hayMejora) {
      desc = 'He notado una mejora en tu bienestar emocional. '
          'Las emociones positivas están ganando terreno.';
    } else if (hayRecaida) {
      desc = 'Parece que esta semana ha sido más difícil. '
          'Estoy aquí para acompañarte.';
    } else if (tendencia > 0.1) {
      desc = 'Tu evolución emocional va en una buena dirección.';
    } else if (tendencia < -0.1) {
      desc = 'Ha habido algunos altibajos recientes. '
          'Es normal en el proceso.';
    } else {
      desc = 'Tu estado emocional se ha mantenido estable.';
    }

    return EmotionalEvolution(
      tendencia: tendencia,
      descripcion: desc,
      emocionesInicio: inicio,
      emocionesFin: fin,
      hayMejora: hayMejora,
      hayRecaida: hayRecaida,
    );
  }

  Map<String, int> _countEmotions(List<EmotionAnalysis> analyses) {
    final counts = <String, int>{};
    for (final a in analyses) {
      for (final s in a.rankings.take(2)) {
        counts[s.emotion.id] = (counts[s.emotion.id] ?? 0) + 1;
      }
    }
    return counts;
  }

  int _posSum(Map<String, int> counts) {
    int total = 0;
    for (final entry in counts.entries) {
      final def = emotionById(entry.key);
      if (def?.category == EmotionCategory.positiva) total += entry.value;
    }
    return total;
  }

  int _negSum(Map<String, int> counts) {
    int total = 0;
    for (final entry in counts.entries) {
      final def = emotionById(entry.key);
      if (def?.category == EmotionCategory.negativa) total += entry.value;
    }
    return total;
  }

  // ───────────────── Generación de objetivos ─────────────────────────────

  List<WellbeingObjective> generateObjectives(
    EmotionPatternReport patrones,
    WritingReport escritura,
  ) {
    final nuevos = <WellbeingObjective>[];
    final now = DateTime.now();

    if (escritura.rachaActual < 3 && escritura.totalEntradas > 0) {
      nuevos.add(WellbeingObjective(
        id: 'obj_escribir_${now.millisecondsSinceEpoch}',
        titulo: 'Escribir durante 5 minutos',
        descripcion: 'Dedica 5 minutos al día a escribir cómo te sientes.',
        motivo: 'La escritura constante te ayuda a procesar emociones.',
        dificultad: DificultadObjetivo.facil,
        duracion: DuracionObjetivo.unaSemana,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    if (patrones.emocionesFrecuentes.contains('ansiedad') ||
        patrones.emocionesFrecuentes.contains('estres')) {
      nuevos.add(WellbeingObjective(
        id: 'obj_respirar_${now.millisecondsSinceEpoch}',
        titulo: 'Practicar respiración',
        descripcion: 'Dedica 3 minutos a respirar profundo y consciente.',
        motivo: 'Detecté que la ansiedad o el estrés aparecen frecuentemente.',
        dificultad: DificultadObjetivo.facil,
        duracion: DuracionObjetivo.unaSemana,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    if (patrones.emocionesFrecuentes.contains('tristeza') ||
        patrones.emocionesFrecuentes.contains('soledad')) {
      nuevos.add(WellbeingObjective(
        id: 'obj_social_${now.millisecondsSinceEpoch}',
        titulo: 'Hablar con alguien',
        descripcion: 'Busca a alguien de confianza y comparte cómo te va.',
        motivo: 'El apoyo social puede hacer una gran diferencia.',
        dificultad: DificultadObjetivo.media,
        duracion: DuracionObjetivo.unaSemana,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    if (patrones.tendencia < -0.1) {
      nuevos.add(WellbeingObjective(
        id: 'obj_caminar_${now.millisecondsSinceEpoch}',
        titulo: 'Salir a caminar',
        descripcion: 'Sal a caminar 15 minutos, aunque sea por tu barrio.',
        motivo: 'El ejercicio ligero puede mejorar tu ánimo.',
        dificultad: DificultadObjetivo.facil,
        duracion: DuracionObjetivo.unaSemana,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    if (escritura.frecuenciaSemanal >= 5) {
      nuevos.add(WellbeingObjective(
        id: 'obj_agua_${now.millisecondsSinceEpoch}',
        titulo: 'Tomar más agua',
        descripcion: 'Intenta tomar al menos 6 vasos de agua al día.',
        motivo: 'Cuidar tu cuerpo también es cuidar tu mente.',
        dificultad: DificultadObjetivo.facil,
        duracion: DuracionObjetivo.dosSemanas,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    if (patrones.emocionDominante.isNotEmpty) {
      final def = emotionById(patrones.emocionDominante);
      if (def?.category == EmotionCategory.positiva) {
        nuevos.add(WellbeingObjective(
          id: 'obj_musica_${now.millisecondsSinceEpoch}',
          titulo: 'Escuchar música que te guste',
          descripcion:
              'Dedica 10 minutos a escuchar música que te haga sentir bien.',
          motivo: 'La música potencia las emociones positivas.',
          dificultad: DificultadObjetivo.facil,
          duracion: DuracionObjetivo.unDia,
          estado: EstadoObjetivo.pendiente,
          fechaInicio: now,
        ));
      }
    }

    nuevos.add(WellbeingObjective(
      id: 'obj_dormir_${now.millisecondsSinceEpoch}',
      titulo: 'Acostarte más temprano',
      descripcion:
          'Intenta acostarte 20 minutos antes de lo habitual esta semana.',
      motivo: 'Un buen descanso impacta directamente en tu bienestar.',
      dificultad: DificultadObjetivo.media,
      duracion: DuracionObjetivo.unaSemana,
      estado: EstadoObjetivo.pendiente,
      fechaInicio: now,
    ));

    nuevos.add(WellbeingObjective(
      id: 'obj_leer_${now.millisecondsSinceEpoch}',
      titulo: 'Leer unos minutos',
      descripcion: 'Dedica 10 minutos a leer algo que te guste.',
      motivo: 'La lectura reduce el estrés y alimenta la mente.',
      dificultad: DificultadObjetivo.facil,
      duracion: DuracionObjetivo.unDia,
      estado: EstadoObjetivo.pendiente,
      fechaInicio: now,
    ));

    if (patrones.emocionesFrecuentes.contains('frustracion') ||
        patrones.emocionesFrecuentes.contains('enojo')) {
      nuevos.add(WellbeingObjective(
        id: 'obj_gratitud_${now.millisecondsSinceEpoch}',
        titulo: 'Escribir 3 cosas buenas',
        descripcion:
            'Antes de dormir, escribe 3 cosas positivas de tu día.',
        motivo:
            'La gratitud ayuda a reenfocar la atención hacia lo positivo.',
        dificultad: DificultadObjetivo.facil,
        duracion: DuracionObjetivo.unaSemana,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    if (patrones.emocionesFrecuentes.contains('soledad') ||
        patrones.emocionesFrecuentes.contains('vacio')) {
      nuevos.add(WellbeingObjective(
        id: 'obj_conexion_${now.millisecondsSinceEpoch}',
        titulo: 'Conectarte con alguien',
        descripcion:
            'Envía un mensaje a alguien que quieras, solo para saludar.',
        motivo:
            'Pequeñas conexiones sociales pueden llenar el vacío.',
        dificultad: DificultadObjetivo.facil,
        duracion: DuracionObjetivo.unDia,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    if (patrones.emocionesFrecuentes.contains('burnout') ||
        patrones.emocionesFrecuentes.contains('agotamiento')) {
      nuevos.add(WellbeingObjective(
        id: 'obj_descanso_${now.millisecondsSinceEpoch}',
        titulo: 'Tomar un descanso real',
        descripcion:
            'Dedica 30 minutos a hacer algo que no sea trabajo ni obligación.',
        motivo:
            'El burnout requiere descanso intencional, no solo pausas.',
        dificultad: DificultadObjetivo.media,
        duracion: DuracionObjetivo.unDia,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    if (patrones.emocionesFrecuentes.contains('incertidumbre') ||
        patrones.emocionesFrecuentes.contains('confusión')) {
      nuevos.add(WellbeingObjective(
        id: 'obj_claridad_${now.millisecondsSinceEpoch}',
        titulo: 'Escribir sobre tus dudas',
        descripcion:
            'Escribe específicamente sobre lo que te genera incertidumbre.',
        motivo:
            'Poner las dudas en papel ayuda a clarificar el pensamiento.',
        dificultad: DificultadObjetivo.facil,
        duracion: DuracionObjetivo.unDia,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    if (escritura.promedioPalabras < 30 && escritura.totalEntradas >= 3) {
      nuevos.add(WellbeingObjective(
        id: 'obj_profundizar_${now.millisecondsSinceEpoch}',
        titulo: 'Escribir más profundo',
        descripcion:
            'Intenta escribir al menos 80 palabras en tu próxima entrada.',
        motivo:
            'Escribir más te permite explorar mejor tus emociones.',
        dificultad: DificultadObjetivo.media,
        duracion: DuracionObjetivo.unaSemana,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: now,
      ));
    }

    _objectives.addAll(nuevos);
    return nuevos;
  }

  // ─────────────── Generación de recomendaciones ─────────────────────────

  List<WellbeingRecommendation> generateRecommendations(
    EmotionPatternReport patrones,
    WritingReport escritura,
    EmotionalEvolution evolucion,
    List<MemoryItem> memories,
  ) {
    final recs = <WellbeingRecommendation>[];
    final now = DateTime.now();

    if (escritura.rachaActual >= 3) {
      recs.add(WellbeingRecommendation(
        id: 'rec_racha_${now.millisecondsSinceEpoch}',
        titulo: 'Sigue con la racha',
        descripcion:
            'Llevas ${escritura.rachaActual} días escribiendo. '
            'Eso demuestra compromiso contigo mismo.',
        fuente: 'racha',
        prioridad: PrioridadRecomendacion.media,
        fechaGenerada: now,
      ));
    }

    if (evolucion.hayMejora) {
      recs.add(WellbeingRecommendation(
        id: 'rec_mejora_${now.millisecondsSinceEpoch}',
        titulo: 'Reconocer tu progreso',
        descripcion:
            'Noté que durante esta semana escribiste con más '
            'esperanza que hace unos días. Eso es un progreso importante.',
        fuente: 'evolucion',
        prioridad: PrioridadRecomendacion.alta,
        fechaGenerada: now,
      ));
    }

    if (evolucion.hayRecaida) {
      recs.add(WellbeingRecommendation(
        id: 'rec_recaida_${now.millisecondsSinceEpoch}',
        titulo: 'Te acompaño',
        descripcion:
            'He notado que esta semana parece haber sido más difícil. '
            'Estoy aquí para acompañarte, sin juzgar.',
        fuente: 'evolucion',
        prioridad: PrioridadRecomendacion.alta,
        fechaGenerada: now,
      ));
    }

    for (final memory in memories.take(3)) {
      if (memory.category == MemoryCategory.miedo ||
          memory.category == MemoryCategory.problema) {
        recs.add(WellbeingRecommendation(
          id: 'rec_mem_${memory.id}_${now.millisecondsSinceEpoch}',
          titulo: 'Retomar un tema pendiente',
          descripcion:
              'Me contaste que "${memory.value}". '
              '¿Te gustaría escribir más sobre eso para explorarlo?',
          fuente: 'memoria',
          prioridad: PrioridadRecomendacion.media,
          fechaGenerada: now,
        ));
        break;
      }
    }

    if (patrones.emocionesFrecuentes.contains('estres') ||
        patrones.emocionesFrecuentes.contains('agotamiento')) {
      recs.add(WellbeingRecommendation(
        id: 'rec_descanso_${now.millisecondsSinceEpoch}',
        titulo: 'Permitirte descansar',
        descripcion:
            'El descanso no es un lujo, es una necesidad. '
            'Date permiso para no hacer nada un rato.',
        fuente: 'patrones',
        prioridad: PrioridadRecomendacion.media,
        fechaGenerada: now,
      ));
    }

    if (patrones.emocionesFrecuentes.contains('tristeza')) {
      final related = memories.where(
        (m) =>
            m.category == MemoryCategory.gusto ||
            m.category == MemoryCategory.logro,
      );
      if (related.isNotEmpty) {
        final mem = related.first;
        recs.add(WellbeingRecommendation(
          id: 'rec_logro_${now.millisecondsSinceEpoch}',
          titulo: 'Recordar algo bueno',
          descripcion:
              'Recuerda que lograste: "${mem.value}". '
              'Eso demuestra tu fortaleza.',
          fuente: 'memoria',
          prioridad: PrioridadRecomendacion.media,
          fechaGenerada: now,
        ));
      }
    }

    if (escritura.frecuenciaSemanal < 2 && escritura.totalEntradas > 5) {
      recs.add(WellbeingRecommendation(
        id: 'rec_frecuencia_${now.millisecondsSinceEpoch}',
        titulo: 'Volver a escribir',
        descripcion:
            'Escribir aunque sea unas líneas te ayuda a '
            'ordenar lo que sientes. No tiene que ser perfecto.',
        fuente: 'escritura',
        prioridad: PrioridadRecomendacion.media,
        fechaGenerada: now,
      ));
    }

    _recommendations
      ..clear()
      ..addAll(recs);
    return recs;
  }

  // ────────────────────── Sistema de logros ──────────────────────────────

  List<WellbeingAchievement> checkAchievements(
    WritingReport escritura,
    EmotionPatternReport patrones,
    EmotionalEvolution evolucion,
  ) {
    final nuevos = <WellbeingAchievement>[];

    _tryUnlock(nuevos, 'ach_primera_entrada', escritura.totalEntradas >= 1);
    _tryUnlock(nuevos, 'ach_7_dias', escritura.rachaMaxima >= 7);
    _tryUnlock(nuevos, 'ach_racha_3', escritura.rachaActual >= 3);
    _tryUnlock(nuevos, 'ach_30_entradas', escritura.totalEntradas >= 30);
    _tryUnlock(nuevos, 'ach_escritor', escritura.promedioPalabras >= 100);
    _tryUnlock(nuevos, 'ach_cambio_positivo', evolucion.hayMejora);
    _tryUnlock(nuevos, 'ach_tendencia_positiva', patrones.tendencia > 0.2);
    _tryUnlock(
      nuevos,
      'ach_emocion_positiva',
      patrones.emocionesFrecuentes.isNotEmpty &&
          (emotionById(patrones.emocionesFrecuentes.first)?.category ==
              EmotionCategory.positiva),
    );
    _tryUnlock(nuevos, 'ach_2_semanas', escritura.rachaMaxima >= 14);
    _tryUnlock(nuevos, 'ach_100_entradas', escritura.totalEntradas >= 100);
    _tryUnlock(
      nuevos,
      'ach_resiliencia',
      evolucion.hayRecaida && !evolucion.hayMejora,
    );

    return nuevos;
  }

  void _tryUnlock(
    List<WellbeingAchievement> list,
    String id,
    bool condition,
  ) {
    if (!condition) return;
    final unlocked = _unlock(id);
    if (unlocked != null) list.add(unlocked);
  }

  WellbeingAchievement? _unlock(String id) {
    final idx = _achievements.indexWhere((a) => a.id == id);
    if (idx == -1) return null;
    if (_achievements[idx].desbloqueado) return null;
    _achievements[idx] = _achievements[idx].desbloquear();
    return _achievements[idx];
  }

  // ──────────────── Progreso de objetivos ────────────────────────────────

  void updateObjectiveProgress(String objectiveId, double progress) {
    final idx = _objectives.indexWhere((o) => o.id == objectiveId);
    if (idx == -1) return;
    _objectives[idx].progreso = progress.clamp(0.0, 1.0);
    if (_objectives[idx].progreso >= 1.0) {
      _objectives[idx].estado = EstadoObjetivo.completado;
      _objectives[idx].fechaFin = DateTime.now();
    } else if (_objectives[idx].estado == EstadoObjetivo.pendiente) {
      _objectives[idx].estado = EstadoObjetivo.enProgreso;
    }
  }

  void completeObjective(String objectiveId) {
    updateObjectiveProgress(objectiveId, 1.0);
  }

  void abandonObjective(String objectiveId) {
    final idx = _objectives.indexWhere((o) => o.id == objectiveId);
    if (idx == -1) return;
    _objectives[idx].estado = EstadoObjetivo.abandonado;
    _objectives[idx].fechaFin = DateTime.now();
  }

  // ──────────────── Snapshot completo ────────────────────────────────────

  WellbeingSnapshot generateSnapshot(
    List<EmotionAnalysis> emotionHistory,
    List<DateTime> entryDates,
    List<int> wordCounts,
    List<MemoryItem> memories,
  ) {
    final patrones = analyzeEmotionPatterns(emotionHistory);
    final escritura = analyzeWritingFrequency(entryDates, wordCounts);
    final evolucion = analyzeEvolution(emotionHistory);
    generateObjectives(patrones, escritura);
    checkAchievements(escritura, patrones, evolucion);
    final recs = generateRecommendations(
      patrones,
      escritura,
      evolucion,
      memories,
    );

    return WellbeingSnapshot(
      patrones: patrones,
      escritura: escritura,
      evolucion: evolucion,
      objetivosActivos: _objectives
          .where((o) => o.estado != EstadoObjetivo.completado &&
              o.estado != EstadoObjetivo.abandonado)
          .toList(),
      logrosDesbloqueados: _achievements
          .where((a) => a.desbloqueado)
          .toList(),
      recomendaciones: recs,
      fechaGeneracion: DateTime.now(),
    );
  }

  // ──────────────── Logros base ──────────────────────────────────────────

  static List<WellbeingAchievement> _buildAllAchievements() {
    return [
      const WellbeingAchievement(
        id: 'ach_primera_entrada',
        titulo: 'Primer paso',
        descripcion: 'Escribiste tu primera entrada en el diario.',
        icono: '🌟',
        categoria: CategoriaLogro.consistencia,
      ),
      const WellbeingAchievement(
        id: 'ach_7_dias',
        titulo: 'Primera semana',
        descripcion: 'Escribiste durante 7 días consecutivos.',
        icono: '🔥',
        categoria: CategoriaLogro.consistencia,
      ),
      const WellbeingAchievement(
        id: 'ach_racha_3',
        titulo: 'En racha',
        descripcion: '3 días consecutivos escribiendo.',
        icono: '⚡',
        categoria: CategoriaLogro.consistencia,
      ),
      const WellbeingAchievement(
        id: 'ach_30_entradas',
        titulo: '30 entradas',
        descripcion: 'Llevas 30 entradas en tu diario.',
        icono: '📚',
        categoria: CategoriaLogro.consistencia,
      ),
      const WellbeingAchievement(
        id: 'ach_escritor',
        titulo: 'Escritor comprometido',
        descripcion:
            'Promedias más de 100 palabras por entrada.',
        icono: '✍️',
        categoria: CategoriaLogro.progreso,
      ),
      const WellbeingAchievement(
        id: 'ach_cambio_positivo',
        titulo: 'Primer cambio positivo',
        descripcion: 'Tus emociones positivas están aumentando.',
        icono: '🌱',
        categoria: CategoriaLogro.emocional,
      ),
      const WellbeingAchievement(
        id: 'ach_tendencia_positiva',
        titulo: 'Tendencia positiva',
        descripcion: 'Tu bienestar emocional va en mejora.',
        icono: '📈',
        categoria: CategoriaLogro.emocional,
      ),
      const WellbeingAchievement(
        id: 'ach_emocion_positiva',
        titulo: 'Emoción dominante positiva',
        descripcion:
            'Tu emoción más frecuente es positiva. ¡Sigue así!',
        icono: '💛',
        categoria: CategoriaLogro.emocional,
      ),
      const WellbeingAchievement(
        id: 'ach_2_semanas',
        titulo: 'Dos semanas',
        descripcion: 'Escribiste durante 14 días consecutivos.',
        icono: '🏆',
        categoria: CategoriaLogro.consistencia,
      ),
      const WellbeingAchievement(
        id: 'ach_100_entradas',
        titulo: 'Centenario',
        descripcion: '100 entradas en tu diario. ¡Increíble!',
        icono: '💎',
        categoria: CategoriaLogro.progreso,
      ),
      const WellbeingAchievement(
        id: 'ach_resiliencia',
        titulo: 'Resiliencia',
        descripcion:
            'Atravesaste un momento difícil y volviste a escribir.',
        icono: '🫂',
        categoria: CategoriaLogro.autoconocimiento,
      ),
    ];
  }
}
