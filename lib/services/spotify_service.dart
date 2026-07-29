import 'package:url_launcher/url_launcher.dart';
import 'music_recommendation_service.dart';

class SpotifyService {
  SpotifyService._();
  static final SpotifyService _instance = SpotifyService._();
  factory SpotifyService() => _instance;

  final _recService = MusicRecommendationService();

  Future<bool> openPlaylistByEmotion(String mood) async {
    final recommendation = _recService.recommendByEmotion(mood);
    return _recService.openRecommendation(recommendation);
  }

  Future<void> openSearch(String query) async {
    final encoded = Uri.encodeComponent(query);
    await _launch('https://open.spotify.com/search/$encoded');
  }

  Future<void> openTrack(String trackId) async {
    const spans = <String, String>{
      'Spotify:track:': 'https://open.spotify.com/track/',
      'Spotify:album:': 'https://open.spotify.com/album/',
      'Spotify:playlist:': 'https://open.spotify.com/playlist/',
    };
    final clean = spans.entries.fold(
      trackId,
      (id, entry) => id.replaceAll(entry.key, entry.value),
    );
    if (clean.startsWith('http')) {
      await _launch(clean);
    } else {
      await _launch('https://open.spotify.com/search/${Uri.encodeComponent(clean)}');
    }
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
