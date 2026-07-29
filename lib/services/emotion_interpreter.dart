import '../models/emotion.dart';

enum EmotionalPattern {
  conflictoEmocional,
  anticipacionAnsiosa,
  aislamientoSocial,
  patronBurnout,
  nostalgica,
  cicloFrustracion,
  vacioEmocional,
  emocionDominante,
  mezclaEquilibrada,
  estadoInespecifico,
}

class EmotionInterpretation {
  const EmotionInterpretation({
    required this.summary,
    required this.primaryEmotions,
    required this.pattern,
    required this.confidence,
    required this.hasMixedValence,
  });

  final String summary;
  final List<EmotionScore> primaryEmotions;
  final EmotionalPattern pattern;
  final double confidence;
  final bool hasMixedValence;
}

class EmotionInterpreter {
  const EmotionInterpreter._();

  static EmotionInterpretation interpret(EmotionAnalysis analysis) {
    if (analysis.rankings.isEmpty) {
      return EmotionInterpretation(
        summary: 'No se detectaron emociones claras en el texto.',
        primaryEmotions: const [],
        pattern: EmotionalPattern.estadoInespecifico,
        confidence: analysis.confidence,
        hasMixedValence: false,
      );
    }

    final top = analysis.rankings.length >= 3
        ? analysis.rankings.sublist(0, 3)
        : analysis.rankings;

    final hasMixed = _hasMixedValence(analysis.rankings);
    final pattern = _detectPattern(analysis.rankings, hasMixed);
    final summary = _generateSummary(pattern, top, hasMixed, analysis);

    return EmotionInterpretation(
      summary: summary,
      primaryEmotions: top,
      pattern: pattern,
      confidence: analysis.confidence,
      hasMixedValence: hasMixed,
    );
  }

  static bool _hasMixedValence(List<EmotionScore> rankings) {
    var hasPositive = false;
    var hasNegative = false;
    for (final score in rankings.take(5)) {
      if (score.emotion.category == EmotionCategory.positiva) hasPositive = true;
      if (score.emotion.category == EmotionCategory.negativa) hasNegative = true;
      if (hasPositive && hasNegative) return true;
    }
    return false;
  }

  static EmotionalPattern _detectPattern(
    List<EmotionScore> rankings,
    bool hasMixed,
  ) {
    final ids = rankings.map((s) => s.emotion.id).toSet();

    if (_isEmotionalConflict(ids, rankings, hasMixed)) {
      return EmotionalPattern.conflictoEmocional;
    }
    if (_isAnticipationAnxiety(ids)) {
      return EmotionalPattern.anticipacionAnsiosa;
    }
    if (_isSocialIsolation(ids)) {
      return EmotionalPattern.aislamientoSocial;
    }
    if (_isBurnoutPattern(ids)) {
      return EmotionalPattern.patronBurnout;
    }
    if (_isNostalgiaBlend(ids)) {
      return EmotionalPattern.nostalgica;
    }
    if (_isFrustrationCycle(ids)) {
      return EmotionalPattern.cicloFrustracion;
    }
    if (_isEmotionalVoid(ids)) {
      return EmotionalPattern.vacioEmocional;
    }

    if (rankings.isNotEmpty && rankings.first.percentage >= 55) {
      return EmotionalPattern.emocionDominante;
    }

    if (hasMixed) {
      return EmotionalPattern.mezclaEquilibrada;
    }

    return EmotionalPattern.emocionDominante;
  }

  static bool _isEmotionalConflict(
    Set<String> ids,
    List<EmotionScore> rankings,
    bool hasMixed,
  ) {
    if (!hasMixed || rankings.length < 2) return false;
    final top2 = rankings.take(2);
    final hasContradiction = _isContradictoryPair(
      top2.elementAt(0).emotion.id,
      top2.elementAt(1).emotion.id,
    );
    return hasContradiction;
  }

  static bool _isContradictoryPair(String a, String b) {
    const contradictions = {
      {'felicidad', 'tristeza'},
      {'alegria', 'tristeza'},
      {'alegria', 'soledad'},
      {'felicidad', 'soledad'},
      {'orgullo', 'culpa'},
      {'esperanza', 'desesperanza'},
      {'calma', 'ansiedad'},
      {'calma', 'enojo'},
      {'motivacion', 'desesperanza'},
      {'amor', 'enojo'},
      {'gratitud', 'culpa'},
      {'felicidad', 'vacio'},
      {'alegria', 'vacio'},
      {'orgullo', 'vergüenza'},
    };
    for (final pair in contradictions) {
      if ((pair.contains(a) && pair.contains(b))) return true;
    }
    return false;
  }

  static bool _isAnticipationAnxiety(Set<String> ids) {
    return ids.contains('ansiedad') &&
        (ids.contains('miedo') ||
            ids.contains('estres') ||
            ids.contains('incertidumbre'));
  }

  static bool _isSocialIsolation(Set<String> ids) {
    return ids.contains('soledad') &&
        (ids.contains('tristeza') ||
            ids.contains('vacio') ||
            ids.contains('desesperanza'));
  }

  static bool _isBurnoutPattern(Set<String> ids) {
    return ids.contains('burnout') ||
        (ids.contains('agotamiento') &&
            (ids.contains('desesperanza') || ids.contains('desmotivacion') || ids.contains('estres')));
  }

  static bool _isNostalgiaBlend(Set<String> ids) {
    return ids.contains('nostalgia') &&
        (ids.contains('tristeza') ||
            ids.contains('felicidad') ||
            ids.contains('esperanza'));
  }

  static bool _isFrustrationCycle(Set<String> ids) {
    return ids.contains('frustracion') &&
        (ids.contains('enojo') || ids.contains('estres'));
  }

  static bool _isEmotionalVoid(Set<String> ids) {
    return ids.contains('vacio') &&
        (ids.contains('desesperanza') || ids.contains('agotamiento'));
  }

  static String _generateSummary(
    EmotionalPattern pattern,
    List<EmotionScore> top,
    bool hasMixed,
    EmotionAnalysis analysis,
  ) {
    return switch (pattern) {
      EmotionalPattern.conflictoEmocional =>
        _conflictSummary(top, analysis),
      EmotionalPattern.anticipacionAnsiosa =>
        _anticipationSummary(top, analysis),
      EmotionalPattern.aislamientoSocial =>
        _isolationSummary(top, analysis),
      EmotionalPattern.patronBurnout =>
        _burnoutSummary(top, analysis),
      EmotionalPattern.nostalgica =>
        _nostalgiaSummary(top, analysis),
      EmotionalPattern.cicloFrustracion =>
        _frustrationSummary(top, analysis),
      EmotionalPattern.vacioEmocional =>
        _voidSummary(top, analysis),
      EmotionalPattern.emocionDominante =>
        _dominantSummary(top, analysis),
      EmotionalPattern.mezclaEquilibrada =>
        _mixedSummary(top, analysis),
      EmotionalPattern.estadoInespecifico =>
        'No se detectaron emociones claras en el texto.',
    };
  }

  static String _conflictSummary(List<EmotionScore> top, EmotionAnalysis a) {
    final primary = top.first.emotion.name;
    final secondary = top[1].emotion.name;

    final templates = [
      'Se percibe una mezcla de $primary y $secondary, '
          'lo que sugiere un conflicto emocional interno.',

      '$primary y $secondary coexisten en este relato, '
          'indicando que los sentimientos no van en la misma dirección.',

      'Las emociones muestran una tensión entre $primary y $secondary, '
          'un patrón común cuando los resultados no coinciden con las expectativas.',
    ];

    return _pick(templates, a);
  }

  static String _anticipationSummary(List<EmotionScore> top, EmotionAnalysis a) {
    final primary = top.first.emotion.name;

    final templates = [
      'La $primary parece estar relacionada con un evento futuro '
          'y genera ansiedad anticipatoria.',

      'Se detecta $primary orientada hacia una situación pendiente, '
          'lo que puede intensificar la preocupación.',

      '$primary presente de forma significativa, '
          'asociada a la incertidumbre sobre lo que está por venir.',
    ];

    return _pick(templates, a);
  }

  static String _isolationSummary(List<EmotionScore> top, EmotionAnalysis a) {
    final primary = top.first.emotion.name;

    final templates = [
      'Se observa aislamiento social acompañado de un estado emocional negativo persistente.',

      '$primary acompaña un patrón de desconexión con otros, '
          'señalando una necesidad no satisfecha de vínculo.',

      'La combinación de $primary con sentimientos de rechazo o ausencia '
          'sugiere un período de retraimiento social.',
    ];

    return _pick(templates, a);
  }

  static String _burnoutSummary(List<EmotionScore> top, EmotionAnalysis a) {
    final primary = top.first.emotion.name;

    final templates = [
      'Se identifica un patrón de $primary sostenido, '
          'posiblemente derivado de una carga prolongada de estrés.',

      '$primary con indicios de desgaste acumulado, '
          'un estado que suele aparecer cuando las exigencias superan los recursos disponibles.',

      'El nivel de $primary es significativo, '
          'consistentes con un agotamiento emocional prolongado.',
    ];

    return _pick(templates, a);
  }

  static String _nostalgiaSummary(List<EmotionScore> top, EmotionAnalysis a) {
    final primary = top.first.emotion.name;

    final templates = [
      '$primary detectada con fuerza, '
          'vinculada a recuerdos o experiencias pasadas.',

      'La $primary aparece como emoción central, '
          'señalando una conexión significativa con el pasado.',

      'Se percibe $primary mezclada con otros sentimientos, '
          'común cuando se evocan momentos que ya no están.',
    ];

    return _pick(templates, a);
  }

  static String _frustrationSummary(List<EmotionScore> top, EmotionAnalysis a) {
    final primary = top.first.emotion.name;
    final secondary = top.length > 1 ? ' y ${top[1].emotion.name}' : '';

    final templates = [
      '$primary$secondary predominan, '
          'un patrón que surge cuando los obstáculos bloquean los objetivos.',

      'Se detecta un ciclo de $primary$secondary, '
          'posiblemente alimentado por una situación percibida como incontrolable.',

      '$primary$secondary son las emociones dominantes, '
          'señalando una respuesta a limitaciones percibidas.',
    ];

    return _pick(templates, a);
  }

  static String _voidSummary(List<EmotionScore> top, EmotionAnalysis a) {
    final primary = top.first.emotion.name;

    final templates = [
      'Se percibe un estado de $primary emocional, '
          'una experiencia que puede manifestarse como desconexión o falta de sentido.',

      '$primary con ausencia de estímulos emocionales claros, '
          'lo que puede indicar un período de apatía o desvinculación.',

      'El $primary domina el panorama emocional, '
          'sugiriendo un estado de numbness emocional.',
    ];

    return _pick(templates, a);
  }

  static String _dominantSummary(List<EmotionScore> top, EmotionAnalysis a) {
    final primary = top.first.emotion.name;
    final pct = top.first.percentage;

    final templates = [
      '$primary es la emoción predominante ($pct%), '
          'con presencia significativa en el texto.',

      'El estado emocional está dominado por $primary ($pct%), '
          'una emoción claramente identificable.',

      '$primary ($pct%) se manifiesta como la emoción principal, '
          'definiendo el tono emocional del relato.',
    ];

    return _pick(templates, a);
  }

  static String _mixedSummary(List<EmotionScore> top, EmotionAnalysis a) {
    final names = top.map((s) => s.emotion.name).join(', ');

    final templates = [
      'Se presenta una mezcla de emociones: $names, '
          'sin que una domine claramente las demás.',

      'El panorama emocional muestra múltiples sentimientos: $names, '
          'reflejando una experiencia emocional diversa.',

      '$names coexisten con pesos similares, '
          'indicando que el texto expresa varias dimensiones emocionales.',
    ];

    return _pick(templates, a);
  }

  static String _pick(List<String> templates, EmotionAnalysis a) {
    final index = a.detectedKeywords.hashCode.abs() % templates.length;
    return templates[index];
  }
}
