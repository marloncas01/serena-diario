import '../models/emotion.dart';
import 'crisis_detector.dart';
import 'emotion_lexicon.dart';

class EmotionEngine {
  const EmotionEngine._();

  static const int _negationWindow = 3;
  static const int _maxPhraseLength = 5;

  /// Bonificación de prioridad del léxico para frases multi-palabra: son
  /// señales más específicas que las palabras sueltas genéricas.
  static const double _phrasePriorityBonus = 1.25;

  /// Umbral mínimo de porcentaje para que una emoción entre al ranking.
  static const double _minRankPercentage = 1.5;

  static const Set<String> _clauseSeparators = {
    'pero',
    'aunque',
    'sino',
    'mientras',
    'además',
    'ademas',
    'entonces',
    'después',
    'despues',
    'luego',
    'también',
    'tambien',
    'porque',
    'y',
    'o',
    'e',
    'u',
  };

  static EmotionAnalysis analyze(String text) {
    if (text.trim().isEmpty) {
      return const EmotionAnalysis(
        rankings: [],
        confidence: 0,
        detectedKeywords: [],
        explanation: 'No hay texto suficiente para analizar.',
      );
    }

    final normalized = _normalize(text);
    final tokens = _tokenize(normalized);
    final scores = <String, double>{};
    final matchedKw = <String>{};
    final matchedByEmotion = <String, Set<String>>{};
    final lastPosition = <String, int>{};
    final used = List<bool>.filled(tokens.length, false);

    _matchPhrases(
      tokens,
      used,
      scores,
      matchedKw,
      matchedByEmotion,
      lastPosition,
    );

    for (var i = 0; i < tokens.length; i++) {
      if (used[i]) continue;
      final token = tokens[i];

      final entries = _entriesForToken(token);
      if (entries == null) continue;

      final negated = _isNegated(tokens, i);
      final multiplier = _getContextMultiplier(tokens, i);

      for (final entry in entries) {
        final baseWeight = entry.weight * multiplier;
        final effectiveWeight = negated ? baseWeight * 0.3 : baseWeight;

        scores[entry.emotionId] = (scores[entry.emotionId] ?? 0) + effectiveWeight;
        matchedKw.add(token);

        matchedByEmotion
            .putIfAbsent(entry.emotionId, () => <String>{})
            .add(token);
        lastPosition[entry.emotionId] = i;
      }
    }

    final override = _detectContextOverride(normalized, scores);
    if (override != null) {
      for (final entry in override.entries) {
        scores[entry.key] = (scores[entry.key] ?? 0) + entry.value;
      }
    }

    _applyCrisisOverride(text, scores);

    final ranked = _rankScores(scores, matchedByEmotion, lastPosition);
    final totalWeight = ranked.fold<double>(0, (s, e) => s + e.percentage);

    var confidence = _calculateConfidence(
      totalWeight,
      tokens.length,
      matchedKw.length,
    );

    // Penaliza la ambigüedad: si el top-2 está muy pegado, la detección es
    // menos confiable.
    if (ranked.length >= 2 &&
        ranked[0].percentage - ranked[1].percentage < 1.5) {
      confidence = double.parse(
        (confidence * 0.85).toStringAsFixed(1),
      );
    }

    final explanation =
        _buildExplanation(ranked, matchedKw, matchedByEmotion, confidence);

    return EmotionAnalysis(
      rankings: ranked,
      confidence: confidence,
      detectedKeywords: matchedKw.toList()..sort(),
      explanation: explanation,
    );
  }

  /// Devuelve la emoción dominante de un texto, o `null` si no se detectó nada.
  static DominantEmotion? dominant(String text) =>
      dominantFromAnalysis(analyze(text));

  /// Devuelve la emoción dominante a partir de un análisis ya calculado.
  static DominantEmotion? dominantFromAnalysis(EmotionAnalysis analysis) {
    if (analysis.rankings.isEmpty) return null;

    final top = analysis.rankings.first;
    final intensity =
        top.percentage / 100 * 0.6 + analysis.confidence / 100 * 0.4;

    return DominantEmotion(
      emotion: top.emotion,
      intensity: double.parse(intensity.clamp(0.0, 1.0).toStringAsFixed(2)),
      percentage: top.percentage,
    );
  }

  static void _matchPhrases(
    List<String> tokens,
    List<bool> used,
    Map<String, double> scores,
    Set<String> matchedKw,
    Map<String, Set<String>> matchedByEmotion,
    Map<String, int> lastPosition,
  ) {
    for (var i = 0; i < tokens.length; i++) {
      if (used[i]) continue;

      var matchedLength = 1;
      for (var len = _maxPhraseLength; len >= 2; len--) {
        if (i + len > tokens.length) continue;
        final phrase = tokens.sublist(i, i + len).join(' ');
        if (EmotionLexicon.keywords.containsKey(phrase)) {
          matchedLength = len;
          break;
        }
      }

      if (matchedLength == 1) continue;

      final phrase = tokens.sublist(i, i + matchedLength).join(' ');
      final entries = EmotionLexicon.keywords[phrase]!;
      final multiplier = _getContextMultiplier(tokens, i);

      // Las frases multi-palabra son más específicas y deben priorizar sobre
      // palabras sueltas genéricas.
      for (final entry in entries) {
        final weight = entry.weight * multiplier * _phrasePriorityBonus;
        scores[entry.emotionId] = (scores[entry.emotionId] ?? 0) + weight;
        matchedByEmotion
            .putIfAbsent(entry.emotionId, () => <String>{})
            .add(phrase);
        lastPosition[entry.emotionId] = i;
      }
      matchedKw.add(phrase);

      for (var k = i; k < i + matchedLength; k++) {
        used[k] = true;
      }
      i += matchedLength - 1;
    }
  }

  static String _normalize(String text) {
    var t = text.toLowerCase().trim();
    t = t.replaceAll(RegExp(r'[¿¡!?.;:,()\[\]{}\u00AB\u00BB\u2013\u2014\u2012\-]'), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }

  static List<String> _tokenize(String text) {
    return text.split(' ').where((t) => t.isNotEmpty).toList();
  }

  static bool _isNegated(List<String> tokens, int index) {
    final start = (index - _negationWindow).clamp(0, tokens.length);
    var negations = 0;

    for (var i = start; i < index; i++) {
      if (_clauseSeparators.contains(tokens[i])) {
        negations = 0;
        continue;
      }
      if (EmotionLexicon.negationWords.contains(tokens[i])) {
        negations++;
      }
    }

    return negations.isOdd;
  }

  static double _getContextMultiplier(List<String> tokens, int index) {
    var multiplier = 1.0;

    if (index > 0) {
      final prev = tokens[index - 1];
      final intens = EmotionLexicon.intensifiers[prev];
      if (intens != null) multiplier *= intens;
    }

    if (index > 1) {
      final twoBack = '${tokens[index - 2]} ${tokens[index - 1]}';
      final diminisher = EmotionLexicon.diminishers[twoBack];
      if (diminisher != null) multiplier *= diminisher;
    }

    if (index > 0) {
      final prev = tokens[index - 1];
      final diminisher = EmotionLexicon.diminishers[prev];
      if (diminisher != null) multiplier *= diminisher;
    }

    if (index < tokens.length - 1) {
      final next = tokens[index + 1];
      final intens = EmotionLexicon.intensifiers[next];
      if (intens != null) multiplier *= intens;
    }

    final token = tokens[index];
    if (_isSuperlative(token)) multiplier *= 1.4;

    return multiplier;
  }

  static bool _isSuperlative(String token) {
    return token.endsWith('ísimo') ||
        token.endsWith('ísima') ||
        token.endsWith('isimo') ||
        token.endsWith('isima');
  }

  /// Busca una palabra clave admitiendo su forma superlativa (p. ej.
  /// `tristísima` -> `triste`).
  static List<LexiconEntry>? _entriesForToken(String token) {
    final direct = EmotionLexicon.keywords[token];
    if (direct != null) return direct;

    const suffixes = ['ísima', 'ísimo', 'isima', 'isimo'];
    for (final suffix in suffixes) {
      if (!token.endsWith(suffix)) continue;
      final base = token.substring(0, token.length - suffix.length);
      if (base.isEmpty) return null;
      for (final ending in const ['e', 'o', 'a', '']) {
        final entries = EmotionLexicon.keywords['$base$ending'];
        if (entries != null) return entries;
      }
      break;
    }
    return null;
  }

  static List<EmotionScore> _rankScores(
    Map<String, double> scores,
    Map<String, Set<String>> matchedByEmotion,
    Map<String, int> lastPosition,
  ) {
    if (scores.isEmpty) return const [];

    final entries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold<double>(0, (s, e) => s + e.value);
    if (total == 0) return const [];

    final results = <EmotionScore>[];
    for (final entry in entries) {
      final emotion = emotionById(entry.key);
      if (emotion == null) continue;

      final percentage = (entry.value / total) * 100;
      if (percentage < _minRankPercentage) continue;

      results.add(EmotionScore(
        emotion: emotion,
        percentage: double.parse(percentage.toStringAsFixed(1)),
        matchedKeywords: const [],
      ));
    }

    // Resuelve conflictos entre emociones con puntuación casi idéntica:
    // gana la que tiene más palabras clave distintas y, en último término,
    // la que aparece más tarde en el texto (suele ser el estado real).
    results.sort((a, b) {
      final byScore = b.percentage.compareTo(a.percentage);
      if (byScore != 0) return byScore;
      final byKeywords = (matchedByEmotion[b.emotion.id]?.length ?? 0)
          .compareTo(matchedByEmotion[a.emotion.id]?.length ?? 0);
      if (byKeywords != 0) return byKeywords;
      return (lastPosition[b.emotion.id] ?? -1)
          .compareTo(lastPosition[a.emotion.id] ?? -1);
    });

    return results;
  }

  static double _calculateConfidence(
    double totalWeight,
    int totalTokens,
    int matchedTokens,
  ) {
    if (totalTokens == 0 || matchedTokens == 0) return 0;

    final density = matchedTokens / totalTokens;
    final weightFactor = (totalWeight / matchedTokens).clamp(0.0, 1.0);
    final diversity = matchedTokens >= 3 ? 1.0 : matchedTokens / 3;

    final raw = (density * 0.4 + weightFactor * 0.35 + diversity * 0.25);
    return double.parse((raw * 100).clamp(0, 100).toStringAsFixed(1));
  }

  static String _buildExplanation(
    List<EmotionScore> rankings,
    Set<String> matchedKw,
    Map<String, Set<String>> matchedByEmotion,
    double confidence,
  ) {
    if (rankings.isEmpty) {
      return 'No se detectaron emociones claras en el texto.';
    }

    final top3 = rankings.take(3).toList();
    final parts = <String>[];

    for (final score in top3) {
      final kw = matchedByEmotion[score.emotion.id];
      if (kw != null && kw.isNotEmpty) {
        final kwList = kw.take(3).join(', ');
        parts.add(
          '${score.emotion.name} (${score.percentage}%) por las palabras: $kwList',
        );
      } else {
        parts.add('${score.emotion.name} (${score.percentage}%)');
      }
    }

    final confText = confidence >= 70
        ? 'Alta'
        : confidence >= 40
            ? 'Media'
            : 'Baja';

    final buf = StringBuffer('Emociones detectadas: ');
    buf.write(parts.join('. '));
    buf.write('. Confianza: $confText ($confidence%).');

    if (matchedKw.isNotEmpty) {
      buf.write(' Se analizaron ${matchedKw.length} palabra(s) clave(s).');
    }

    return buf.toString();
  }

  static const Map<String, List<String>> _contextKeywords = {
    'tristeza': [
      'muerte', 'murió', 'murio', 'falleció', 'fallecio', 'morirse',
      'duelo', 'funeral', 'entierro', 'velorio', 'sepultura',
      'perder', 'perdí', 'perdi', 'perdido', 'perdida',
      'vacío', 'vacio', 'llorar', 'llorando', 'lloré', 'llore',
      'deprimido', 'deprimida', 'depresión', 'depresion',
      'desesperanza', 'desesperado', 'desesperada',
      'soledad', 'solo', 'sola', 'abandonado', 'abandonada',
      'hospital', 'enfermedad', 'cáncer', 'cancer', 'diagnóstico',
      'diagnostico', 'operación', 'operacion', 'quirófano',
      'accidente', 'golpe', 'fractura', 'hemorragia',
      'ruptura', 'separación', 'separacion', 'divorcio',
      'despedido', 'despedida', 'pierde', 'extravio',
      'ando re mal', 'estoy hecho polvo', 'estoy fatal',
      'no tengo energía', 'no tengo energia',
    ],
    'ansiedad': [
      'ataque de pánico', 'pánico', 'panico',
      'no puedo respirar', 'se me cierra', 'ahogo',
      'corazón acelerado', 'corazon acelerado', 'temblor',
      'insomnio', 'no puedo dormir', 'desvelo',
    ],
    'desesperanza': [
      'no tiene sentido', 'no vale la pena', 'para qué',
      'para que', 'ya no quiero', 'no aguanto', 'no soporto',
      'quisiera desaparecer', 'no quiero existir',
      'no doy más', 'no doy mas', 'todo me sale mal',
    ],
    'estres': [
      'no pude dormir', 'no duermo', 'sin dormir', 'dormir mal',
      'desvelo', 'desvelada', 'presión', 'presion',
      'presionado', 'presionada', 'agobiado', 'agobiada', 'agobio',
      'agobiante', 'sobrepasado', 'sobrepasada', 'mucho trabajo',
      'mucha carga', 'no me alcanza el tiempo', 'colapsado', 'colapsada',
      'tengo mil cosas', 'estoy hasta el cuello', 'al límite', 'al limite',
    ],
  };

  static const Set<String> _positiveEmotionIds = {
    'alegria', 'felicidad', 'amor', 'gratitud', 'esperanza',
    'calma', 'orgullo', 'motivacion', 'inspiracion',
    'entusiasmo', 'ternura', 'ilusion', 'alivio', 'optimismo',
    'confianza', 'diversion', 'paz',
  };

  static Map<String, double>? _detectContextOverride(
    String normalized,
    Map<String, double> currentScores,
  ) {
    final triggers = <String>[];
    final overrideScores = <String, double>{};

    for (final entry in _contextKeywords.entries) {
      for (final keyword in entry.value) {
        if (normalized.contains(keyword)) {
          triggers.add(keyword);
          switch (entry.key) {
            case 'tristeza':
              overrideScores['tristeza'] = (overrideScores['tristeza'] ?? 0) + 1.2;
              overrideScores['desesperanza'] = (overrideScores['desesperanza'] ?? 0) + 0.3;
              break;
            case 'ansiedad':
              overrideScores['ansiedad'] = (overrideScores['ansiedad'] ?? 0) + 1.2;
              overrideScores['miedo'] = (overrideScores['miedo'] ?? 0) + 0.4;
              break;
            case 'desesperanza':
              overrideScores['desesperanza'] = (overrideScores['desesperanza'] ?? 0) + 1.3;
              overrideScores['tristeza'] = (overrideScores['tristeza'] ?? 0) + 0.5;
              break;
            case 'estres':
              overrideScores['estres'] = (overrideScores['estres'] ?? 0) + 1.2;
              overrideScores['ansiedad'] = (overrideScores['ansiedad'] ?? 0) + 0.6;
              overrideScores['agotamiento'] = (overrideScores['agotamiento'] ?? 0) + 0.3;
              break;
          }
        }
      }
    }

    if (triggers.isEmpty) return null;

    for (final emotionId in _positiveEmotionIds) {
      if (overrideScores.containsKey(emotionId)) continue;
      final current = currentScores[emotionId];
      if (current != null && current > 0) {
        currentScores[emotionId] = current * 0.15;
      }
    }

    return overrideScores;
  }

  static void _applyCrisisOverride(String text, Map<String, double> scores) {
    final crisis = CrisisDetector.detect(text);
    if (!crisis.highRisk) return;

    scores['desesperanza'] = (scores['desesperanza'] ?? 0) + 12.0;
    scores['tristeza'] = (scores['tristeza'] ?? 0) + 4.0;
  }
}
