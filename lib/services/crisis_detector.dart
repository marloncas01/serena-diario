import '../models/emotion.dart';

class CrisisResult {
  const CrisisResult({
    required this.highRisk,
    required this.confidence,
    required this.triggers,
    this.contextBoost = 0.0,
  });

  final bool highRisk;
  final double confidence;
  final List<String> triggers;
  final double contextBoost;

  static const CrisisResult none = CrisisResult(
    highRisk: false,
    confidence: 0,
    triggers: [],
  );
}

class _CrisisPattern {
  const _CrisisPattern(this.phrases, this.combinedSeverity);

  final List<String> phrases;
  final double combinedSeverity;
}

class CrisisDetector {
  const CrisisDetector._();

  static const List<CrisisPhrase> _phrases = [
    CrisisPhrase('quiero morir', 0.98),
    CrisisPhrase('me quiero morir', 0.99),
    CrisisPhrase('ya no quiero vivir', 0.98),
    CrisisPhrase('no quiero estar vivo', 0.97),
    CrisisPhrase('no quiero estar viva', 0.97),
    CrisisPhrase('no quiero seguir viviendo', 0.98),
    CrisisPhrase('no quiero seguir viva', 0.98),
    CrisisPhrase('no quiero seguir vivo', 0.98),
    CrisisPhrase('ya no quiero seguir', 0.95),
    CrisisPhrase('ya no aguanto la vida', 0.97),
    CrisisPhrase('la vida no vale la pena', 0.95),
    CrisisPhrase('no vale la pena vivir', 0.97),
    CrisisPhrase('no vale la pena seguir', 0.96),
    CrisisPhrase('nada vale la pena', 0.80),
    CrisisPhrase('ya no le veo sentido a todo', 0.82),
    CrisisPhrase('ya no le veo sentido a nada', 0.85),
    CrisisPhrase('ya no le veo sentido a la vida', 0.95),
    CrisisPhrase('me quiero matar', 0.99),
    CrisisPhrase('me quiero hacer daño', 0.95),
    CrisisPhrase('me voy a hacer daño', 0.96),
    CrisisPhrase('me voy a lastimar', 0.95),
    CrisisPhrase('me quiero lastimar', 0.95),
    CrisisPhrase('voy a cortarme', 0.94),
    CrisisPhrase('me voy a cortar', 0.94),
    CrisisPhrase('me voy a cortar las venas', 0.98),
    CrisisPhrase('me voy a tirar', 0.96),
    CrisisPhrase('me voy a lanzar', 0.96),
    CrisisPhrase('me voy a tirar de un puente', 0.98),
    CrisisPhrase('me voy a lanzar al vacío', 0.97),
    CrisisPhrase('me voy a tirar de un edificio', 0.98),
    CrisisPhrase('ya tengo el plan', 0.92),
    CrisisPhrase('ya sé cómo lo voy a hacer', 0.94),
    CrisisPhrase('ya decidí cómo terminar', 0.97),
    CrisisPhrase('ya decidí cómo acabar con todo', 0.98),
    CrisisPhrase('ya dejé mis cosas', 0.88),
    CrisisPhrase('ya dejé todo arreglado', 0.85),
    CrisisPhrase('ya me despido de todos', 0.92),
    CrisisPhrase('esta es mi última vez', 0.93),
    CrisisPhrase('esta es mi última carta', 0.88),
    CrisisPhrase('esta es mi despedida', 0.95),
    CrisisPhrase('este es mi último mensaje', 0.93),
    CrisisPhrase('este es mi último día', 0.96),
    CrisisPhrase('adiós para siempre', 0.96),
    CrisisPhrase('adios para siempre', 0.96),
    CrisisPhrase('me despido para siempre', 0.95),
    CrisisPhrase('ya no habrá mañana para mí', 0.93),
    CrisisPhrase('no habrá próxima vez', 0.88),
    CrisisPhrase('digan a mi familia que los quiero', 0.90),
    CrisisPhrase('cuídense mucho sin mí', 0.88),
    CrisisPhrase('sé que me extrañarán', 0.82),
    CrisisPhrase('ya no puedo más', 0.88),
    CrisisPhrase('no puedo más', 0.85),
    CrisisPhrase('ya no doy más', 0.84),
    CrisisPhrase('no doy más', 0.82),
    CrisisPhrase('estoy harto de vivir', 0.90),
    CrisisPhrase('estoy harta de vivir', 0.90),
    CrisisPhrase('estoy cansado de vivir', 0.88),
    CrisisPhrase('estoy cansada de vivir', 0.88),
    CrisisPhrase('no aguanto más', 0.84),
    CrisisPhrase('ya no aguanto más', 0.86),
    CrisisPhrase('no resisto más', 0.83),
    CrisisPhrase('no soporto más', 0.84),
    CrisisPhrase('estoy al límite', 0.78),
    CrisisPhrase('llegué al límite', 0.80),
    CrisisPhrase('no puedo con esto', 0.70),
    CrisisPhrase('nadie me necesita', 0.88),
    CrisisPhrase('nadie me quiere', 0.85),
    CrisisPhrase('a nadie le importo', 0.83),
    CrisisPhrase('a nadie le importa si vivo', 0.90),
    CrisisPhrase('a nadie le importa si muero', 0.95),
    CrisisPhrase('nadie se daría cuenta', 0.90),
    CrisisPhrase('nadie notaría mi ausencia', 0.88),
    CrisisPhrase('no le importo a nadie', 0.83),
    CrisisPhrase('soy un peso para todos', 0.82),
    CrisisPhrase('soy una carga', 0.78),
    CrisisPhrase('todos estarían mejor sin mí', 0.93),
    CrisisPhrase('todo sería mejor sin mí', 0.93),
    CrisisPhrase('sin mí todo sería mejor', 0.93),
    CrisisPhrase('el mundo sería mejor sin mí', 0.95),
    CrisisPhrase('no sirvo para nada', 0.80),
    CrisisPhrase('no sirvo de nada', 0.80),
    CrisisPhrase('soy inútil', 0.72),
    CrisisPhrase('no sirvo', 0.70),
    CrisisPhrase('quiero desaparecer', 0.82),
    CrisisPhrase('me quiero desaparecer', 0.84),
    CrisisPhrase('quiero que todo pare', 0.80),
    CrisisPhrase('ya no quiero sentir nada', 0.82),
    CrisisPhrase('quisiera no haber nacido', 0.90),
    CrisisPhrase('quisiera no existir', 0.90),
    CrisisPhrase('no debería haber nacido', 0.88),
    CrisisPhrase('el mundo sería mejor si no existiera', 0.92),
    CrisisPhrase('ojalá no estuviera aquí', 0.85),
    CrisisPhrase('ojalá no existiera', 0.88),
    CrisisPhrase('desearía no haber nacido', 0.88),
    CrisisPhrase('ya no siento nada', 0.82),
    CrisisPhrase('estoy muerto por dentro', 0.85),
    CrisisPhrase('estoy muerta por dentro', 0.85),
    CrisisPhrase('siento un vacío enorme', 0.78),
    CrisisPhrase('todo es oscuridad', 0.80),
    CrisisPhrase('no hay luz', 0.72),
    CrisisPhrase('no hay salida', 0.82),
    CrisisPhrase('no veo salida', 0.82),
    CrisisPhrase('estoy atrapado', 0.76),
    CrisisPhrase('estoy atrapada', 0.76),
    CrisisPhrase('no puedo escapar', 0.78),
    CrisisPhrase('no hay esperanza', 0.85),
    CrisisPhrase('ya no queda nada', 0.80),
    CrisisPhrase('quitarme la vida', 0.97),
    CrisisPhrase('acabar con todo esto', 0.82),
    CrisisPhrase('acabar con mi vida', 0.97),
    CrisisPhrase('terminar con todo', 0.85),
    CrisisPhrase('terminar con mi vida', 0.97),
    CrisisPhrase('tomar demasiadas pastillas', 0.94),
    CrisisPhrase('tomar una sobredosis', 0.95),
    CrisisPhrase('tomar pastillas de más', 0.90),
    CrisisPhrase('beber veneno', 0.92),
    CrisisPhrase('prenderme fuego', 0.94),
    CrisisPhrase('ahogarme', 0.82),
    CrisisPhrase('colgarme', 0.94),
    CrisisPhrase('estrangularme', 0.92),
    CrisisPhrase('gracias por todo', 0.60),
    CrisisPhrase('cuídense mucho', 0.55),
    CrisisPhrase('los quiero mucho', 0.50),
    CrisisPhrase('perdón por todo', 0.62),
    CrisisPhrase('lo siento mucho', 0.58),
    CrisisPhrase('siento mucho haber existido', 0.90),
    CrisisPhrase('perdón por ser una carga', 0.88),
    CrisisPhrase('perdón por ser un problema', 0.87),
  ];

  static const List<_CrisisPattern> _patterns = [
    _CrisisPattern(['no puedo más', 'nadie'], 0.92),
    _CrisisPattern(['ya no quiero', 'todo es'], 0.93),
    _CrisisPattern(['quiero morir', 'perdón'], 0.97),
    _CrisisPattern(['no vale la pena', 'nadie me'], 0.94),
    _CrisisPattern(['ya no siento', 'vacío'], 0.90),
    _CrisisPattern(['estoy solo', 'no hay nadie'], 0.88),
    _CrisisPattern(['ya decidí', 'despedida'], 0.96),
    _CrisisPattern(['ya no puedo', 'no veo salida'], 0.93),
    _CrisisPattern(['soy una carga', 'mejor sin mí'], 0.95),
    _CrisisPattern(['quiero desaparecer', 'nadie'], 0.91),
    _CrisisPattern(['estoy harto', 'ya no quiero'], 0.92),
    _CrisisPattern(['no hay esperanza', 'todo es oscuridad'], 0.93),
    _CrisisPattern(['ya no aguanto', 'no resisto'], 0.91),
    _CrisisPattern(['quisiera no existir', 'perdón'], 0.94),
    _CrisisPattern(['tomar pastillas', 'ya no quiero'], 0.96),
  ];

  static CrisisResult detect(String text) {
    if (text.trim().isEmpty) return CrisisResult.none;

    final normalized = _normalize(text);
    final triggers = <String>[];
    var maxConfidence = 0.0;

    for (final phrase in _phrases) {
      if (normalized.contains(phrase.text)) {
        triggers.add(phrase.text);
        if (phrase.severity > maxConfidence) {
          maxConfidence = phrase.severity;
        }
      }
    }

    for (final pattern in _patterns) {
      final allMatch = pattern.phrases.every(
        (p) => normalized.contains(p),
      );
      if (allMatch) {
        triggers.add('patrón: ${pattern.phrases.join(" + ")}');
        if (pattern.combinedSeverity > maxConfidence) {
          maxConfidence = pattern.combinedSeverity;
        }
      }
    }

    if (triggers.isEmpty) return CrisisResult.none;

    final overallConfidence = maxConfidence.clamp(0.0, 1.0);

    return CrisisResult(
      highRisk: overallConfidence >= 0.85,
      confidence: double.parse(overallConfidence.toStringAsFixed(2)),
      triggers: triggers,
    );
  }

  static CrisisResult detectWithContext(
    String text, {
    List<EmotionAnalysis> history = const [],
  }) {
    final base = detect(text);
    if (base == CrisisResult.none && history.isEmpty) {
      return CrisisResult.none;
    }

    var contextBoost = 0.0;

    if (history.length >= 3) {
      final recent = history.takeLast(5);
      var negativeCount = 0;
      var despairCount = 0;
      for (final a in recent) {
        for (final s in a.rankings.take(2)) {
          if (s.emotion.category == EmotionCategory.negativa) {
            negativeCount++;
          }
          if (s.emotion.id == 'desesperanza' ||
              s.emotion.id == 'vacio' ||
              s.emotion.id == 'soledad') {
            despairCount++;
          }
        }
      }
      if (negativeCount >= 4) contextBoost += 0.05;
      if (despairCount >= 3) contextBoost += 0.08;
    }

    if (base == CrisisResult.none) {
      if (contextBoost > 0.05) {
        return CrisisResult(
          highRisk: false,
          confidence: contextBoost,
          triggers: ['contexto emocional'],
          contextBoost: contextBoost,
        );
      }
      return CrisisResult.none;
    }

    final boostedConfidence = (base.confidence + contextBoost).clamp(0.0, 1.0);

    return CrisisResult(
      highRisk: boostedConfidence >= 0.85,
      confidence: double.parse(boostedConfidence.toStringAsFixed(2)),
      triggers: base.triggers,
      contextBoost: contextBoost,
    );
  }

  static String _normalize(String text) {
    var t = text.toLowerCase().trim();
    t = t.replaceAll(
      RegExp(
        r'[¿¡!?.;:,()\[\]{}\u00AB\u00BB\u2013\u2014\u2012\-]',
      ),
      ' ',
    );
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }
}

extension _ListTakeLast<T> on List<T> {
  List<T> takeLast(int count) {
    if (length <= count) return List.from(this);
    return sublist(length - count);
  }
}

class CrisisPhrase {
  const CrisisPhrase(this.text, this.severity);

  final String text;
  final double severity;
}
