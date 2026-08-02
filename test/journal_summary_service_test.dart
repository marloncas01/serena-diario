import 'package:flutter_test/flutter_test.dart';
import 'package:serena_diario/models/emotion.dart';
import 'package:serena_diario/models/journal_entry.dart';
import 'package:serena_diario/services/journal_summary_service.dart';

JournalEntry _entry(String id, DateTime date, String mood) => JournalEntry(
      id: id,
      createdAt: date,
      mood: mood,
      note: 'nota $id',
    );

List<EmotionAnalysis> _analysisFor(List<JournalEntry> entries, String emotionId) =>
    entries.map((entry) {
      final emotion = emotionById(emotionId)!;
      return EmotionAnalysis(
        rankings: [
          EmotionScore(
            emotion: emotion,
            percentage: 80,
            matchedKeywords: const [],
          ),
          EmotionScore(
            emotion: neutralEmotion,
            percentage: 20,
            matchedKeywords: const [],
          ),
        ],
        confidence: 0.9,
        detectedKeywords: const [],
        explanation: '',
      );
    }).toList();

void main() {
  final service = JournalSummaryService();

  group('generateWeekly', () {
    test('sin entradas devuelve un resumen vacío amigable', () {
      final summary = service.generateWeekly(history: const [], entries: const []);
      expect(summary.entradas, 0);
      expect(summary.emocionPredominante, 'Sin datos');
      expect(summary.descripcion, contains('no escribiste'));
    });

    test('detecta la emoción predominante de la semana', () {
      final now = DateTime.now();
      final entries = [
        _entry('1', now.subtract(const Duration(days: 1)), 'Alegría'),
        _entry('2', now.subtract(const Duration(days: 2)), 'Felicidad'),
        _entry('3', now.subtract(const Duration(days: 3)), 'Tristeza'),
      ];
      final history = _analysisFor(entries, 'felicidad');
      final summary = service.generateWeekly(history: history, entries: entries);
      expect(summary.entradas, 3);
      expect(summary.momentosAlegria, greaterThan(0));
      expect(summary.descripcion, contains('3 veces'));
    });

    test('ignora entradas de más de 7 días', () {
      final now = DateTime.now();
      final entries = [
        _entry('vieja', now.subtract(const Duration(days: 10)), 'Tristeza'),
      ];
      final history = _analysisFor(entries, 'tristeza');
      final summary = service.generateWeekly(history: history, entries: entries);
      expect(summary.entradas, 0);
    });
  });

  group('generateMonthly', () {
    test('sin entradas devuelve un resumen vacío', () {
      final summary =
          service.generateMonthly(history: const [], entries: const []);
      expect(summary.avances, contains('Sin datos'));
    });

    test('genera resumen mensual con avances', () {
      final now = DateTime.now();
      final entries = List.generate(
        8,
        (i) => _entry(
          'm$i',
          now.subtract(Duration(days: i * 2)),
          i.isEven ? 'Felicidad' : 'Ansiedad',
        ),
      );
      final history = _analysisFor(entries, 'ansiedad');
      final summary =
          service.generateMonthly(history: history, entries: entries);
      expect(summary.avances, contains('8'));
      expect(summary.descripcion, isNotEmpty);
    });

    test('felicita cuando hay muchas entradas', () {
      final now = DateTime.now();
      final entries = List.generate(
        22,
        (i) => _entry('f$i', now.subtract(Duration(days: i)), 'Felicidad'),
      );
      final history = _analysisFor(entries, 'felicidad');
      final summary =
          service.generateMonthly(history: history, entries: entries);
      expect(summary.felicitacion, isNotEmpty);
    });
  });
}
