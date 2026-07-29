import '../models/emotion.dart';
import '../models/journal_entry.dart';

class WeeklySummary {
  const WeeklySummary({
    required this.entradas,
    required this.emocionPredominante,
    required this.cambioEsperanza,
    required this.momentosAlegria,
    required this.rachaEscritura,
    required this.descripcion,
  });

  final int entradas;
  final String emocionPredominante;
  final String cambioEsperanza;
  final int momentosAlegria;
  final int rachaEscritura;
  final String descripcion;
}

class MonthlySummary {
  const MonthlySummary({
    required this.avances,
    required this.cambioTristeza,
    required this.cambioPositivas,
    required this.aspectoTrabajar,
    required this.felicitacion,
    required this.descripcion,
  });

  final String avances;
  final String cambioTristeza;
  final String cambioPositivas;
  final String aspectoTrabajar;
  final String felicitacion;
  final String descripcion;
}

class JournalSummaryService {
  WeeklySummary generateWeekly({
    required List<EmotionAnalysis> history,
    required List<JournalEntry> entries,
  }) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekEntries = entries
        .where((e) => e.createdAt.isAfter(weekAgo))
        .toList();
    final weekHistory = _matchHistoryToEntries(weekEntries, entries, history);

    if (weekEntries.isEmpty) {
      return const WeeklySummary(
        entradas: 0,
        emocionPredominante: 'Sin datos',
        cambioEsperanza: 'Sin datos',
        momentosAlegria: 0,
        rachaEscritura: 0,
        descripcion: 'Esta semana no escribiste. '
            '¿Qué tal si hoy abres tu diario?',
      );
    }

    final emotionCounts = <String, int>{};
    int esperanzaCount = 0;

    for (final a in weekHistory) {
      for (final s in a.rankings.take(2)) {
        emotionCounts[s.emotion.id] = (emotionCounts[s.emotion.id] ?? 0) + 1;
        if (s.emotion.id == 'esperanza') esperanzaCount++;
      }
    }

    final sorted = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final predominant = sorted.isNotEmpty
        ? (emotionById(sorted.first.key)?.name ?? 'Desconocida')
        : 'Desconocida';

    final alegriaCount = (emotionCounts['alegria'] ?? 0) +
        (emotionCounts['felicidad'] ?? 0);

    final racha = _calculateCurrentStreak(entries);

    String esperanzaDesc;
    if (esperanzaCount > 2) {
      esperanzaDesc = 'Hubo un incremento notable de esperanza.';
    } else if (esperanzaCount > 0) {
      esperanzaDesc = 'Aparecieron momentos de esperanza.';
    } else {
      esperanzaDesc = 'La esperanza no fue muy prominente esta semana.';
    }

    final desc = _buildWeeklyDescription(
      weekEntries.length,
      predominant,
      alegriaCount,
      racha,
    );

    return WeeklySummary(
      entradas: weekEntries.length,
      emocionPredominante: predominant,
      cambioEsperanza: esperanzaDesc,
      momentosAlegria: alegriaCount,
      rachaEscritura: racha,
      descripcion: desc,
    );
  }

  MonthlySummary generateMonthly({
    required List<EmotionAnalysis> history,
    required List<JournalEntry> entries,
  }) {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    final monthEntries = entries
        .where((e) => e.createdAt.isAfter(monthAgo))
        .toList();
    final monthHistory = _matchHistoryToEntries(monthEntries, entries, history);

    if (monthEntries.isEmpty) {
      return const MonthlySummary(
        avances: 'Sin datos este mes.',
        cambioTristeza: 'Sin datos.',
        cambioPositivas: 'Sin datos.',
        aspectoTrabajar: 'Escribe más para que pueda conocerte mejor.',
        felicitacion: '',
        descripcion: 'Este mes no hubo entradas en tu diario.',
      );
    }

    final emotionCounts = <String, int>{};
    int totalNeg = 0;
    int totalPos = 0;

    for (final a in monthHistory) {
      for (final s in a.rankings.take(2)) {
        emotionCounts[s.emotion.id] = (emotionCounts[s.emotion.id] ?? 0) + 1;
        if (s.emotion.category == EmotionCategory.positiva) totalPos++;
        if (s.emotion.category == EmotionCategory.negativa) totalNeg++;
      }
    }

    final tristezaCount = emotionCounts['tristeza'] ?? 0;
    final total = totalPos + totalNeg;

    String avances;
    if (monthEntries.length >= 15) {
      avances = 'Este mes mostraste avances importantes. '
          'Escribiste ${monthEntries.length} veces.';
    } else if (monthEntries.length >= 5) {
      avances = 'Este mes escribiste ${monthEntries.length} veces. '
          'Sigue así para conocerme mejor.';
    } else {
      avances = 'Escribiste poco este mes, pero cada entrada cuenta.';
    }

    String tristezaDesc;
    if (total > 0 && tristezaCount / total < 0.15) {
      tristezaDesc = 'La tristeza disminuyó este mes.';
    } else if (total > 0 && tristezaCount / total > 0.3) {
      tristezaDesc = 'La tristeza sigue siendo un aspecto presente.';
    } else {
      tristezaDesc = 'La tristeza se mantuvo en niveles moderados.';
    }

    String positivasDesc;
    if (total > 0 && totalPos / total > 0.5) {
      positivasDesc = 'Aparecieron más emociones positivas que el mes pasado.';
    } else if (total > 0 && totalPos / total > 0.3) {
      positivasDesc = 'Las emociones positivas estuvieron presentes.';
    } else {
      positivasDesc = 'Las emociones positivas necesitan más espacio.';
    }

    String aspecto;
    if ((emotionCounts['ansiedad'] ?? 0) > 3) {
      aspecto = 'La ansiedad sigue siendo un aspecto para trabajar.';
    } else if ((emotionCounts['estres'] ?? 0) > 3) {
      aspecto = 'El estrés ha sido recurrente.';
    } else if ((emotionCounts['tristeza'] ?? 0) > 3) {
      aspecto = 'La tristeza necesita atención.';
    } else {
      aspecto = 'Sigue cultivando tu bienestar emocional.';
    }

    String felicitacion = '';
    if (monthEntries.length >= 20) {
      felicitacion = 'Felicitaciones por mantener el hábito este mes.';
    } else if (monthEntries.length >= 10) {
      felicitacion = 'Buen trabajo escribiendo este mes.';
    }

    final desc = '$avances $tristezaDesc $positivasDesc';

    return MonthlySummary(
      avances: avances,
      cambioTristeza: tristezaDesc,
      cambioPositivas: positivasDesc,
      aspectoTrabajar: aspecto,
      felicitacion: felicitacion,
      descripcion: desc,
    );
  }

  List<EmotionAnalysis> _matchHistoryToEntries(
    List<JournalEntry> target,
    List<JournalEntry> all,
    List<EmotionAnalysis> history,
  ) {
    if (history.isEmpty || all.isEmpty) return [];
    final targetIds = target.map((e) => e.id).toSet();
    final result = <EmotionAnalysis>[];
    for (var i = 0; i < all.length && i < history.length; i++) {
      if (targetIds.contains(all[i].id)) {
        result.add(history[i]);
      }
    }
    return result;
  }

  int _calculateCurrentStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;
    final sorted = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final uniqueDays = sorted
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    int streak = 0;
    DateTime expected = todayNorm;

    for (final day in uniqueDays) {
      if (day == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (day.isAfter(expected)) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  String _buildWeeklyDescription(
    int entries,
    String predominant,
    int alegria,
    int racha,
  ) {
    final parts = <String>[];
    parts.add('Esta semana escribiste $entries '
        '${entries == 1 ? "vez" : "veces"}.');

    if (predominant != 'Desconocida') {
      parts.add('Predominó la $predominant.');
    }

    if (alegria > 0) {
      parts.add('Detectamos $alegria '
          '${alegria == 1 ? "momento" : "momentos"} de alegría.');
    }

    if (racha >= 3) {
      parts.add('Lograste mantener una racha de $racha días.');
    }

    return parts.join(' ');
  }
}
