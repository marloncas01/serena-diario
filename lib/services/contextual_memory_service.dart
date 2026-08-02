import '../models/memory_item.dart';

class RecurringTopic {
  const RecurringTopic({
    required this.value,
    required this.timesMentioned,
    required this.spanDays,
  });

  final String value;
  final int timesMentioned;
  final int spanDays;
}

class PersonRecall {
  const PersonRecall({
    required this.name,
    required this.timesMentioned,
    required this.daysSinceLastMention,
  });

  final String name;
  final int timesMentioned;
  final int daysSinceLastMention;
}

class ContextualMemory {
  const ContextualMemory({
    required this.recurringTopics,
    required this.people,
    required this.recurringProblems,
    required this.resumedSituation,
  });

  final List<RecurringTopic> recurringTopics;
  final List<PersonRecall> people;
  final List<MemoryItem> recurringProblems;

  /// Situación/evento que el usuario viene contando y volvió a mencionar.
  final MemoryItem? resumedSituation;

  bool get isEmpty =>
      recurringTopics.isEmpty &&
      people.isEmpty &&
      recurringProblems.isEmpty &&
      resumedSituation == null;
}

/// Extrae contexto humano a partir de las memorias activas, sin inventar
/// información: solo usa datos que ya existen en las memorias.
class ContextualMemoryService {
  const ContextualMemoryService._();

  static const int _recurringMinMentions = 2;
  static const int _problemMinMentions = 3;
  static const int _resumedMaxDays = 3;

  static ContextualMemory build({
    required List<MemoryItem> memories,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final recurringTopics = <RecurringTopic>[];
    final people = <PersonRecall>[];
    final recurringProblems = <MemoryItem>[];
    MemoryItem? resumedSituation;

    for (final memory in memories) {
      if (!memory.active) continue;

      final spanDays = memory.lastMention
          .difference(memory.createdAt)
          .inDays;
      final daysSinceLast = reference
          .difference(memory.lastMention)
          .inDays;

      if (memory.category == MemoryCategory.persona) {
        if (memory.timesMentioned >= 1) {
          people.add(PersonRecall(
            name: memory.value,
            timesMentioned: memory.timesMentioned,
            daysSinceLastMention: daysSinceLast < 0 ? 0 : daysSinceLast,
          ));
        }
        continue;
      }

      final isSituation = memory.category == MemoryCategory.evento ||
          memory.category == MemoryCategory.trabajo ||
          memory.category == MemoryCategory.estudio ||
          memory.category == MemoryCategory.salud ||
          memory.category == MemoryCategory.relacion;

      if (isSituation &&
          memory.timesMentioned >= _recurringMinMentions &&
          daysSinceLast <= _resumedMaxDays &&
          daysSinceLast >= 0) {
        if (resumedSituation == null ||
            memory.timesMentioned > resumedSituation.timesMentioned) {
          resumedSituation = memory;
        }
        continue;
      }

      final isProblem = memory.category == MemoryCategory.problema ||
          memory.category == MemoryCategory.miedo;

      if (isProblem && memory.timesMentioned >= _problemMinMentions) {
        recurringProblems.add(memory);
      } else if (memory.timesMentioned >= _recurringMinMentions &&
          spanDays >= 1) {
        recurringTopics.add(RecurringTopic(
          value: memory.value,
          timesMentioned: memory.timesMentioned,
          spanDays: spanDays,
        ));
      }
    }

    recurringTopics.sort((a, b) => b.timesMentioned.compareTo(a.timesMentioned));
    people.sort((a, b) {
      final mentions = b.timesMentioned.compareTo(a.timesMentioned);
      if (mentions != 0) return mentions;
      return a.daysSinceLastMention.compareTo(b.daysSinceLastMention);
    });
    recurringProblems.sort(
      (a, b) => b.timesMentioned.compareTo(a.timesMentioned),
    );

    return ContextualMemory(
      recurringTopics: recurringTopics,
      people: people,
      recurringProblems: recurringProblems,
      resumedSituation: resumedSituation,
    );
  }

  /// Frases de contexto listas para ser usadas en la interpretación de Serena.
  /// Devuelve como máximo [limit] frases, priorizando problemas, personas y
  /// temas recurrentes.
  static List<String> sentences(
    ContextualMemory memory, {
    int limit = 2,
    bool includeResumed = true,
  }) {
    final sentences = <String>[];

    for (final problem in memory.recurringProblems.take(1)) {
      sentences.add(
        'Parece que el tema de "${problem.value}" vuelve a aparecer.',
      );
      if (sentences.length >= limit) return sentences;
    }

    for (final person in memory.people.take(2)) {
      if (person.daysSinceLastMention <= 1) {
        sentences.add('Volviste a mencionar a ${person.name}.');
      } else if (person.daysSinceLastMention <= 7) {
        sentences.add(
          'Hace ${person.daysSinceLastMention} días mencionaste a ${person.name}.',
        );
      } else {
        sentences.add('Antes solías hablar de ${person.name}.');
      }
      if (sentences.length >= limit) return sentences;
    }

    for (final topic in memory.recurringTopics.take(1)) {
      sentences.add(
        'El tema de "${topic.value}" ha aparecido ${topic.timesMentioned} veces '
        'a lo largo de los días.',
      );
      if (sentences.length >= limit) return sentences;
    }

    final resumed = memory.resumedSituation;
    if (resumed != null && includeResumed) {
      sentences.add('Retomas lo que venías contando sobre "${resumed.value}".');
    }

    return sentences;
  }
}
