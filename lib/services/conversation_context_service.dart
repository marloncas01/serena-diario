import '../models/emotion.dart';
import '../models/memory_item.dart';

class ConversationContext {
  const ConversationContext({
    required this.memoriasRelacionadas,
    required this.emocionesHistorial,
    required this.tendenciaEmocional,
    required this.temasRecurrentes,
    required this.fraseContextual,
  });

  final List<String> memoriasRelacionadas;
  final List<String> emocionesHistorial;
  final String tendenciaEmocional;
  final List<String> temasRecurrentes;
  final String fraseContextual;
}

class ConversationContextService {
  ConversationContext buildContext({
    required String currentText,
    required List<MemoryItem> memories,
    required List<EmotionAnalysis> history,
  }) {
    final relatedMemories = _findRelatedMemories(currentText, memories);
    final recentEmotions = _getRecentEmotions(history);
    final trend = _analyzeTrend(history);
    final recurringTopics = _findRecurringTopics(currentText, memories);
    final phrase = _buildContextualPhrase(
      currentText,
      relatedMemories,
      recentEmotions,
      trend,
      history,
    );

    return ConversationContext(
      memoriasRelacionadas: relatedMemories,
      emocionesHistorial: recentEmotions,
      tendenciaEmocional: trend,
      temasRecurrentes: recurringTopics,
      fraseContextual: phrase,
    );
  }

  List<String> _findRelatedMemories(String text, List<MemoryItem> memories) {
    final results = <String>[];
    final lower = text.toLowerCase();
    final words = lower.split(' ').where((w) => w.length >= 3).toSet();

    for (final m in memories) {
      if (!m.active) continue;
      final valueLower = m.value.toLowerCase();
      bool related = false;
      for (final word in words) {
        if (valueLower.contains(word)) {
          related = true;
          break;
        }
      }
      if (!related) {
        for (final kw in m.keywords) {
          if (words.any((w) => w.contains(kw.toLowerCase()) ||
              kw.toLowerCase().contains(w))) {
            related = true;
            break;
          }
        }
      }
      if (related) {
        results.add(m.value);
      }
    }
    return results.take(3).toList();
  }

  List<String> _getRecentEmotions(List<EmotionAnalysis> history) {
    if (history.isEmpty) return [];
    final recent = history.length > 5
        ? history.sublist(history.length - 5)
        : history;
    final counts = <String, int>{};
    for (final a in recent) {
      for (final s in a.rankings.take(2)) {
        counts[s.emotion.id] = (counts[s.emotion.id] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .take(3)
        .map((e) => emotionById(e.key)?.name ?? e.key)
        .toList();
  }

  String _analyzeTrend(List<EmotionAnalysis> history) {
    if (history.length < 4) return 'neutral';
    final mid = history.length ~/ 2;
    final first = _posRatio(history.sublist(0, mid));
    final second = _posRatio(history.sublist(mid));
    if (second - first > 0.15) return 'mejorando';
    if (first - second > 0.15) return 'empeorando';
    return 'estable';
  }

  double _posRatio(List<EmotionAnalysis> analyses) {
    int pos = 0, total = 0;
    for (final a in analyses) {
      for (final s in a.rankings) {
        total++;
        if (s.emotion.category == EmotionCategory.positiva) pos++;
      }
    }
    return total > 0 ? pos / total : 0;
  }

  List<String> _findRecurringTopics(String text, List<MemoryItem> memories) {
    final topics = <String>[];
    final lower = text.toLowerCase();
    for (final m in memories) {
      if (!m.active) continue;
      if (m.timesMentioned >= 2 && lower.isNotEmpty) {
        final valueLower = m.value.toLowerCase();
        final words = lower.split(' ').where((w) => w.length >= 3);
        if (words.any((w) => valueLower.contains(w))) {
          topics.add(m.value);
        }
      }
    }
    return topics.take(2).toList();
  }

  String _buildContextualPhrase(
    String text,
    List<String> relatedMemories,
    List<String> recentEmotions,
    String trend,
    List<EmotionAnalysis> history,
  ) {
    if (history.isEmpty) return '';

    final parts = <String>[];

    if (relatedMemories.isNotEmpty) {
      parts.add('Recuerdo que me contaste sobre "${relatedMemories.first}".');
    }

    if (trend == 'mejorando') {
      parts.add('He notado que últimamente tus emociones van en una mejor dirección.');
    } else if (trend == 'empeorando') {
      parts.add('Parece que los últimos días han sido más difíciles.');
    }

    if (recentEmotions.isNotEmpty) {
      parts.add(
        'Tus emociones más recientes incluyen '
        '${recentEmotions.join(" y ")}.',
      );
    }

    return parts.join(' ');
  }
}
