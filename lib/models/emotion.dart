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
    emoji: '😌',
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
    emoji: '😢',
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
    emoji: '😵',
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
    emoji: '😤',
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
    emoji: '😔',
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
  EmotionDefinition(
    id: 'entusiasmo',
    name: 'Entusiasmo',
    emoji: '🤩',
    color: Color(0xFFFFB74D),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'ternura',
    name: 'Ternura',
    emoji: '🥹',
    color: Color(0xFFF8BBD0),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'ilusion',
    name: 'Ilusión',
    emoji: '✨',
    color: Color(0xFFE1BEE7),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'alivio',
    name: 'Alivio',
    emoji: '😮‍💨',
    color: Color(0xFFA5D6A7),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'optimismo',
    name: 'Optimismo',
    emoji: '🌞',
    color: Color(0xFFFFF59D),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'confianza',
    name: 'Confianza',
    emoji: '💙',
    color: Color(0xFF90CAF9),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'diversion',
    name: 'Diversión',
    emoji: '😂',
    color: Color(0xFFFFF176),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'paz',
    name: 'Paz',
    emoji: '🕊️',
    color: Color(0xFFB2DFDB),
    category: EmotionCategory.positiva,
  ),
  EmotionDefinition(
    id: 'vulnerabilidad',
    name: 'Vulnerabilidad',
    emoji: '🫣',
    color: Color(0xFFFFCCBC),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'irritabilidad',
    name: 'Irritabilidad',
    emoji: '😒',
    color: Color(0xFFE57373),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'inseguridad',
    name: 'Inseguridad',
    emoji: '😟',
    color: Color(0xFFA0AEC0),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'decepcion',
    name: 'Decepción',
    emoji: '😞',
    color: Color(0xFFBCAAA4),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'aburrimiento',
    name: 'Aburrimiento',
    emoji: '😑',
    color: Color(0xFFCFD8DC),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'cansancio',
    name: 'Cansancio',
    emoji: '😴',
    color: Color(0xFFB0BEC5),
    category: EmotionCategory.negativa,
  ),
  EmotionDefinition(
    id: 'melancolia',
    name: 'Melancolía',
    emoji: '🥀',
    color: Color(0xFF9575CD),
    category: EmotionCategory.mixta,
  ),
  EmotionDefinition(
    id: 'curiosidad',
    name: 'Curiosidad',
    emoji: '🤔',
    color: Color(0xFF80DEEA),
    category: EmotionCategory.mixta,
  ),
  EmotionDefinition(
    id: 'sorpresa',
    name: 'Sorpresa',
    emoji: '😲',
    color: Color(0xFF80CBC4),
    category: EmotionCategory.mixta,
  ),
  EmotionDefinition(
    id: 'anticipacion',
    name: 'Anticipación',
    emoji: '🎢',
    color: Color(0xFFFFAB40),
    category: EmotionCategory.mixta,
  ),
  EmotionDefinition(
    id: 'neutral',
    name: 'Neutral',
    emoji: '😐',
    color: Color(0xFF9E9E9E),
    category: EmotionCategory.mixta,
  ),
];

/// Emoción dominante de una entrada, derivada del análisis emocional.
class DominantEmotion {
  const DominantEmotion({
    required this.emotion,
    required this.intensity,
    required this.percentage,
  });

  final EmotionDefinition emotion;

  /// Intensidad normalizada entre 0.0 y 1.0.
  final double intensity;

  /// Porcentaje que la emoción representa sobre el total detectado (0-100).
  final double percentage;
}

EmotionDefinition? emotionById(String id) {
  for (final e in allEmotions) {
    if (e.id == id) return e;
  }
  return null;
}

/// Emoción neutral de respaldo para etiquetas desconocidas o vacías.
final EmotionDefinition neutralEmotion = emotionById('neutral')!;

/// Resuelve una etiqueta guardada en `JournalEntry.mood` a su emoción
/// equivalente. Entiende tanto los moods antiguos (Feliz, En calma, Normal,
/// Triste, Cansada) como los nombres de las emociones actuales, manteniendo
/// compatibilidad con entradas ya guardadas.
EmotionDefinition emotionForLabel(String label) {
  final trimmed = label.trim();
  if (trimmed.isEmpty) return neutralEmotion;

  for (final emotion in allEmotions) {
    if (emotion.name == trimmed) return emotion;
  }

  return switch (trimmed) {
    'Feliz' => emotionById('felicidad')!,
    'En calma' => emotionById('calma')!,
    'Normal' => neutralEmotion,
    'Triste' => emotionById('tristeza')!,
    'Cansada' => emotionById('cansancio')!,
    _ => neutralEmotion,
  };
}
