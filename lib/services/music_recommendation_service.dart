import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

class MusicRecommendation {
  const MusicRecommendation({
    required this.title,
    required this.spotifyUrl,
    required this.description,
    required this.emotion,
  });

  final String title;
  final String spotifyUrl;
  final String description;
  final String emotion;
}

class MusicRecommendationService {
  MusicRecommendationService._();
  static final MusicRecommendationService _instance =
      MusicRecommendationService._();
  factory MusicRecommendationService() => _instance;

  final _random = Random();

  static const _emotions = <String, List<MusicRecommendation>>{
    'tristeza': [
      MusicRecommendation(
        title: 'Sad Songs',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX7rOY2pLkXY3',
        description:
            'Canciones que abrazan la tristeza y te permiten sentir.',
        emotion: 'tristeza',
      ),
      MusicRecommendation(
        title: 'Chill Hits',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZDC5ieUZuaE',
        description:
            'Éxitos relajados para momentos de melancolía.',
        emotion: 'tristeza',
      ),
      MusicRecommendation(
        title: 'Peaceful Piano',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq5pBd',
        description:
            'Piano suave para acompañar tus momentos tristes.',
        emotion: 'tristeza',
      ),
      MusicRecommendation(
        title: 'Chillout Lounge',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZq8uCjDZS7',
        description:
            'Ambientes relajados para procesar emociones.',
        emotion: 'tristeza',
      ),
      MusicRecommendation(
        title: 'Chill Tracks',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX4Fmd0cnu6wF',
        description:
            'Canciones chill que te ayudan a desahogarte.',
        emotion: 'tristeza',
      ),
    ],
    'ansiedad': [
      MusicRecommendation(
        title: 'Relax & Unwind',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWYBO1MoTDhZI',
        description:
            'Música relajante para calmar la ansiedad.',
        emotion: 'ansiedad',
      ),
      MusicRecommendation(
        title: 'Meditation',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX10zKzsJ2jva',
        description:
            'Sesiones musicales para meditar y reducir la ansiedad.',
        emotion: 'ansiedad',
      ),
      MusicRecommendation(
        title: 'Lofi Beats',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
        description:
            'Beats lo-fi para tranquilizar tu mente.',
        emotion: 'ansiedad',
      ),
      MusicRecommendation(
        title: 'Mood Booster',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX1g0fEXnMSch',
        description:
            'Canciones que elevan tu ánimo y reducen la preocupación.',
        emotion: 'ansiedad',
      ),
      MusicRecommendation(
        title: 'Acoustic Chill',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWWEJlVGaZieg',
        description:
            'Acústicos suaves para calmar los nervios.',
        emotion: 'ansiedad',
      ),
    ],
    'estres': [
      MusicRecommendation(
        title: 'Lo-Fi Beats',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX0SM0LYsmbMT',
        description:
            'Beats lo-fi para liberar el estrés del día.',
        emotion: 'estres',
      ),
      MusicRecommendation(
        title: 'Chill Hits',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZDC5ieUZuaE',
        description:
            'Éxitos relajados para desconectar del estrés.',
        emotion: 'estres',
      ),
      MusicRecommendation(
        title: 'Peaceful Piano',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq5pBd',
        description:
            'Piano relajante para aliviar la tensión.',
        emotion: 'estres',
      ),
      MusicRecommendation(
        title: 'Chillout Lounge',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZq8uCjDZS7',
        description:
            'Ambientes de lounge para relajarte profundamente.',
        emotion: 'estres',
      ),
      MusicRecommendation(
        title: 'Deep Meditation',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX1i3eiOAngUS',
        description:
            'Meditación profunda para liberar el estrés acumulado.',
        emotion: 'estres',
      ),
    ],
    'concentracion': [
      MusicRecommendation(
        title: 'Deep Focus',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX5trt9i14X7j',
        description:
            'Música instrumental para concentrarte a fondo.',
        emotion: 'concentracion',
      ),
      MusicRecommendation(
        title: 'Lofi Beats',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
        description:
            'Beats lo-fi ideales para estudiar y trabajar.',
        emotion: 'concentracion',
      ),
      MusicRecommendation(
        title: 'Lo-Fi Beats',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX0SM0LYsmbMT',
        description:
            'Lo-fi para mantener el foco y la productividad.',
        emotion: 'concentracion',
      ),
      MusicRecommendation(
        title: 'Chill Tracks',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX4Fmd0cnu6wF',
        description:
            'Canciones sin distracciones para mantenerte en zona.',
        emotion: 'concentracion',
      ),
      MusicRecommendation(
        title: 'Chill Hits',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZDC5ieUZuaE',
        description:
            'Hits relajados que no interrumpen tu concentración.',
        emotion: 'concentracion',
      ),
    ],
    'dormir': [
      MusicRecommendation(
        title: 'Sleep',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DXbYM3nMM0oPk',
        description:
            'Sonidos suaves para acompañar tu descanso.',
        emotion: 'dormir',
      ),
      MusicRecommendation(
        title: 'Sleep Sounds',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX4JCPYoGoGNz',
        description:
            'Sonidos ambientales para conciliar el sueño.',
        emotion: 'dormir',
      ),
      MusicRecommendation(
        title: 'Deep Sleep',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX5JhFESzQjLi',
        description:
            'Música profunda para un sueño reparador.',
        emotion: 'dormir',
      ),
      MusicRecommendation(
        title: 'Chillout Lounge',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZq8uCjDZS7',
        description:
            'Ambientes relajantes para dormir tranquilo.',
        emotion: 'dormir',
      ),
      MusicRecommendation(
        title: 'Peaceful Piano',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq5pBd',
        description:
            'Piano tranquilo para acompañar el sueño.',
        emotion: 'dormir',
      ),
    ],
    'felicidad': [
      MusicRecommendation(
        title: 'Happy Hits!',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DXdPec7aJc1Po',
        description:
            'Los hits más felices para alegrar tu día.',
        emotion: 'felicidad',
      ),
      MusicRecommendation(
        title: 'Mood Booster',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX1g0fEXnMSch',
        description:
            'Canciones que elevan tu estado de ánimo al máximo.',
        emotion: 'felicidad',
      ),
      MusicRecommendation(
        title: 'Good Vibes',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX76PYB5c69Y3',
        description:
            'Buenas vibras para disfrutar la felicidad.',
        emotion: 'felicidad',
      ),
      MusicRecommendation(
        title: 'Feel Good Indie Rock',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX9XIFQuFvzM4',
        description:
            'Indie rock que te hace sentir bien.',
        emotion: 'felicidad',
      ),
      MusicRecommendation(
        title: 'Workout Mix',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX1lVhptIYRq8',
        description:
            'Energía pura para celebrar tus buenas moments.',
        emotion: 'felicidad',
      ),
    ],
    'motivacion': [
      MusicRecommendation(
        title: 'Workout Mix',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX1lVhptIYRq8',
        description:
            'Energía intensa para impulsar tu motivación.',
        emotion: 'motivacion',
      ),
      MusicRecommendation(
        title: 'Good Vibes',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX76PYB5c69Y3',
        description:
            'Vibras positivas para mantenerte motivado.',
        emotion: 'motivacion',
      ),
      MusicRecommendation(
        title: 'Mood Booster',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX1g0fEXnMSch',
        description:
            'Sube tu ánimo y recupera la motivación.',
        emotion: 'motivacion',
      ),
      MusicRecommendation(
        title: 'Feel Good Indie Rock',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX9XIFQuFvzM4',
        description:
            'Rock indie inspirador para nuevos retos.',
        emotion: 'motivacion',
      ),
      MusicRecommendation(
        title: 'Beast Mode',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX0XUsuxWHRQd',
        description:
            'Modo bestia para alcanzar tus metas.',
        emotion: 'motivacion',
      ),
    ],
    'calma': [
      MusicRecommendation(
        title: 'Chill Hits',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZDC5ieUZuaE',
        description:
            'Hits relajados para disfrutar la calma.',
        emotion: 'calma',
      ),
      MusicRecommendation(
        title: 'Peaceful Piano',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq5pBd',
        description:
            'Piano sereno para momentos de paz.',
        emotion: 'calma',
      ),
      MusicRecommendation(
        title: 'Relax & Unwind',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWYBO1MoTDhZI',
        description:
            'Relájate y desconecta con música suave.',
        emotion: 'calma',
      ),
      MusicRecommendation(
        title: 'Meditation',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX10zKzsJ2jva',
        description:
            'Música para meditar y encontrar la calma interior.',
        emotion: 'calma',
      ),
      MusicRecommendation(
        title: 'Acoustic Chill',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWWEJlVGaZieg',
        description:
            'Acústicos relajantes para un ambiente de paz.',
        emotion: 'calma',
      ),
    ],
  };

  static const _moodToEmotion = <String, String>{
    'Feliz': 'felicidad',
    'En calma': 'calma',
    'Normal': 'calma',
    'Triste': 'tristeza',
    'Cansada': 'estres',
    'triste': 'tristeza',
    'tristeza': 'tristeza',
    'ansiedad': 'ansiedad',
    'ansioso': 'ansiedad',
    'ansiosa': 'ansiedad',
    'estres': 'estres',
    'estresado': 'estres',
    'estresada': 'estres',
    'enojado': 'estres',
    'enojada': 'estres',
    'enojo': 'estres',
    'frustrado': 'estres',
    'frustrada': 'estres',
    'frustracion': 'estres',
    'concentracion': 'concentracion',
    'enfoque': 'concentracion',
    'estudiar': 'concentracion',
    'trabajar': 'concentracion',
    'dormir': 'dormir',
    'sueno': 'dormir',
    'cansado': 'dormir',
    'cansada': 'dormir',
    'agotado': 'dormir',
    'agotada': 'dormir',
    'felicidad': 'felicidad',
    'feliz': 'felicidad',
    'alegre': 'felicidad',
    'alegria': 'felicidad',
    'contento': 'felicidad',
    'contenta': 'felicidad',
    'motivacion': 'motivacion',
    'motivado': 'motivacion',
    'motivada': 'motivacion',
    'inspirado': 'motivacion',
    'inspirada': 'motivacion',
    'energia': 'motivacion',
    'calma': 'calma',
    'calmado': 'calma',
    'calmada': 'calma',
    'tranquilo': 'calma',
    'tranquila': 'calma',
    'sereno': 'calma',
    'serena': 'calma',
    'paz': 'calma',
  };

  MusicRecommendation recommendByEmotion(String emotion) {
    final key = emotion.toLowerCase().trim();
    final mapped = _moodToEmotion[key] ?? key;
    final recommendations = _emotions[mapped];

    if (recommendations != null && recommendations.isNotEmpty) {
      return recommendations[_random.nextInt(recommendations.length)];
    }

    final allKeys = _emotions.keys.toList();
    final fallbackKey = allKeys[_random.nextInt(allKeys.length)];
    final fallbackList = _emotions[fallbackKey]!;
    return fallbackList[_random.nextInt(fallbackList.length)];
  }

  Future<bool> openRecommendation(MusicRecommendation rec) async {
    final uri = Uri.parse(rec.spotifyUrl);

    try {
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      }
    } catch (_) {}

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (launched) return true;
    } catch (_) {}

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
      );
      return launched;
    } catch (_) {
      return false;
    }
  }

  List<String> getEmotions() => _emotions.keys.toList();
}
