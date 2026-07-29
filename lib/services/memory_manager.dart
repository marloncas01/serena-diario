import '../models/memory_item.dart';
import 'memory_extractor.dart';

class MemoryManager {
  MemoryManager() : _memories = [];

  final List<MemoryItem> _memories;

  List<MemoryItem> get all =>
      List.unmodifiable(_memories.where((m) => m.active));

  int get count => all.length;

  // ── Add ──

  List<MemoryItem> addFromText(String text) {
    final result = MemoryExtractor.extract(text);
    final added = <MemoryItem>[];

    for (final item in result.items) {
      final existing = _findSimilar(item);
      if (existing != null) {
        _refreshMemory(existing, text);
        added.add(existing);
      } else {
        _memories.add(item);
        added.add(item);
      }
    }

    return added;
  }

  void addItem(MemoryItem item) {
    final existing = _findSimilar(item);
    if (existing != null) {
      _refreshMemory(existing, item.originalText);
    } else {
      _memories.add(item);
    }
  }

  // ── Update ──

  void updateItem(String id, {String? newValue, double? newConfidence}) {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final old = _memories[index];
    _memories[index] = old.copyWith(
      value: newValue,
      confidence: newConfidence,
    );
  }

  // ── Merge ──

  int mergeSimilar() {
    int merged = 0;
    final toRemove = <int>[];

    for (var i = 0; i < _memories.length; i++) {
      if (toRemove.contains(i)) continue;
      if (!_memories[i].active) continue;

      for (var j = i + 1; j < _memories.length; j++) {
        if (toRemove.contains(j)) continue;
        if (!_memories[j].active) continue;

        if (_areSimilar(_memories[i], _memories[j])) {
          _memories[i] = _mergeTwo(_memories[i], _memories[j]);
          toRemove.add(j);
          merged++;
        }
      }
    }

    for (var i = toRemove.length - 1; i >= 0; i--) {
      _memories.removeAt(toRemove[i]);
    }

    return merged;
  }

  // ── Increment mentions ──

  void incrementMention(String id) {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final old = _memories[index];
    _memories[index] = old.copyWith(
      timesMentioned: old.timesMentioned + 1,
      lastMention: DateTime.now(),
    );
  }

  // ── Deactivate old ──

  int deactivateOlderThan(Duration age) {
    int deactivated = 0;
    final cutoff = DateTime.now().subtract(age);

    for (var i = 0; i < _memories.length; i++) {
      if (!_memories[i].active) continue;
      if (_memories[i].lastMention.isBefore(cutoff) &&
          _memories[i].importance < 0.3) {
        _memories[i] = _memories[i].copyWith(active: false);
        deactivated++;
      }
    }

    return deactivated;
  }

  void deactivate(String id) {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _memories[index] = _memories[index].copyWith(active: false);
  }

  void reactivate(String id) {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _memories[index] = _memories[index].copyWith(active: true);
  }

  // ── Search ──

  List<MemoryItem> search(String query) {
    if (query.trim().isEmpty) return const [];

    final lower = query.toLowerCase();
    final words = lower.split(' ').where((w) => w.length >= 3).toList();
    if (words.isEmpty) return const [];

    final results = <_ScoredMemory>[];

    for (final memory in _memories.where((m) => m.active)) {
      var score = 0;
      final valueLower = memory.value.toLowerCase();

      if (valueLower.contains(lower)) {
        score += 10;
      }

      for (final word in words) {
        if (valueLower.contains(word)) score += 3;
        for (final kw in memory.keywords) {
          if (kw.toLowerCase().contains(word)) score += 2;
        }
      }

      if (score > 0) {
        results.add(_ScoredMemory(memory, score));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.map((r) => r.memory).toList();
  }

  List<MemoryItem> getByCategory(MemoryCategory category) {
    return all
        .where((m) => m.category == category)
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));
  }

  List<MemoryItem> getByCategories(List<MemoryCategory> categories) {
    return all
        .where((m) => categories.contains(m.category))
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));
  }

  List<MemoryItem> searchByKeywords(List<String> keywords) {
    final lower = keywords.map((k) => k.toLowerCase()).toSet();
    final results = <_ScoredMemory>[];

    for (final memory in all) {
      var score = 0;
      for (final kw in memory.keywords) {
        if (lower.contains(kw.toLowerCase())) score += 3;
      }
      final valueLower = memory.value.toLowerCase();
      for (final kw in lower) {
        if (valueLower.contains(kw)) score += 2;
      }
      if (score > 0) {
        results.add(_ScoredMemory(memory, score));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.map((r) => r.memory).toList();
  }

  // ── Retrieval ──

  List<MemoryItem> getRecent({int limit = 10}) {
    final sorted = all.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  List<MemoryItem> getMostImportant({int limit = 10}) {
    final sorted = all.toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));
    return sorted.take(limit).toList();
  }

  List<MemoryItem> getMostMentioned({int limit = 10}) {
    final sorted = all.toList()
      ..sort((a, b) => b.timesMentioned.compareTo(a.timesMentioned));
    return sorted.take(limit).toList();
  }

  List<MemoryItem> getRecentByCategory(
    MemoryCategory category, {
    int limit = 5,
  }) {
    final filtered = all.where((m) => m.category == category).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.take(limit).toList();
  }

  MemoryItem? getById(String id) {
    try {
      return _memories.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Smart follow-up ──

  static const _followUpCategories = {
    MemoryCategory.persona,
    MemoryCategory.familia,
    MemoryCategory.relacion,
    MemoryCategory.mascota,
    MemoryCategory.evento,
    MemoryCategory.meta,
    MemoryCategory.trabajo,
    MemoryCategory.estudio,
    MemoryCategory.salud,
  };

  static const _followUpTemplates = <MemoryCategory, String>{
    MemoryCategory.persona: '¿Cómo sigue %s?',
    MemoryCategory.familia: '¿Cómo está tu familia, en especial %s?',
    MemoryCategory.relacion: '¿Cómo va todo con %s?',
    MemoryCategory.mascota: '¿Cómo está %s?',
    MemoryCategory.evento: '¿Cómo te fue con %s?',
    MemoryCategory.meta: '¿Cómo va tu objetivo de %s?',
    MemoryCategory.trabajo: '¿Cómo sigue todo en %s?',
    MemoryCategory.estudio: '¿Cómo va tu estudio de %s?',
    MemoryCategory.salud: '¿Cómo sigue tu salud, %s?',
  };

  List<String> getFollowUpSuggestions({int maxSuggestions = 2}) {
    final now = DateTime.now();
    final suggestions = <String>[];

    final candidates = all
        .where((m) =>
            _followUpCategories.contains(m.category) &&
            m.importance > 0.3 &&
            m.timesMentioned >= 1)
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));

    for (final memory in candidates) {
      if (suggestions.length >= maxSuggestions) break;

      final daysSince = now.difference(memory.lastMention).inDays;
      if (daysSince < 3) continue;

      final template = _followUpTemplates[memory.category];
      if (template == null) continue;

      final value = memory.value.length > 30
          ? memory.value.substring(0, 30)
          : memory.value;
      suggestions.add(template.replaceAll('%s', value));
    }

    return suggestions;
  }

  List<MemoryItem> getContextFor(String text) {
    final extracted = MemoryExtractor.extract(text);
    final categoryIds = extracted.items.map((i) => i.category).toSet();

    final related = <MemoryItem>[];
    for (final memory in all) {
      if (categoryIds.contains(memory.category)) {
        related.add(memory);
        continue;
      }
      for (final item in extracted.items) {
        if (_areRelated(memory, item)) {
          related.add(memory);
          break;
        }
      }
    }

    return related
      ..sort((a, b) => b.importance.compareTo(a.importance));
  }

  // ── Stats ──

  Map<MemoryCategory, int> getCategoryCounts() {
    final counts = <MemoryCategory, int>{};
    for (final memory in all) {
      counts[memory.category] = (counts[memory.category] ?? 0) + 1;
    }
    return counts;
  }

  double get averageImportance {
    if (all.isEmpty) return 0;
    final total = all.fold<double>(0, (s, m) => s + m.importance);
    return total / all.length;
  }

  // ── Serialization (prepared for Hive) ──

  List<Map<String, dynamic>> toMapList() =>
      _memories.map((m) => m.toMap()).toList();

  void loadFromMapList(List<Map<dynamic, dynamic>> maps) {
    _memories.clear();
    for (final map in maps) {
      _memories.add(MemoryItem.fromMap(map));
    }
  }

  // ── Private helpers ──

  MemoryItem? _findSimilar(MemoryItem candidate) {
    for (final existing in _memories) {
      if (!existing.active) continue;
      if (existing.category != candidate.category) continue;
      if (_areSimilar(existing, candidate)) return existing;
    }
    return null;
  }

  bool _areSimilar(MemoryItem a, MemoryItem b) {
    if (a.category != b.category) return false;

    final wordsA = a.value.toLowerCase().split(' ').toSet();
    final wordsB = b.value.toLowerCase().split(' ').toSet();
    final intersection = wordsA.intersection(wordsB);
    final union = wordsA.union(wordsB);

    if (union.isEmpty) return false;
    final jaccard = intersection.length / union.length;
    return jaccard >= 0.4;
  }

  bool _areRelated(MemoryItem a, MemoryItem b) {
    if (a.category == b.category) return true;

    final wordsA = a.value.toLowerCase().split(' ').toSet();
    final wordsB = b.value.toLowerCase().split(' ').toSet();
    final kwA = a.keywords.map((k) => k.toLowerCase()).toSet();
    final kwB = b.keywords.map((k) => k.toLowerCase()).toSet();

    final wordIntersection = wordsA.intersection(wordsB);
    final kwIntersection = kwA.intersection(kwB);

    return wordIntersection.length >= 2 || kwIntersection.length >= 2;
  }

  void _refreshMemory(MemoryItem existing, String newText) {
    final index = _memories.indexOf(existing);
    if (index == -1) return;

    final newKeywords = MemoryExtractor.extract(newText)
        .items
        .expand((i) => i.keywords)
        .toList();

    final mergedKeywords = {
      ...existing.keywords,
      ...newKeywords,
    }.toList();

    _memories[index] = existing.copyWith(
      lastMention: DateTime.now(),
      timesMentioned: existing.timesMentioned + 1,
      keywords: mergedKeywords,
    );
  }

  MemoryItem _mergeTwo(MemoryItem a, MemoryItem b) {
    final higherConfidence =
        a.confidence >= b.confidence ? a.confidence : b.confidence;
    final totalMentions = a.timesMentioned + b.timesMentioned;
    final laterDate =
        a.lastMention.isAfter(b.lastMention) ? a.lastMention : b.lastMention;
    final earlierDate =
        a.createdAt.isBefore(b.createdAt) ? a.createdAt : b.createdAt;

    final mergedKeywords = {
      ...a.keywords,
      ...b.keywords,
    }.toList();

    final mergedValue = a.value.length >= b.value.length ? a.value : b.value;

    return MemoryItem(
      id: a.id,
      category: a.category,
      value: mergedValue,
      confidence: higherConfidence,
      createdAt: earlierDate,
      lastMention: laterDate,
      timesMentioned: totalMentions,
      active: true,
      originalText: a.originalText,
      keywords: mergedKeywords,
    );
  }
}

class _ScoredMemory {
  const _ScoredMemory(this.memory, this.score);

  final MemoryItem memory;
  final int score;
}
