import '../models/mood.dart';
import '../models/emotion.dart';

class MoodEmotionMapper {
  MoodEmotionMapper._();

  static const _moodToEmotions = <String, List<String>>{
    'Feliz': [
      'Felicidad',
      'Alegría',
      'Orgullo',
      'Entusiasmo',
      'Ilusión',
      'Optimismo',
      'Diversión',
      'Ternura',
      'Anticipación',
    ],
    'En calma': [
      'Calma',
      'Serenidad',
      'Paz',
      'Alivio',
      'Confianza',
    ],
    'Normal': ['Neutral', 'Tranquilidad', 'Curiosidad', 'Aburrimiento'],
    'Triste': [
      'Tristeza',
      'Soledad',
      'Melancolía',
      'Vulnerabilidad',
      'Decepción',
      'Inseguridad',
    ],
    'Cansada': [
      'Agotamiento',
      'Fatiga',
      'Burnout',
      'Irritabilidad',
      'Cansancio',
    ],
  };

  static const _emotionToMood = <String, String>{
    'Felicidad': 'Feliz',
    'Alegría': 'Feliz',
    'Orgullo': 'Feliz',
    'Amor': 'Feliz',
    'Gratitud': 'Feliz',
    'Esperanza': 'Feliz',
    'Entusiasmo': 'Feliz',
    'Ilusión': 'Feliz',
    'Optimismo': 'Feliz',
    'Diversión': 'Feliz',
    'Ternura': 'Feliz',
    'Anticipación': 'Feliz',
    'Calma': 'En calma',
    'Serenidad': 'En calma',
    'Paz': 'En calma',
    'Alivio': 'En calma',
    'Confianza': 'En calma',
    'Tranquilidad': 'Normal',
    'Curiosidad': 'Normal',
    'Aburrimiento': 'Normal',
    'Tristeza': 'Triste',
    'Soledad': 'Triste',
    'Melancolía': 'Triste',
    'Desesperanza': 'Triste',
    'Vacío': 'Triste',
    'Vulnerabilidad': 'Triste',
    'Decepción': 'Triste',
    'Inseguridad': 'Triste',
    'Ansiedad': 'Cansada',
    'Estrés': 'Cansada',
    'Miedo': 'Cansada',
    'Frustración': 'Cansada',
    'Agotamiento': 'Cansada',
    'Burnout': 'Cansada',
    'Irritabilidad': 'Cansada',
    'Cansancio': 'Cansada',
    'Culpa': 'Triste',
    'Vergüenza': 'Triste',
    'Confusión': 'Normal',
    'Nostalgia': 'Triste',
    'Incertidumbre': 'Normal',
    'Motivación': 'Feliz',
    'Inspiración': 'Feliz',
  };

  static Mood moodFromEmotion(String emotionName) {
    final moodName = _emotionToMood[emotionName];
    if (moodName != null) return moodByName(moodName);
    return moods[2];
  }

  static String moodFromEmotionAnalysis(EmotionAnalysis analysis) {
    if (analysis.rankings.isEmpty) return 'Normal';
    final top = analysis.rankings.first;
    final mapped = _emotionToMood[top.emotion.name];
    return mapped ?? 'Normal';
  }

  static List<String> emotionKeywordsForMood(String moodName) {
    return _moodToEmotions[moodName] ?? ['Neutral'];
  }
}
