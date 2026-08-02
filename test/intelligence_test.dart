import 'package:flutter_test/flutter_test.dart';
import 'package:serena_diario/models/emotion.dart';
import 'package:serena_diario/models/journal_entry.dart';
import 'package:serena_diario/models/memory_item.dart';
import 'package:serena_diario/services/contextual_memory_service.dart';
import 'package:serena_diario/services/emotional_pattern_analyzer.dart';
import 'package:serena_diario/services/pattern_insight_generator.dart';
import 'package:serena_diario/services/response_variation_tracker.dart';
import 'package:serena_diario/services/smart_advice_engine.dart';

JournalEntry _entry(
  String id,
  DateTime createdAt,
  String emotionId, {
  double? intensity,
}) {
  final emotion = emotionById(emotionId)!;
  return JournalEntry(
    id: id,
    createdAt: createdAt,
    mood: emotion.name,
    note: 'entrada $id',
    dominantEmotionId: emotion.id,
    dominantEmotionName: emotion.name,
    dominantEmotionEmoji: emotion.emoji,
    dominantEmotionCategory: emotion.category.name,
    dominantEmotionIntensity: intensity ?? 0.5,
  );
}

void main() {
  group('EmotionalPatternAnalyzer', () {
    test('detecta emoción predominante, diversidad y rachas', () {
      final entries = [
        _entry('a', DateTime(2026, 7, 1, 10), 'tristeza'), // miércoles
        _entry('b', DateTime(2026, 7, 2, 10), 'tristeza'), // jueves
        _entry('c', DateTime(2026, 7, 3, 10), 'tristeza'), // viernes
        _entry('d', DateTime(2026, 7, 4, 10), 'ansiedad'), // sábado
        _entry('e', DateTime(2026, 7, 8, 10), 'tristeza'), // miércoles
      ];

      final report = EmotionalPatternAnalyzer.analyze(entries);

      expect(report.totalEntries, 5);
      expect(report.predominantEmotion!.id, 'tristeza');
      expect(report.predominantEmotionCount, 4);
      expect(report.emotionalDiversity, 2);
      expect(report.negativeStreak, 5);
      expect(report.positiveStreak, 0);
      expect(report.mostActiveWeekday, 'miércoles');
      expect(report.predominantHourSlot, 'mañana');
      expect(
        report.consecutiveRuns.any((r) => r.emotionId == 'tristeza' && r.count >= 3),
        isTrue,
      );
    });

    test('detecta cambio brusco y mayor salto de ánimo', () {
      final entries = [
        _entry('a', DateTime(2026, 7, 1, 20), 'tristeza'),
        _entry('b', DateTime(2026, 7, 2, 7), 'alegria'),
      ];

      final report = EmotionalPatternAnalyzer.analyze(entries);
      final biggest = report.biggestMoodChange;

      expect(report.abruptChanges, isNotEmpty);
      expect(biggest, isNotNull);
      expect(biggest!.fromEmotion.id, 'tristeza');
      expect(biggest.toEmotion.id, 'alegria');
      expect(biggest.categoryFlip, isTrue);
    });

    test('detecta tendencia de mejora y de empeoramiento', () {
      final improving = [
        _entry('a', DateTime(2026, 7, 1, 10), 'ansiedad'),
        _entry('b', DateTime(2026, 7, 2, 10), 'tristeza'),
        _entry('c', DateTime(2026, 7, 3, 10), 'alegria'),
        _entry('d', DateTime(2026, 7, 4, 10), 'felicidad'),
      ];
      final worsening = [
        _entry('a', DateTime(2026, 7, 1, 10), 'alegria'),
        _entry('b', DateTime(2026, 7, 2, 10), 'felicidad'),
        _entry('c', DateTime(2026, 7, 3, 10), 'tristeza'),
        _entry('d', DateTime(2026, 7, 4, 10), 'ansiedad'),
      ];

      expect(
        EmotionalPatternAnalyzer.analyze(improving).trend,
        TrendDirection.improving,
      );
      expect(
        EmotionalPatternAnalyzer.analyze(worsening).trend,
        TrendDirection.worsening,
      );
    });
  });

  group('ResponseVariationTracker', () {
    test('evita repetir opciones recientes', () {
      final tracker = ResponseVariationTracker();
      const pool = ['a', 'b', 'c'];

      String? previous;
      for (var i = 0; i < 20; i++) {
        final pick = tracker.pickUnique('k', pool, i);
        expect(pick, isNot(previous));
        previous = pick;
      }
    });

    test('cae a la lista completa cuando se agotan las alternativas', () {
      final tracker = ResponseVariationTracker();
      final pick = tracker.pickUnique('k', const ['solo'], 7);
      expect(pick, 'solo');
    });

    test('pickIndex alterna entre opciones disponibles', () {
      final tracker = ResponseVariationTracker();
      int? previous;
      for (var i = 0; i < 10; i++) {
        final index = tracker.pickIndex('idx', 3, i);
        expect(index, isNot(previous));
        previous = index;
      }
    });

    test('record, recent y reset funcionan por clave', () {
      final tracker = ResponseVariationTracker();
      tracker.record('a', 'x');
      tracker.record('a', 'y');
      tracker.record('b', 'z');

      expect(tracker.wasRecentlyUsed('a', 'x'), isTrue);
      expect(tracker.recent('a'), ['y', 'x']);
      expect(tracker.wasRecentlyUsed('b', 'z'), isTrue);

      tracker.reset('a');
      expect(tracker.recent('a'), isEmpty);
      expect(tracker.recent('b'), isNotEmpty);
    });
  });

  group('PatternInsightGenerator', () {
    test('genera insights únicos y dentro del límite', () {
      final report = EmotionalPatternAnalyzer.analyze([
        _entry('a', DateTime(2026, 7, 1, 10), 'tristeza'),
        _entry('b', DateTime(2026, 7, 2, 10), 'tristeza'),
        _entry('c', DateTime(2026, 7, 3, 10), 'tristeza'),
        _entry('d', DateTime(2026, 7, 4, 10), 'ansiedad'),
      ]);

      final insights = PatternInsightGenerator(
        tracker: ResponseVariationTracker(),
      ).generate(report);

      expect(insights, isNotEmpty);
      expect(insights.length, lessThanOrEqualTo(8));

      final messages = insights.map((i) => i.message).toList();
      expect(messages.toSet().length, messages.length);

      expect(
        insights.any((i) => i.category == PatternInsightCategory.frecuencia),
        isTrue,
      );
      expect(
        insights
            .any((i) => i.message.contains(report.predominantEmotion!.name)),
        isTrue,
      );
    });

    test('refleja la tendencia de empeoramiento', () {
      final report = EmotionalPatternAnalyzer.analyze([
        _entry('a', DateTime(2026, 7, 1, 10), 'alegria'),
        _entry('b', DateTime(2026, 7, 2, 10), 'felicidad'),
        _entry('c', DateTime(2026, 7, 3, 10), 'tristeza'),
        _entry('d', DateTime(2026, 7, 4, 10), 'ansiedad'),
      ]);

      final insights = PatternInsightGenerator(
        tracker: ResponseVariationTracker(),
      ).generate(report);

      expect(
        insights.any((i) => i.category == PatternInsightCategory.tendencia),
        isTrue,
      );
      expect(
        insights.any(
          (i) =>
              i.category == PatternInsightCategory.tendencia &&
              i.emoji == '📉',
        ),
        isTrue,
      );
    });
  });

  group('SmartAdviceEngine', () {
    test('genera consejos por emoción actual', () {
      SmartAdviceEngine().resetHistory();

      final advices = SmartAdviceEngine().generateMultiple(
        emotionHistory: const [],
        profile: null,
        historyReport: null,
        memories: const [],
        streak: 0,
        currentEmotionId: 'ansiedad',
        now: DateTime(2026, 7, 4, 10),
      );

      expect(advices.map((a) => a.title), contains('Ancla con la respiración'));
    });

    test('incluye consejos por patrón de empeoramiento y racha negativa', () {
      SmartAdviceEngine().resetHistory();

      final patterns = EmotionalPatternAnalyzer.analyze([
        _entry('a', DateTime(2026, 7, 1, 10), 'alegria'),
        _entry('b', DateTime(2026, 7, 2, 10), 'felicidad'),
        _entry('c', DateTime(2026, 7, 3, 10), 'tristeza'),
        _entry('d', DateTime(2026, 7, 4, 10), 'ansiedad'),
        _entry('e', DateTime(2026, 7, 5, 10), 'tristeza'),
      ]);

      final advices = SmartAdviceEngine().generateMultiple(
        emotionHistory: const [],
        profile: null,
        historyReport: null,
        memories: const [],
        streak: 0,
        patterns: patterns,
        now: DateTime(2026, 7, 5, 10),
      );

      final titles = advices.map((a) => a.title).toList();
      expect(titles, contains('Cuidado con la tendencia'));
      expect(titles, contains('Varios días difíciles'));
    });
  });

  group('ContextualMemoryService', () {
    test('detecta personas, problemas, temas y situación retomada', () {
      final now = DateTime(2026, 7, 5, 12);

      final memories = [
        MemoryItem(
          id: 'p1',
          category: MemoryCategory.persona,
          value: 'Ana',
          confidence: 0.8,
          createdAt: DateTime(2026, 7, 1),
          lastMention: DateTime(2026, 7, 3),
          timesMentioned: 2,
        ),
        MemoryItem(
          id: 'pr1',
          category: MemoryCategory.problema,
          value: 'estrés laboral',
          confidence: 0.8,
          createdAt: DateTime(2026, 6, 20),
          lastMention: DateTime(2026, 7, 4),
          timesMentioned: 3,
        ),
        MemoryItem(
          id: 't1',
          category: MemoryCategory.rutina,
          value: 'yoga',
          confidence: 0.7,
          createdAt: DateTime(2026, 7, 1),
          lastMention: DateTime(2026, 7, 4),
          timesMentioned: 2,
        ),
        MemoryItem(
          id: 'e1',
          category: MemoryCategory.evento,
          value: 'mudanza',
          confidence: 0.9,
          createdAt: DateTime(2026, 7, 2),
          lastMention: DateTime(2026, 7, 4),
          timesMentioned: 2,
        ),
        MemoryItem(
          id: 'inactive',
          category: MemoryCategory.rutina,
          value: 'ignorada',
          confidence: 0.5,
          createdAt: DateTime(2026, 7, 1),
          lastMention: DateTime(2026, 7, 4),
          timesMentioned: 5,
          active: false,
        ),
      ];

      final memory = ContextualMemoryService.build(memories: memories, now: now);

      expect(memory.people, hasLength(1));
      expect(memory.people.first.name, 'Ana');
      expect(memory.recurringProblems, hasLength(1));
      expect(memory.recurringProblems.first.value, 'estrés laboral');
      expect(memory.recurringTopics, hasLength(1));
      expect(memory.recurringTopics.first.value, 'yoga');
      expect(memory.resumedSituation, isNotNull);
      expect(memory.resumedSituation!.value, 'mudanza');
      expect(memory.isEmpty, isFalse);
    });

    test('construye frases de contexto en español', () {
      final now = DateTime(2026, 7, 5, 12);

      final memory = ContextualMemoryService.build(
        memories: [
          MemoryItem(
            id: 'pr1',
            category: MemoryCategory.problema,
            value: 'examenes',
            confidence: 0.8,
            createdAt: DateTime(2026, 6, 20),
            lastMention: DateTime(2026, 7, 4),
            timesMentioned: 3,
          ),
        ],
        now: now,
      );

      final sentences = ContextualMemoryService.sentences(memory, limit: 2);
      expect(sentences, isNotEmpty);
      expect(sentences.first, contains('examenes'));
    });

    test('no detecta nada con memorias vacías', () {
      final memory = ContextualMemoryService.build(
        memories: const [],
        now: DateTime(2026, 7, 5, 12),
      );
      expect(memory.isEmpty, isTrue);
      expect(ContextualMemoryService.sentences(memory), isEmpty);
    });
  });
}
