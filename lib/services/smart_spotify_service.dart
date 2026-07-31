import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import '../models/memory_item.dart';
import 'music_recommendation_service.dart';

class SmartMusicRecommendation {
  const SmartMusicRecommendation({
    required this.recommendation,
    required this.reason,
    required this.emotionLabel,
    required this.genre,
    required this.playlistName,
  });

  final MusicRecommendation recommendation;
  final String reason;
  final String emotionLabel;
  final String genre;
  final String playlistName;
}

class PlaylistUsage {
  const PlaylistUsage({
    required this.spotifyUrl,
    required this.title,
    required this.openedAt,
  });

  final String spotifyUrl;
  final String title;
  final DateTime openedAt;

  Map<String, dynamic> toMap() => {
        'url': spotifyUrl,
        'title': title,
        'date': openedAt.toIso8601String(),
      };

  factory PlaylistUsage.fromMap(Map<String, dynamic> m) => PlaylistUsage(
        spotifyUrl: m['url'] ?? '',
        title: m['title'] ?? '',
        openedAt: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
      );
}

class SmartSpotifyService {
  SmartSpotifyService._();
  static final SmartSpotifyService _instance = SmartSpotifyService._();
  factory SmartSpotifyService() => _instance;

  static const _usageKey = 'spotify_playlist_usage_v1';
  final _recService = MusicRecommendationService();

  final _genreMap = const {
    'Sad Songs': 'Pop melancólico',
    'Chill Hits': 'Pop relajado',
    'Peaceful Piano': 'Clásica / Piano',
    'Chillout Lounge': 'Electrónica chill',
    'Chill Tracks': 'Lo-fi / Indie',
    'Relax & Unwind': 'Ambient',
    'Meditation': 'Meditación',
    'Lofi Beats': 'Lo-fi Hip Hop',
    'Mood Booster': 'Pop energético',
    'Acoustic Chill': 'Acústico',
    'Lo-Fi Beats': 'Lo-fi',
    'Deep Focus': 'Instrumental',
    'Deep Meditation': 'Meditación profunda',
    'Sleep': 'Sonidos para dormir',
    'Sleep Sounds': 'Sonidos ambientales',
    'Deep Sleep': 'Ambient nocturno',
    'Happy Hits!': 'Pop feliz',
    'Good Vibes': 'Reggae / Pop',
    'Feel Good Indie Rock': 'Indie Rock',
    'Workout Mix': 'Electrónica / Workout',
    'Beast Mode': 'Rock / Energía',
  };

  final _emotionLabels = const {
    'tristeza': 'tristeza',
    'ansiedad': 'ansiedad',
    'estres': 'estrés',
    'concentracion': 'concentración',
    'dormir': 'necesidad de descanso',
    'felicidad': 'felicidad',
    'motivacion': 'motivación',
    'calma': 'calma',
  };

  SmartMusicRecommendation getSmartRecommendation({
    required String currentMood,
    List<JournalEntry>? recentEntries,
    List<MemoryItem>? memories,
  }) {
    final base = _recService.recommendByEmotion(currentMood);
    final emotionKey = _resolveEmotionKey(currentMood);
    final genre = _genreMap[base.title] ?? 'Variado';
    final emotionLabel = _emotionLabels[emotionKey] ?? emotionKey;
    final reason = _buildReason(emotionKey, recentEntries, memories);

    return SmartMusicRecommendation(
      recommendation: base,
      reason: reason,
      emotionLabel: emotionLabel,
      genre: genre,
      playlistName: base.title,
    );
  }

  SmartMusicRecommendation getAlternative({
    required String currentMood,
    required String excludeUrl,
  }) {
    final emotionKey = _resolveEmotionKey(currentMood);
    var result = _recService.recommendByEmotion(emotionKey);
    var attempts = 0;
    while (result.spotifyUrl == excludeUrl && attempts < 5) {
      result = _recService.recommendByEmotion(emotionKey);
      attempts++;
    }
    return SmartMusicRecommendation(
      recommendation: result,
      reason: 'Otra opción para acompañar tu ${_emotionLabels[emotionKey] ?? "estado de ánimo"}.',
      emotionLabel: _emotionLabels[emotionKey] ?? emotionKey,
      genre: _genreMap[result.title] ?? 'Variado',
      playlistName: result.title,
    );
  }

  Future<void> recordUsage(MusicRecommendation rec) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_usageKey) ?? [];
    final usage = PlaylistUsage(
      spotifyUrl: rec.spotifyUrl,
      title: rec.title,
      openedAt: DateTime.now(),
    );
    list.add(_encodeUsage(usage));
    if (list.length > 50) {
      final cutoff = DateTime.now().subtract(const Duration(days: 90));
      list.removeWhere((s) {
        final u = _decodeUsage(s);
        return u.openedAt.isBefore(cutoff);
      });
    }
    await prefs.setStringList(_usageKey, list);
  }

  Future<List<PlaylistUsage>> getRecentUsage({int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_usageKey) ?? [];
    final usages = list.map(_decodeUsage).toList();
    usages.sort((a, b) => b.openedAt.compareTo(a.openedAt));
    return usages.take(limit).toList();
  }

  Future<bool> wasRecentlyUsed(String spotifyUrl) async {
    final recent = await getRecentUsage(limit: 20);
    final cutoff = DateTime.now().subtract(const Duration(days: 3));
    return recent.any(
      (u) => u.spotifyUrl == spotifyUrl && u.openedAt.isAfter(cutoff),
    );
  }

  String _resolveEmotionKey(String mood) {
    const emotionMap = {
      'feliz': 'felicidad',
      'en calma': 'calma',
      'normal': 'calma',
      'triste': 'tristeza',
      'cansada': 'estres',
    };
    return emotionMap[mood.toLowerCase()] ?? mood.toLowerCase();
  }

  String _buildReason(
    String emotionKey,
    List<JournalEntry>? entries,
    List<MemoryItem>? memories,
  ) {
    final parts = <String>[];

    if (entries != null && entries.isNotEmpty) {
      final recent = entries.take(3).toList();
      final hasAnxiety = recent.any(
        (e) => e.note.toLowerCase().contains('ansiedad') ||
            e.note.toLowerCase().contains('nervioso') ||
            e.note.toLowerCase().contains('preocup'),
      );
      final hasSadness = recent.any(
        (e) => e.note.toLowerCase().contains('triste') ||
            e.note.toLowerCase().contains('mal') ||
            e.note.toLowerCase().contains('llor'),
      );
      final hasTired = recent.any(
        (e) => e.note.toLowerCase().contains('cansad') ||
            e.note.toLowerCase().contains('agotad') ||
            e.note.toLowerCase().contains('dormir'),
      );
      final hasStress = recent.any(
        (e) => e.note.toLowerCase().contains('estrés') ||
            e.note.toLowerCase().contains('presión') ||
            e.note.toLowerCase().contains('trabajo'),
      );

      if (hasAnxiety && emotionKey == 'ansiedad') {
        parts.add('escribiste que te sientes ansioso/a');
      } else if (hasSadness && emotionKey == 'tristeza') {
        parts.add('escribiste que hoy no fue tu mejor día');
      } else if (hasTired && emotionKey == 'dormir') {
        parts.add('mencionaste que estás cansado/a');
      } else if (hasStress && emotionKey == 'estres') {
        parts.add('escribiste sobre el estrés del día');
      }
    }

    if (memories != null && memories.isNotEmpty) {
      final personal = memories.where(
        (m) => m.importance > 0.4,
      ).toList();
      if (personal.isNotEmpty) {
        final m = personal.first;
        parts.add('sé que ${m.value} es importante para ti');
      }
    }

    if (parts.isEmpty) {
      final emotionLabel = _emotionLabels[emotionKey] ?? 'tu estado de ánimo';
      return 'acompañar tu $emotionLabel';
    }

    return 'porque ${parts.first}';
  }

  String _encodeUsage(PlaylistUsage u) =>
      '${u.spotifyUrl}|${u.title}|${u.openedAt.toIso8601String()}';

  PlaylistUsage _decodeUsage(String s) {
    final parts = s.split('|');
    return PlaylistUsage(
      spotifyUrl: parts.isNotEmpty ? parts[0] : '',
      title: parts.length > 1 ? parts[1] : '',
      openedAt: parts.length > 2
          ? (DateTime.tryParse(parts[2]) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
