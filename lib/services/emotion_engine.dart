import '../models/emotion.dart';
import 'emotion_lexicon.dart';

class EmotionEngine {
  const EmotionEngine._();

  static const int _negationWindow = 3;

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

    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];

      final entries = EmotionLexicon.keywords[token];
      if (entries == null) continue;

      final negated = _isNegated(tokens, i);
      final multiplier = _getContextMultiplier(tokens, i);

      for (final entry in entries) {
        final baseWeight = entry.weight * multiplier;
        final effectiveWeight = negated ? baseWeight * 0.3 : baseWeight;

        final current = scores[entry.emotionId] ?? 0;
        scores[entry.emotionId] = current + effectiveWeight;
        matchedKw.add(token);

        matchedByEmotion
            .putIfAbsent(entry.emotionId, () => <String>{})
            .add(token);
      }
    }

    final override = _detectContextOverride(normalized, scores);
    if (override != null) {
      for (final entry in override.entries) {
        scores[entry.key] = (scores[entry.key] ?? 0) + entry.value;
      }
    }

    final ranked = _rankScores(scores);
    final totalWeight = ranked.fold<double>(0, (s, e) => s + e.percentage);

    final confidence = _calculateConfidence(
      totalWeight,
      tokens.length,
      matchedKw.length,
    );

    final explanation =
        _buildExplanation(ranked, matchedKw, matchedByEmotion, confidence);

    return EmotionAnalysis(
      rankings: ranked,
      confidence: confidence,
      detectedKeywords: matchedKw.toList()..sort(),
      explanation: explanation,
    );
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
    for (var i = start; i < index; i++) {
      if (EmotionLexicon.negationWords.contains(tokens[i])) return true;
    }
    return false;
  }

  static double _getContextMultiplier(List<String> tokens, int index) {
    var multiplier = 1.0;

    if (index > 0) {
      final prev = tokens[index - 1];
      final intens = EmotionLexicon.intensifiers[prev];
      if (intens != null) {
        multiplier *= intens;
        return multiplier;
      }
    }

    if (index > 1) {
      final twoBack = '${tokens[index - 2]} ${tokens[index - 1]}';
      final diminisher = EmotionLexicon.diminishers[twoBack];
      if (diminisher != null) {
        multiplier *= diminisher;
        return multiplier;
      }
    }

    if (index > 0) {
      final prev = tokens[index - 1];
      final diminisher = EmotionLexicon.diminishers[prev];
      if (diminisher != null) {
        multiplier *= diminisher;
      }
    }

    return multiplier;
  }

  static List<EmotionScore> _rankScores(Map<String, double> scores) {
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
      if (percentage < 1.0) continue;

      results.add(EmotionScore(
        emotion: emotion,
        percentage: double.parse(percentage.toStringAsFixed(1)),
        matchedKeywords: const [],
      ));
    }

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
    ],
  };

  static const Set<String> _positiveEmotionIds = {
    'alegria', 'felicidad', 'amor', 'gratitud', 'esperanza',
    'calma', 'orgullo', 'motivacion', 'inspiracion',
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
          if (entry.key == 'tristeza') {
            overrideScores['tristeza'] = (overrideScores['tristeza'] ?? 0) + 1.2;
            overrideScores['desesperanza'] = (overrideScores['desesperanza'] ?? 0) + 0.3;
          } else if (entry.key == 'ansiedad') {
            overrideScores['ansiedad'] = (overrideScores['ansiedad'] ?? 0) + 1.2;
            overrideScores['miedo'] = (overrideScores['miedo'] ?? 0) + 0.4;
          } else if (entry.key == 'desesperanza') {
            overrideScores['desesperanza'] = (overrideScores['desesperanza'] ?? 0) + 1.3;
            overrideScores['tristeza'] = (overrideScores['tristeza'] ?? 0) + 0.5;
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
}
