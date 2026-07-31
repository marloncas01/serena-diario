import '../models/emotion.dart';

class EmotionalHistoryReport {
  const EmotionalHistoryReport({
    required this.hayRecaida,
    required this.hayMejora,
    required this.esEstable,
    required this.ciclosDetectados,
    required this.descripcion,
    required this.tendencia,
    required this.diasAnalizados,
  });

  final bool hayRecaida;
  final bool hayMejora;
  final bool esEstable;
  final List<String> ciclosDetectados;
  final String descripcion;
  final double tendencia;
  final int diasAnalizados;
}

class EmotionalHistoryService {
  EmotionalHistoryReport analyze(List<EmotionAnalysis> history) {
    if (history.length < 3) {
      return const EmotionalHistoryReport(
        hayRecaida: false,
        hayMejora: false,
        esEstable: false,
        ciclosDetectados: [],
        descripcion: 'Necesito más entradas para analizar tu historia.',
        tendencia: 0,
        diasAnalizados: 0,
      );
    }

    final segments = _splitIntoSegments(history);
    final trends = _analyzeSegmentTrends(segments);
    final cycles = _detectCycles(history);

    final hayMejora = _detectImprovement(trends);
    final hayRecaida = _detectRelapse(trends);
    final esEstable = !hayMejora && !hayRecaida && trends.length >= 2;

    final tendencia = _calculateOverallTrend(trends);
    final desc = _buildDescription(hayMejora, hayRecaida, esEstable, cycles, trends);

    return EmotionalHistoryReport(
      hayRecaida: hayRecaida,
      hayMejora: hayMejora,
      esEstable: esEstable,
      ciclosDetectados: cycles,
      descripcion: desc,
      tendencia: tendencia,
      diasAnalizados: history.length,
    );
  }

  List<_Segment> _splitIntoSegments(List<EmotionAnalysis> history) {
    final segSize = (history.length / 3).ceil().clamp(2, history.length);
    final segments = <_Segment>[];
    for (var i = 0; i < history.length; i += segSize) {
      final end = (i + segSize).clamp(0, history.length);
      segments.add(_Segment(history.sublist(i, end)));
    }
    return segments;
  }

  List<double> _analyzeSegmentTrends(List<_Segment> segments) {
    return segments.map((s) => s.positiveRatio).toList();
  }

  bool _detectImprovement(List<double> trends) {
    if (trends.length < 2) return false;
    final first = trends.first;
    final last = trends.last;
    return last - first > 0.1;
  }

  bool _detectRelapse(List<double> trends) {
    if (trends.length < 3) return false;
    final mid = trends[trends.length ~/ 2];
    final last = trends.last;
    return mid > trends.first + 0.1 && last < mid - 0.1;
  }

  List<String> _detectCycles(List<EmotionAnalysis> history) {
    if (history.length < 6) return [];
    final cycles = <String>[];
    const windowSize = 3;
    var wasNegative = false;
    var wasPositive = false;
    var switchCount = 0;

    for (var i = 0; i <= history.length - windowSize; i++) {
      final window = history.sublist(i, i + windowSize);
      final ratio = _Segment(window).positiveRatio;
      final isNeg = ratio < 0.35;
      final isPos = ratio > 0.55;

      if (isNeg && wasPositive) switchCount++;
      if (isPos && wasNegative) switchCount++;
      wasNegative = isNeg;
      wasPositive = isPos;
    }

    if (switchCount >= 2) {
      cycles.add('Altibajos emocionales');
    }

    final recent = history.sublist(history.length - windowSize);
    final older = history.sublist(0, windowSize);
    final recentRatio = _Segment(recent).positiveRatio;
    final olderRatio = _Segment(older).positiveRatio;

    if ((recentRatio - olderRatio).abs() < 0.1 && history.length >= 6) {
      cycles.add('Patrón estable');
    }

    return cycles;
  }

  double _calculateOverallTrend(List<double> trends) {
    if (trends.length < 2) return 0;
    return (trends.last - trends.first).clamp(-1.0, 1.0);
  }

  String _buildDescription(
    bool improvement,
    bool relapse,
    bool stable,
    List<String> cycles,
    List<double> trends,
  ) {
    if (improvement && !relapse) {
      return 'Llevas varios días mejorando. He notado una tendencia positiva '
          'en tus emociones.';
    }
    if (relapse) {
      return 'Esta semana aparecieron nuevamente emociones difíciles. '
          'Es parte del proceso, y estoy aquí para acompañarte.';
    }
    if (stable) {
      return 'Has mostrado mayor estabilidad emocional en los últimos días.';
    }
    if (cycles.isNotEmpty) {
      return 'Durante las últimas semanas has tenido momentos de todo. '
          'Eso es normal en un proceso de crecimiento.';
    }
    return 'Tu historia emocional sigue construyéndose. '
        'Sigue escribiendo para conocerme mejor.';
  }
}

class _Segment {
  _Segment(this.analyses);
  final List<EmotionAnalysis> analyses;

  double get positiveRatio {
    int pos = 0, total = 0;
    for (final a in analyses) {
      for (final s in a.rankings) {
        total++;
        if (s.emotion.category == EmotionCategory.positiva) pos++;
      }
    }
    return total > 0 ? pos / total : 0;
  }
}
