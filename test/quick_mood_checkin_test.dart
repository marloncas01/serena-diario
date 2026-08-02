import 'package:flutter_test/flutter_test.dart';
import 'package:serena_diario/models/emotion.dart';
import 'package:serena_diario/models/journal_entry.dart';
import 'package:serena_diario/widgets/quick_mood_checkin.dart';

void main() {
  JournalEntry entry(String id, DateTime date, {List<String> tags = const []}) =>
      JournalEntry(id: id, createdAt: date, mood: 'Felicidad', note: 'nota', tags: tags);

  group('recentCheckInToUpdate', () {
    test('devuelve el check-in reciente dentro de la ventana', () {
      final now = DateTime(2026, 8, 3, 10, 0);
      final entries = [
        entry('a', now.subtract(const Duration(minutes: 1)), tags: ['check-in']),
      ];
      final target = recentCheckInToUpdate(entries, now);
      expect(target?.id, 'a');
    });

    test('ignora check-ins fuera de la ventana', () {
      final now = DateTime(2026, 8, 3, 10, 0);
      final entries = [
        entry('a', now.subtract(const Duration(minutes: 3)), tags: ['check-in']),
      ];
      expect(recentCheckInToUpdate(entries, now), isNull);
    });

    test('ignora entradas que no son check-in', () {
      final now = DateTime(2026, 8, 3, 10, 0);
      final entries = [entry('a', now.subtract(const Duration(minutes: 1)))];
      expect(recentCheckInToUpdate(entries, now), isNull);
    });

    test('usa la ventana por defecto de 2 minutos', () {
      final now = DateTime(2026, 8, 3, 10, 0);
      final entries = [
        entry('a', now.subtract(const Duration(seconds: 119)), tags: ['check-in']),
      ];
      expect(recentCheckInToUpdate(entries, now)?.id, 'a');
    });
  });

  group('quick moods', () {
    test('los 6 emojis se resuelven a emociones existentes', () {
      const ids = ['felicidad', 'neutral', 'tristeza', 'enojo', 'ansiedad', 'amor'];
      for (final id in ids) {
        expect(emotionById(id), isNotNull, reason: 'emotion $id debe existir');
      }
    });

    test('los moods guardados se resuelven por etiqueta', () {
      for (final id in ['felicidad', 'neutral', 'tristeza', 'enojo', 'ansiedad', 'amor']) {
        final emotion = emotionById(id)!;
        expect(emotionForLabel(emotion.name).id, id);
      }
    });
  });
}
