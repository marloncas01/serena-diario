import '../models/mood.dart';
import '../models/emotion.dart';

class MoodEmotionMapper {
  MoodEmotionMapper._();

  static const _moodToEmotions = <String, List<String>>{
    'Feliz': ['Felicidad', 'Alegría', 'Orgullo'],
    'En calma': ['Calma', 'Serenidad', 'Paz'],
    'Normal': ['Neutral', 'Tranquilidad'],
    'Triste': ['Tristeza', 'Soledad', 'Melancolía'],
    'Cansada': ['Agotamiento', 'Fatiga', 'Burnout'],
  };

  static const _emotionToMood = <String, String>{
    'Felicidad': 'Feliz',
    'Alegría': 'Feliz',
    'Orgullo': 'Feliz',
    'Amor': 'Feliz',
    'Gratitud': 'Feliz',
    'Esperanza': 'Feliz',
    'Calma': 'En calma',
    'Serenidad': 'En calma',
    'Paz': 'En calma',
    'Tranquilidad': 'Normal',
    'Tristeza': 'Triste',
    'Soledad': 'Triste',
    'Melancolía': 'Triste',
    'Desesperanza': 'Triste',
    'Vacío': 'Triste',
    'Ansiedad': 'Cansada',
    'Estrés': 'Cansada',
    'Miedo': 'Cansada',
    'Frustración': 'Cansada',
    'Agotamiento': 'Cansada',
    'Burnout': 'Cansada',
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
