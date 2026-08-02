import 'package:flutter_test/flutter_test.dart';
import 'package:serena_diario/models/journal_entry.dart';
import 'package:serena_diario/utils/journal_insights.dart';

JournalEntry _entry(DateTime date,
        {String mood = 'Felicidad',
        String? dominantId,
        double? intensity}) =>
    JournalEntry(
      id: date.toIso8601String(),
      createdAt: date,
      mood: mood,
      note: 'nota',
      dominantEmotionId: dominantId,
      dominantEmotionIntensity: intensity,
    );

void main() {
  group('daysWithEntries', () {
    test('cuenta días distintos del mes', () {
      final month = DateTime(2026, 8);
      final entries = [
        _entry(DateTime(2026, 8, 1)),
        _entry(DateTime(2026, 8, 1, 12)),
        _entry(DateTime(2026, 8, 15)),
      ];
      expect(JournalInsights.daysWithEntries(entries, month), 2);
    });

    test('ignora entradas de otros meses', () {
      final month = DateTime(2026, 8);
      final entries = [
        _entry(DateTime(2026, 7, 31)),
        _entry(DateTime(2026, 9, 1)),
      ];
      expect(JournalInsights.daysWithEntries(entries, month), 0);
    });
  });

  group('bestStreakInMonth', () {
    test('racha máxima de días consecutivos del mes', () {
      final month = DateTime(2026, 8);
      final entries = [
        for (var d = 3; d <= 6; d++) _entry(DateTime(2026, 8, d)),
        _entry(DateTime(2026, 8, 10)),
        _entry(DateTime(2026, 8, 11)),
        _entry(DateTime(2026, 8, 12)),
        _entry(DateTime(2026, 8, 13)),
        _entry(DateTime(2026, 8, 14)),
      ];
      expect(JournalInsights.bestStreakInMonth(entries, month), 5);
    });

    test('racha que cruza el inicio del mes', () {
      final month = DateTime(2026, 8);
      final entries = [
        _entry(DateTime(2026, 7, 30)),
        _entry(DateTime(2026, 7, 31)),
        _entry(DateTime(2026, 8, 1)),
        _entry(DateTime(2026, 8, 2)),
      ];
      expect(JournalInsights.bestStreakInMonth(entries, month), 2);
    });

    test('mes sin entradas devuelve 0', () {
      expect(
        JournalInsights.bestStreakInMonth(const [], DateTime(2026, 8)),
        0,
      );
    });
  });

  group('positiveRatio', () {
    test('porcentaje de entradas con emoción positiva', () {
      final entries = [
        _entry(DateTime(2026, 8, 1), dominantId: 'felicidad'),
        _entry(DateTime(2026, 8, 2), dominantId: 'tristeza'),
        _entry(DateTime(2026, 8, 3), dominantId: 'amor'),
        _entry(DateTime(2026, 8, 4)),
      ];
      expect(JournalInsights.positiveRatio(entries), 66.66666666666666);
    });

    test('sin análisis emocional devuelve 0', () {
      expect(
        JournalInsights.positiveRatio([_entry(DateTime(2026, 8, 1))]),
        0,
      );
    });
  });
}
