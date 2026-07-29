import '../models/emotion.dart';
import '../models/memory_item.dart';
import '../models/journal_entry.dart';

class EmotionalProfile {
  const EmotionalProfile({
    required this.emocionPredominante,
    required this.nivelAnsiedad,
    required this.frecuenciaTristeza,
    required this.frecuenciaAlegria,
    required this.horaFrecuente,
    required this.diaFrecuente,
    required this.promedioPalabras,
    required this.estabilidadEmocional,
    required this.porcentajePositivas,
    required this.porcentajeNegativas,
    required this.personasMencionadas,
    required this.problemasFrecuentes,
    required this.temasRepetitivos,
    required this.nivelProgreso,
    required this.fortalezas,
    required this.aspectosTrabajar,
  });

  final String emocionPredominante;
  final double nivelAnsiedad;
  final double frecuenciaTristeza;
  final double frecuenciaAlegria;
  final int horaFrecuente;
  final int diaFrecuente;
  final double promedioPalabras;
  final double estabilidadEmocional;
  final double porcentajePositivas;
  final double porcentajeNegativas;
  final List<String> personasMencionadas;
  final List<String> problemasFrecuentes;
  final List<String> temasRepetitivos;
  final double nivelProgreso;
  final List<String> fortalezas;
  final List<String> aspectosTrabajar;
}

class EmotionalProfileService {
  EmotionalProfile generate({
    required List<EmotionAnalysis> history,
    required List<MemoryItem> memories,
    required List<JournalEntry> entries,
  }) {
    if (history.isEmpty) {
      return _emptyProfile();
    }

    final emotionCounts = <String, int>{};
    final emotionScores = <String, double>{};
    int totalPositive = 0;
    int totalNegative = 0;

    for (final analysis in history) {
      for (final score in analysis.rankings) {
        final id = score.emotion.id;
        emotionCounts[id] = (emotionCounts[id] ?? 0) + 1;
        emotionScores[id] = (emotionScores[id] ?? 0) + score.percentage;
        if (score.emotion.category == EmotionCategory.positiva) {
          totalPositive++;
        } else if (score.emotion.category == EmotionCategory.negativa) {
          totalNegative++;
        }
      }
    }

    final sorted = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final predominant = sorted.isNotEmpty
        ? (emotionById(sorted.first.key)?.name ?? 'Desconocida')
        : 'Desconocida';

    final ansiedadScores = emotionScores.entries
        .where((e) => e.key == 'ansiedad' || e.key == 'estres')
        .map((e) => e.value / (emotionCounts[e.key] ?? 1));
    final avgAnsiedad = ansiedadScores.isNotEmpty
        ? ansiedadScores.reduce((a, b) => a + b) / ansiedadScores.length
        : 0.0;

    final tristezaCount = emotionCounts['tristeza'] ?? 0;
    final alegriaCount = emotionCounts['alegria'] ?? 0;
    final total = totalPositive + totalNegative;

    final stability = _calculateStability(history);
    final writingPatterns = _analyzeWritingPatterns(entries);
    final memoryStats = _analyzeMemories(memories);
    final progress = _calculateProgress(history);

    return EmotionalProfile(
      emocionPredominante: predominant,
      nivelAnsiedad: avgAnsiedad.clamp(0.0, 1.0),
      frecuenciaTristeza: total > 0 ? tristezaCount / total : 0,
      frecuenciaAlegria: total > 0 ? alegriaCount / total : 0,
      horaFrecuente: writingPatterns.horaFrecuente,
      diaFrecuente: writingPatterns.diaFrecuente,
      promedioPalabras: writingPatterns.promedioPalabras,
      estabilidadEmocional: stability,
      porcentajePositivas: total > 0 ? totalPositive / total : 0,
      porcentajeNegativas: total > 0 ? totalNegative / total : 0,
      personasMencionadas: memoryStats.personas,
      problemasFrecuentes: memoryStats.problemas,
      temasRepetitivos: memoryStats.temas,
      nivelProgreso: progress,
      fortalezas: _detectFortalezas(emotionCounts, memoryStats),
      aspectosTrabajar: _detectAspectosTrabajar(emotionCounts),
    );
  }

  double _calculateStability(List<EmotionAnalysis> history) {
    if (history.length < 4) return 0.5;
    final mid = history.length ~/ 2;
    final first = _avgPositiveRatio(history.sublist(0, mid));
    final second = _avgPositiveRatio(history.sublist(mid));
    final diff = (second - first).abs();
    return (1.0 - diff).clamp(0.0, 1.0);
  }

  double _avgPositiveRatio(List<EmotionAnalysis> analyses) {
    int pos = 0;
    int total = 0;
    for (final a in analyses) {
      for (final s in a.rankings) {
        total++;
        if (s.emotion.category == EmotionCategory.positiva) pos++;
      }
    }
    return total > 0 ? pos / total : 0;
  }

  _WritingPatterns _analyzeWritingPatterns(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return const _WritingPatterns(0, 0, 0);
    }
    final hours = <int>{};
    final days = <int>{};
    int totalWords = 0;

    for (final entry in entries) {
      hours.add(entry.createdAt.hour);
      days.add(entry.createdAt.weekday);
      totalWords += entry.note.split(RegExp(r'\s+')).length;
    }

    final hourCounts = <int, int>{};
    for (final h in hours) {
      hourCounts[h] = (hourCounts[h] ?? 0) + 1;
    }
    final frequentHour = hourCounts.isNotEmpty
        ? (hourCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first.key
        : 0;

    final dayCounts = <int, int>{};
    for (final d in days) {
      dayCounts[d] = (dayCounts[d] ?? 0) + 1;
    }
    final frequentDay = dayCounts.isNotEmpty
        ? (dayCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first.key
        : 1;

    return _WritingPatterns(
      frequentHour,
      frequentDay,
      totalWords / entries.length,
    );
  }

  _MemoryStats _analyzeMemories(List<MemoryItem> memories) {
    final personas = <String>[];
    final problemas = <String>[];
    final temas = <String>[];

    for (final m in memories) {
      if (!m.active) continue;
      switch (m.category) {
        case MemoryCategory.persona:
          personas.add(m.value);
          break;
        case MemoryCategory.problema:
          problemas.add(m.value);
          break;
        case MemoryCategory.familia:
        case MemoryCategory.relacion:
          personas.add(m.value);
          break;
        default:
          temas.add(m.value);
          break;
      }
    }
    return _MemoryStats(
      personas.take(5).toList(),
      problemas.take(5).toList(),
      temas.take(5).toList(),
    );
  }

  double _calculateProgress(List<EmotionAnalysis> history) {
    if (history.length < 4) return 0.5;
    final recent = history.length > 10 ? history.sublist(history.length - 10) : history;
    double totalScore = 0;
    int count = 0;
    for (final a in recent) {
      for (final s in a.rankings.take(3)) {
        if (s.emotion.category == EmotionCategory.positiva) {
          totalScore += s.percentage;
        }
        count++;
      }
    }
    return count > 0 ? (totalScore / count).clamp(0.0, 1.0) : 0.5;
  }

  List<String> _detectFortalezas(
    Map<String, int> counts,
    _MemoryStats stats,
  ) {
    final fortalezas = <String>[];
    if ((counts['alegria'] ?? 0) > 2) fortalezas.add('Capacidad de experimentar alegría');
    if ((counts['amor'] ?? 0) > 1) fortalezas.add('Conexión afectiva');
    if ((counts['esperanza'] ?? 0) > 1) fortalezas.add('Sentido de esperanza');
    if ((counts['gratitud'] ?? 0) > 1) fortalezas.add('Actitud de gratitud');
    if ((counts['calma'] ?? 0) > 1) fortalezas.add('Búsqueda de paz interior');
    if ((counts['motivacion'] ?? 0) > 1) fortalezas.add('Impulso motivacional');
    if (fortalezas.isEmpty) fortalezas.add('Compromiso con el autoconocimiento');
    return fortalezas;
  }

  List<String> _detectAspectosTrabajar(Map<String, int> counts) {
    final aspectos = <String>[];
    if ((counts['ansiedad'] ?? 0) > 2) aspectos.add('Manejo de la ansiedad');
    if ((counts['tristeza'] ?? 0) > 2) aspectos.add('Procesamiento de la tristeza');
    if ((counts['estres'] ?? 0) > 2) aspectos.add('Reducción del estrés');
    if ((counts['frustracion'] ?? 0) > 2) aspectos.add('Gestión de la frustración');
    if ((counts['soledad'] ?? 0) > 2) aspectos.add('Conexión social');
    if ((counts['miedo'] ?? 0) > 2) aspectos.add('Afrontamiento del miedo');
    if (aspectos.isEmpty) aspectos.add('Mantener la constancia');
    return aspectos;
  }

  EmotionalProfile _emptyProfile() {
    return const EmotionalProfile(
      emocionPredominante: 'Sin datos',
      nivelAnsiedad: 0,
      frecuenciaTristeza: 0,
      frecuenciaAlegria: 0,
      horaFrecuente: 0,
      diaFrecuente: 1,
      promedioPalabras: 0,
      estabilidadEmocional: 0.5,
      porcentajePositivas: 0,
      porcentajeNegativas: 0,
      personasMencionadas: [],
      problemasFrecuentes: [],
      temasRepetitivos: [],
      nivelProgreso: 0.5,
      fortalezas: [],
      aspectosTrabajar: [],
    );
  }
}

class _WritingPatterns {
  const _WritingPatterns(this.horaFrecuente, this.diaFrecuente, this.promedioPalabras);
  final int horaFrecuente;
  final int diaFrecuente;
  final double promedioPalabras;
}

class _MemoryStats {
  const _MemoryStats(this.personas, this.problemas, this.temas);
  final List<String> personas;
  final List<String> problemas;
  final List<String> temas;
}
