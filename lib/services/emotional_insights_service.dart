import '../models/emotion.dart';
import '../models/memory_item.dart';
import '../models/journal_entry.dart';

class Insight {
  const Insight({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.icono,
  });

  final String titulo;
  final String descripcion;
  final String categoria;
  final String icono;
}

class EmotionalInsightsService {
  List<Insight> generateInsights({
    required List<EmotionAnalysis> history,
    required List<JournalEntry> entries,
    required List<MemoryItem> memories,
  }) {
    if (history.isEmpty || entries.isEmpty) return const [];

    final insights = <Insight>[];
    insights.addAll(_temporalInsights(entries, history));
    insights.addAll(_writingInsights(entries, history));
    insights.addAll(_emotionContentInsights(history, memories));
    insights.addAll(_memoryInsights(memories));
    insights.addAll(_peopleInsights(memories, history));
    insights.addAll(_repeatedEmotionInsights(history));
    insights.addAll(_trendInsights(history));
    insights.sort((a, b) => b.categoria.compareTo(a.categoria));
    return insights.take(8).toList();
  }

  List<Insight> _temporalInsights(
    List<JournalEntry> entries,
    List<EmotionAnalysis> history,
  ) {
    final insights = <Insight>[];
    if (entries.length < 3) return insights;

    final dayEmotions = <int, List<String>>{};
    final oldestFirst = entries.reversed.toList();
    final n = oldestFirst.length < history.length
        ? oldestFirst.length
        : history.length;
    for (var i = 0; i < n; i++) {
      final day = oldestFirst[i].createdAt.weekday;
      final topEmotions = history[i].rankings
          .take(2)
          .map((s) => s.emotion.id)
          .toList();
      dayEmotions.putIfAbsent(day, () => []).addAll(topEmotions);
    }

    final dayNames = {
      1: 'lunes', 2: 'martes', 3: 'miércoles',
      4: 'jueves', 5: 'viernes', 6: 'sábado', 7: 'domingo',
    };

    final stressDays = <String>[];
    final joyDays = <String>[];
    for (final entry in dayEmotions.entries) {
      final stressCount = entry.value
          .where((e) => e == 'estres' || e == 'ansiedad')
          .length;
      final joyCount = entry.value
          .where((e) => e == 'alegria' || e == 'felicidad')
          .length;
      if (stressCount >= 2) stressDays.add(dayNames[entry.key] ?? '');
      if (joyCount >= 2) joyDays.add(dayNames[entry.key] ?? '');
    }

    if (stressDays.isNotEmpty) {
      insights.add(Insight(
        titulo: 'Patrón temporal',
        descripcion: 'Los ${stressDays.join(", ")} sueles sentir más estrés.',
        categoria: 'temporal',
        icono: '📅',
      ));
    }
    if (joyDays.isNotEmpty) {
      insights.add(Insight(
        titulo: 'Días positivos',
        descripcion: 'Los ${joyDays.join(", ")} tienden a ser más alegres.',
        categoria: 'temporal',
        icono: '🌟',
      ));
    }
    return insights;
  }

  List<Insight> _writingInsights(
    List<JournalEntry> entries,
    List<EmotionAnalysis> history,
  ) {
    final insights = <Insight>[];
    if (entries.length < 5) return insights;

    int highWordEntries = 0;
    int highWordPositive = 0;
    int lowWordEntries = 0;
    int lowWordPositive = 0;

    final oldestFirst = entries.reversed.toList();
    final n = oldestFirst.length < history.length
        ? oldestFirst.length
        : history.length;
    for (var i = 0; i < n; i++) {
      final wordCount = oldestFirst[i].note.split(RegExp(r'\s+')).length;
      final topEmotions = history[i].rankings.take(2).toList();
      final hasPositive = topEmotions.any(
        (s) => s.emotion.category == EmotionCategory.positiva,
      );

      if (wordCount > 100) {
        highWordEntries++;
        if (hasPositive) highWordPositive++;
      } else {
        lowWordEntries++;
        if (hasPositive) lowWordPositive++;
      }
    }

    if (highWordEntries > 0 && highWordPositive / highWordEntries > 0.5) {
      insights.add(const Insight(
        titulo: 'Escritura y emoción',
        descripcion:
            'Cuando escribes más de 100 palabras, tu estado emocional tiende a mejorar.',
        categoria: 'escritura',
        icono: '✍️',
      ));
    }
    if (lowWordEntries > 0 && lowWordPositive / lowWordEntries < 0.3) {
      insights.add(const Insight(
        titulo: 'Entradas cortas',
        descripcion:
            'Las entradas más cortas suelen asociarse con emociones negativas.',
        categoria: 'escritura',
        icono: '📝',
      ));
    }
    return insights;
  }

  List<Insight> _emotionContentInsights(
    List<EmotionAnalysis> history,
    List<MemoryItem> memories,
  ) {
    final insights = <Insight>[];
    final allKeywords = <String>[];
    for (final a in history) {
      allKeywords.addAll(a.detectedKeywords);
    }
    if (allKeywords.isEmpty) return insights;

    final keywordFreq = <String, int>{};
    for (final kw in allKeywords) {
      keywordFreq[kw] = (keywordFreq[kw] ?? 0) + 1;
    }
    final topKeywords = keywordFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final physicalWords = {'caminar', 'correr', 'ejercicio', 'caminata', 'gimnasio'};
    final musicWords = {'música', 'canción', 'escuchar', 'cantar'};

    final hasPhysical = topKeywords.any(
      (e) => physicalWords.contains(e.key.toLowerCase()),
    );
    final hasMusic = topKeywords.any(
      (e) => musicWords.contains(e.key.toLowerCase()),
    );

    if (hasPhysical) {
      final anxietyCount = _countEmotion(history, 'ansiedad');
      if (anxietyCount > 2) {
        insights.add(const Insight(
          titulo: 'Actividad física',
          descripcion:
              'Tu ansiedad disminuye cuando mencionas actividad física.',
          categoria: 'emocional',
          icono: '🏃',
        ));
      }
    }
    if (hasMusic) {
      insights.add(const Insight(
        titulo: 'Música',
        descripcion:
            'La música parece tener un efecto positivo en tu estado de ánimo.',
        categoria: 'emocional',
        icono: '🎵',
      ));
    }

    final familyMemories = memories.where(
      (m) => m.category == MemoryCategory.familia ||
          m.category == MemoryCategory.relacion,
    );
    if (familyMemories.length >= 2) {
      final posCount = _countPositiveEmotions(history);
      if (posCount > history.length * 0.3) {
        insights.add(const Insight(
          titulo: 'Familia y relaciones',
          descripcion:
              'La mayoría de tus entradas positivas hablan de tu familia o seres queridos.',
          categoria: 'emocional',
          icono: '❤️',
        ));
      }
    }

    return insights;
  }

  List<Insight> _memoryInsights(List<MemoryItem> memories) {
    final insights = <Insight>[];
    final mostMentioned = memories
        .where((m) => m.active && m.timesMentioned >= 2)
        .toList()
      ..sort((a, b) => b.timesMentioned.compareTo(a.timesMentioned));

    if (mostMentioned.isNotEmpty) {
      final top = mostMentioned.first;
      insights.add(Insight(
        titulo: 'Tema recurrente',
        descripcion:
            'Has mencionado "${top.value}" ${top.timesMentioned} veces. '
            'Parece ser algo importante para ti.',
        categoria: 'memoria',
        icono: '🔁',
      ));
    }
    return insights;
  }

  int _countEmotion(List<EmotionAnalysis> history, String emotionId) {
    int count = 0;
    for (final a in history) {
      for (final s in a.rankings.take(2)) {
        if (s.emotion.id == emotionId) count++;
      }
    }
    return count;
  }

  int _countPositiveEmotions(List<EmotionAnalysis> history) {
    int count = 0;
    for (final a in history) {
      for (final s in a.rankings.take(2)) {
        if (s.emotion.category == EmotionCategory.positiva) count++;
      }
    }
    return count;
  }

  List<Insight> _peopleInsights(
    List<MemoryItem> memories,
    List<EmotionAnalysis> history,
  ) {
    final insights = <Insight>[];
    final people = memories
        .where((m) =>
            m.active &&
            (m.category == MemoryCategory.persona ||
                m.category == MemoryCategory.familia ||
                m.category == MemoryCategory.relacion))
        .toList()
      ..sort((a, b) => b.timesMentioned.compareTo(a.timesMentioned));

    if (people.length >= 2) {
      final names = people.take(2).map((p) => p.value).toList();
      insights.add(Insight(
        titulo: 'Personas importantes',
        descripcion:
            '${names.join(" y ")} son personas frecuentes en tus escritos.',
        categoria: 'personas',
        icono: '👥',
      ));
    }

    if (people.isNotEmpty && people.first.timesMentioned >= 3) {
      final associated = _findAssociatedEmotion(
        people.first.value,
        history,
      );
      if (associated != null) {
        insights.add(Insight(
          titulo: 'Vínculo emocional',
          descripcion:
              'Cuando mencionas a "${people.first.value}", '
              'sueles sentir $associated.',
          categoria: 'personas',
          icono: '💫',
        ));
      }
    }

    return insights;
  }

  String? _findAssociatedEmotion(
    String personName,
    List<EmotionAnalysis> history,
  ) {
    final emotionCounts = <String, int>{};
    for (final a in history) {
      if (a.detectedKeywords.any(
        (kw) => kw.toLowerCase().contains(personName.toLowerCase()),
      )) {
        for (final s in a.rankings.take(1)) {
          emotionCounts[s.emotion.name] =
              (emotionCounts[s.emotion.name] ?? 0) + 1;
        }
      }
    }
    if (emotionCounts.isEmpty) return null;
    final sorted = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  List<Insight> _repeatedEmotionInsights(List<EmotionAnalysis> history) {
    final insights = <Insight>[];
    if (history.length < 4) return insights;

    final emotionCounts = <String, int>{};
    for (final a in history) {
      if (a.rankings.isNotEmpty) {
        final top = a.rankings.first.emotion;
        emotionCounts[top.name] = (emotionCounts[top.name] ?? 0) + 1;
      }
    }

    final total = history.length;
    for (final entry in emotionCounts.entries) {
      if (entry.value >= 3 && entry.value / total >= 0.4) {
        insights.add(Insight(
          titulo: 'Emoción recurrente',
          descripcion:
              '"${entry.key}" aparece en ${entry.value} de $total entradas. '
              'Es una emoción muy presente en tu vida.',
          categoria: 'patrón',
          icono: '🔄',
        ));
        break;
      }
    }

    final negCount = emotionCounts.entries
        .where((e) => _isNegative(e.key))
        .fold<int>(0, (sum, e) => sum + e.value);
    if (negCount >= 4 && negCount / total >= 0.5) {
      insights.add(const Insight(
        titulo: 'Tendencia emocional',
        descripcion:
            'Las emociones negativas han predominado recientemente. '
            'Recuerda que esto es temporal.',
        categoria: 'patrón',
        icono: '🌊',
      ));
    }

    return insights;
  }

  List<Insight> _trendInsights(List<EmotionAnalysis> history) {
    final insights = <Insight>[];
    if (history.length < 6) return insights;

    final mid = history.length ~/ 2;
    final firstHalf = history.sublist(0, mid);
    final secondHalf = history.sublist(mid);

    final firstPos = _positiveRatio(firstHalf);
    final secondPos = _positiveRatio(secondHalf);

    if (secondPos - firstPos > 0.2) {
      insights.add(const Insight(
        titulo: 'Mejorando',
        descripcion:
            'Tus emociones positivas han aumentado recientemente. '
            'Estás en un buen camino.',
        categoria: 'tendencia',
        icono: '📈',
      ));
    } else if (firstPos - secondPos > 0.2) {
      insights.add(const Insight(
        titulo: 'Atención',
        descripcion:
            'Las emociones negativas han aumentado un poco. '
            '¿Qué ha cambiado recientemente?',
        categoria: 'tendencia',
        icono: '⚠️',
      ));
    }

    return insights;
  }

  double _positiveRatio(List<EmotionAnalysis> analyses) {
    int pos = 0, total = 0;
    for (final a in analyses) {
      for (final s in a.rankings.take(2)) {
        total++;
        if (s.emotion.category == EmotionCategory.positiva) pos++;
      }
    }
    return total > 0 ? pos / total : 0;
  }

  bool _isNegative(String emotionName) {
    const negatives = {
      'tristeza', 'soledad', 'vacío', 'desesperanza', 'ansiedad',
      'estrés', 'miedo', 'frustración', 'enojo', 'culpa',
      'vergüenza', 'agotamiento', 'burnout',
    };
    return negatives.contains(emotionName.toLowerCase());
  }
}
