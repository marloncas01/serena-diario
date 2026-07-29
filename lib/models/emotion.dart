import 'package:flutter/material.dart';

enum EmotionCategory { positiva, negativa, mixta }

class EmotionDefinition {
  const EmotionDefinition({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.category,
  });

  final String id;
  final String name;
  final String emoji;
  final Color color;
  final EmotionCategory category;
}

class EmotionScore {
  const EmotionScore({
    required this.emotion,
    required this.percentage,
    required this.matchedKeywords,
  });

  final EmotionDefinition emotion;
  final double percentage;
  final List<String> matchedKeywords;
}

class EmotionKeyword {
  const EmotionKeyword(this.word, this.weight);

  final String word;
  final double weight;
}

class EmotionAnalysis {
  const EmotionAnalysis({
    required this.rankings,
    required this.confidence,
    required this.detectedKeywords,
    required this.explanation,
  });

  final List<EmotionScore> rankings;
  final double confidence;
  final List<String> detectedKeywords;
  final String explanation;
}

const List<EmotionDefinition> allEmotions = [
  EmotionDefinition(
    id: 'alegria',
    name: 'Alegría',
    emoji: '😄',
    color: Color(0xFFFFD54F),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'felicidad',
    name: 'Felicidad',
    emoji: '😊',
    color: Color(0xFFFFD5C2),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'amor',
    name: 'Amor',
    emoji: '❤️',
    color: Color(0xFFEF9A9A),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'gratitud',
    name: 'Gratitud',
    emoji: '🙏',
    color: Color(0xFFCE93D8),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'esperanza',
    name: 'Esperanza',
    emoji: '🌟',
    color: Color(0xFF81D4FA),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'calma',
    name: 'Calma',
    emoji: '😌',
    color: Color(0xFFBFE6D9),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'orgullo',
    name: 'Orgullo',
    emoji: '💪',
    color: Color(0xFFFFAB91),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'motivacion',
    name: 'Motivación',
    emoji: '🔥',
    color: Color(0xFFFF8A65),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'inspiracion',
    name: 'Inspiración',
    emoji: '✨',
    color: Color(0xFFFFE082),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'tristeza',
    name: 'Tristeza',
    emoji: '😔',
    color: Color(0xFFFCCFD6),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'soledad',
    name: 'Soledad',
    emoji: '🫥',
    color: Color(0xFFB0BEC5),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'vacio',
    name: 'Vacío',
    emoji: '🕳️',
    color: Color(0xFFCFD8DC),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'desesperanza',
    name: 'Desesperanza',
    emoji: '😞',
    color: Color(0xFF90A4AE),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'ansiedad',
    name: 'Ansiedad',
    emoji: '😰',
    color: Color(0xFFFFCC80),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'estres',
    name: 'Estrés',
    emoji: '😤',
    color: Color(0xFFFFAB91),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'miedo',
    name: 'Miedo',
    emoji: '😨',
    color: Color(0xFFE0E0E0),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'frustracion',
    name: 'Frustración',
    emoji: '😖',
    color: Color(0xFFFF8A80),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'enojo',
    name: 'Enojo',
    emoji: '😠',
    color: Color(0xFFEF5350),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'culpa',
    name: 'Culpa',
    emoji: '😥',
    color: Color(0xFFA1887F),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'vergüenza',
    name: 'Vergüenza',
    emoji: '😳',
    color: Color(0xFFF48FB1),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'confusion',
    name: 'Confusión',
    emoji: '😕',
    color: Color(0xFFB39DDB),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'agotamiento',
    name: 'Agotamiento',
    emoji: '😩',
    color: Color(0xFFBDBDBD),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'burnout',
    name: 'Burnout',
    emoji: '🫠',
    color: Color(0xFFA1887F),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'nostalgia',
    name: 'Nostalgia',
    emoji: '🥹',
    color: Color(0xFFCE93D8),
    category: EmotionCategory.mixta,
  ),
  EmotionDefinition(
    id: 'incertidumbre',
    name: 'Incertidumbre',
    emoji: '🤷',
    color: Color(0xFFB0BEC5),
    category: EmotionCategory.mixta,
  ),
];

EmotionDefinition? emotionById(String id) {
  for (final e in allEmotions) {
    if (e.id == id) return e;
  }
  return null;
}
