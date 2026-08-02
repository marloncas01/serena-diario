import 'package:flutter_test/flutter_test.dart';
import 'package:serena_diario/models/emotion.dart';
import 'package:serena_diario/models/journal_entry.dart';
import 'package:serena_diario/services/emotion_engine.dart';
import 'package:serena_diario/services/emotion_grammar.dart';
import 'package:serena_diario/services/user_profile.dart';

void main() {
  group('EmotionEngine.analyze', () {
    test('detecta felicidad con intensificador', () {
      final analysis = EmotionEngine.analyze('hoy estoy muy feliz');
      expect(analysis.rankings, isNotEmpty);
      expect(analysis.rankings.first.emotion.id, 'felicidad');
      expect(analysis.confidence, greaterThan(0));
    });

    test('detecta intensidad con superlativo', () {
      final baseline = EmotionEngine.analyze('estoy triste');
      final superlative = EmotionEngine.analyze('estoy tristísima');
      expect(superlative.rankings.first.emotion.id, 'tristeza');
      expect(
        superlative.rankings.first.percentage,
        greaterThanOrEqualTo(baseline.rankings.first.percentage),
      );
    });

    test('la negación evita que domine la emoción negada', () {
      final analysis = EmotionEngine.analyze('no estoy triste, estoy feliz');
      expect(analysis.rankings, isNotEmpty);
      expect(analysis.rankings.first.emotion.id, isNot('tristeza'));
    });

    test('el separador de cláusula corta la negación', () {
      final analysis =
          EmotionEngine.analyze('no estoy triste pero me siento genial');
      expect(analysis.rankings, isNotEmpty);
      expect(analysis.rankings.first.emotion.id, 'alegria');
    });

    test('detecta frases multi-palabra (anticipación)', () {
      final analysis = EmotionEngine.analyze('no veo la hora de verla');
      expect(analysis.rankings, isNotEmpty);
      expect(analysis.rankings.first.emotion.id, 'anticipacion');
    });

    test('detecta frases multi-palabra (inseguridad)', () {
      final analysis = EmotionEngine.analyze('no me siento capaz de lograrlo');
      expect(analysis.rankings, isNotEmpty);
      expect(analysis.rankings.first.emotion.id, 'inseguridad');
    });

    test('contexto de estrés por falta de sueño', () {
      final analysis =
          EmotionEngine.analyze('no pude dormir anoche por el trabajo');
      expect(analysis.rankings, isNotEmpty);
      expect(analysis.rankings.first.emotion.id, 'estres');
    });

    test('la crisis fuerza la desesperanza como dominante', () {
      final analysis = EmotionEngine.analyze('ya no quiero vivir');
      expect(analysis.rankings, isNotEmpty);
      expect(analysis.rankings.first.emotion.id, 'desesperanza');
    });

    test('texto vacío devuelve análisis vacío', () {
      final analysis = EmotionEngine.analyze('   ');
      expect(analysis.rankings, isEmpty);
      expect(analysis.confidence, 0);
    });
  });

  group('EmotionEngine.dominant', () {
    test('devuelve la emoción dominante con intensidad y porcentaje', () {
      final dominant = EmotionEngine.dominant('estoy muy feliz');
      expect(dominant, isNotNull);
      expect(dominant!.emotion.id, 'felicidad');
      expect(dominant.intensity, inInclusiveRange(0.0, 1.0));
      expect(dominant.percentage, greaterThan(0));
    });

    test('devuelve null cuando no hay texto', () {
      expect(EmotionEngine.dominant(''), isNull);
    });

    test('todos los ids de emoción dominante existen en allEmotions', () {
      final dominant = EmotionEngine.dominant('estoy feliz y en paz');
      expect(dominant, isNotNull);
      expect(
        allEmotions.map((e) => e.id),
        contains(dominant!.emotion.id),
      );
    });
  });

  group('JournalEntry con emoción dominante', () {
    test('round-trip a través de toMap/fromMap', () {
      final entry = JournalEntry(
        id: 'e1',
        createdAt: DateTime(2026, 8, 1, 12, 30),
        mood: 'Feliz',
        note: 'Hoy fue un gran día',
        dominantEmotionId: 'alegria',
        dominantEmotionName: 'Alegría',
        dominantEmotionEmoji: '😄',
        dominantEmotionCategory: 'positiva',
        dominantEmotionIntensity: 0.8,
      );

      final restored = JournalEntry.fromMap(entry.toMap());
      expect(restored.dominantEmotionId, 'alegria');
      expect(restored.dominantEmotionName, 'Alegría');
      expect(restored.dominantEmotionEmoji, '😄');
      expect(restored.dominantEmotionCategory, 'positiva');
      expect(restored.dominantEmotionIntensity, 0.8);
    });

    test('entradas antiguas se leen sin emoción dominante', () {
      final restored = JournalEntry.fromMap({
        'id': 'e2',
        'createdAt': '2026-07-01T10:00:00.000',
        'mood': 'Normal',
        'note': 'Nota antigua',
        'tags': <String>[],
      });
      expect(restored.dominantEmotionId, isNull);
      expect(restored.dominantEmotionIntensity, isNull);
    });

    test('copyWith permite limpiar la emoción dominante', () {
      final entry = JournalEntry(
        id: 'e3',
        createdAt: DateTime(2026, 8, 1),
        mood: 'Normal',
        note: 'Nota',
        dominantEmotionId: 'tristeza',
        dominantEmotionEmoji: '😔',
        dominantEmotionIntensity: 0.9,
      );
      final cleared = entry.copyWith(clearDominantEmotion: true);
      expect(cleared.dominantEmotionId, isNull);
      expect(cleared.dominantEmotionIntensity, isNull);
    });
  });

  group('EmotionGrammar', () {
    test('flex devuelve la forma femenina solo para sexo mujer', () {
      expect(EmotionGrammar.flex(UserSex.hombre, 'solo', 'sola'), 'solo');
      expect(EmotionGrammar.flex(UserSex.mujer, 'solo', 'sola'), 'sola');
      expect(
        EmotionGrammar.flex(UserSex.prefieroNoDecirlo, 'solo', 'sola'),
        'solo',
      );
    });

    test('labelFor flexiona el estado según el sexo', () {
      final cansancio = emotionById('cansancio')!;
      expect(EmotionGrammar.labelFor(cansancio, UserSex.hombre), 'Cansado');
      expect(EmotionGrammar.labelFor(cansancio, UserSex.mujer), 'Cansada');
      expect(
        EmotionGrammar.labelFor(cansancio, UserSex.prefieroNoDecirlo),
        'Con cansancio',
      );
    });

    test('labelFor mantiene Neutral sin flexión', () {
      expect(
        EmotionGrammar.labelFor(neutralEmotion, UserSex.hombre),
        'Neutral',
      );
      expect(
        EmotionGrammar.labelFor(neutralEmotion, UserSex.mujer),
        'Neutral',
      );
    });
  });
}
