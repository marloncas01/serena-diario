import 'dart:math';

import '../models/emotion.dart';
import '../models/memory_item.dart';
import 'memory_manager.dart';
import 'conversation_context_service.dart';

class RecallResponse {
  const RecallResponse({
    required this.text,
    required this.memories,
    this.followUp,
  });

  final String text;
  final List<MemoryItem> memories;
  final String? followUp;
}

class MemoryRecallService {
  MemoryRecallService._();
  static final MemoryRecallService _instance = MemoryRecallService._();
  factory MemoryRecallService() => _instance;

  final _random = Random();
  final _contextService = ConversationContextService();

  static const _greetings = [
    'Claro, recuerdo que me contaste sobre %s.',
    'Sí, me acuerdo de %s.',
    'Recuerdo bien cuando hablaste de %s.',
    'Eso me quedó claro: %s.',
    'Sí, tengo presente %s.',
  ];

  static const _importanceGrowth = [
    'Es algo que te importa mucho, lo has mencionado %d veces.',
    'Veo que %s es algo que te sigue importando.',
    'Es un tema recurrente para ti.',
    'Parece que %s sigue siendo importante en tu vida.',
  ];

  static const _categoryPhrases = {
    MemoryCategory.persona: 'Esa persona parece ser importante para ti.',
    MemoryCategory.familia: 'Tu familia siempre aparece en tus reflexiones.',
    MemoryCategory.relacion: 'Esa relación parece marcar tus días.',
    MemoryCategory.mascota: 'Tu mascota claramente te hace feliz.',
    MemoryCategory.meta: 'Ese sigue siendo tu objetivo.',
    MemoryCategory.miedo: 'Eso ha sido algo difícil para ti.',
    MemoryCategory.problema: 'Parece que ese tema te sigue preocupando.',
    MemoryCategory.logro: 'Ese logro te llenó de orgullo.',
    MemoryCategory.salud: 'Tu salud es algo que te importa cuidar.',
    MemoryCategory.trabajo: 'El trabajo parece ser parte central de tu rutina.',
    MemoryCategory.estudio: 'Tu aprendizaje es algo que valoras.',
    MemoryCategory.rutina: 'Eso parece parte de tu día a día.',
    MemoryCategory.gusto: 'Eso te gusta y te hace bien.',
    MemoryCategory.evento: 'Ese evento parece haber sido significativo.',
    MemoryCategory.otro: 'Recuerdo que hablaste de eso.',
  };

  static const _followUpQuestions = {
    MemoryCategory.persona: ['¿Cómo está %s últimamente?', '¿Has hablado con %s?'],
    MemoryCategory.familia: ['¿Cómo está tu familia?', '¿Qué han hecho juntos últimamente?'],
    MemoryCategory.relacion: ['¿Cómo va todo con %s?', '¿Qué novedades hay?'],
    MemoryCategory.mascota: ['¿Cómo está %s?', '¿Qué ha hecho %s últimamente?'],
    MemoryCategory.meta: ['¿Cómo va tu progreso?', '¿Qué has hecho para avanzar?'],
    MemoryCategory.miedo: ['¿Cómo te sientes con eso ahora?', '¿Ha mejorado la situación?'],
    MemoryCategory.problema: ['¿Cómo sigue todo?', '¿Has encontrado alguna solución?'],
    MemoryCategory.logro: ['¿Qué más has logrado desde entonces?', '¿Cómo te sentiste con eso?'],
    MemoryCategory.salud: ['¿Cómo está tu salud?', '¿Estás cuidándote?'],
    MemoryCategory.trabajo: ['¿Cómo va el trabajo?', '¿Qué tal tu día a día?'],
    MemoryCategory.estudio: ['¿Cómo va tu aprendizaje?', '¿Qué has aprendido recientemente?'],
    MemoryCategory.rutina: ['¿Sigues con la misma rutina?', '¿Has cambiado algo?'],
    MemoryCategory.gusto: ['¿Sigues disfrutando de eso?', '¿Qué has hecho recientemente?'],
    MemoryCategory.evento: ['¿Cómo fue la experiencia?', '¿Qué más pasó?'],
    MemoryCategory.otro: ['¿Qué más hay de eso?', '¿Cómo sigue todo?'],
  };

  RecallResponse recall({
    required String query,
    required MemoryManager memoryManager,
    String? userName,
  }) {
    final results = memoryManager.search(query);

    if (results.isEmpty) {
      final important = memoryManager.getMostImportant(limit: 3);
      if (important.isNotEmpty) {
        final m = important.first;
        return RecallResponse(
          text: 'No encontré algo específico sobre eso, pero recuerdo que ${m.value} es algo importante para ti.',
          memories: [m],
          followUp: '¿Quieres contarme algo más sobre eso?',
        );
      }
      return const RecallResponse(
        text: 'No tengo recuerdos sobre eso aún. Si quieres que lo recuerde, escríbelo en tu diario.',
        memories: [],
      );
    }

    final best = results.first;
    final template = _greetings[_random.nextInt(_greetings.length)];
    final greeting = template.replaceAll('%s', best.value);

    final categoryPhrase = _categoryPhrases[best.category] ?? '';

    String importancePhrase = '';
    if (best.timesMentioned >= 3) {
      final impTemplate = _importanceGrowth[_random.nextInt(_importanceGrowth.length)];
      importancePhrase = impTemplate
          .replaceAll('%d', best.timesMentioned.toString())
          .replaceAll('%s', best.value);
    }

    final parts = [greeting];
    if (categoryPhrase.isNotEmpty) parts.add(categoryPhrase);
    if (importancePhrase.isNotEmpty) parts.add(importancePhrase);

    String? followUp;
    final questions = _followUpQuestions[best.category];
    if (questions != null && questions.isNotEmpty) {
      followUp = questions[_random.nextInt(questions.length)]
          .replaceAll('%s', best.value);
    }

    return RecallResponse(
      text: parts.join(' '),
      memories: results.take(3).toList(),
      followUp: followUp,
    );
  }

  RecallResponse recallWithContext({
    required String currentText,
    required MemoryManager memoryManager,
    required List<MemoryItem> memories,
    required List<EmotionAnalysis> emotionHistory,
    String? userName,
  }) {
    final context = _contextService.buildContext(
      currentText: currentText,
      memories: memories,
      history: emotionHistory,
    );

    final extracted = memoryManager.getContextFor(currentText);
    if (extracted.isEmpty) {
      return const RecallResponse(
        text: '',
        memories: [],
      );
    }

    final best = extracted.first;
    final phrase = context.fraseContextual;

    final parts = <String>[];
    if (phrase.isNotEmpty) {
      parts.add(phrase);
    } else {
      final template = _greetings[_random.nextInt(_greetings.length)];
      parts.add(template.replaceAll('%s', best.value));
    }

    final trendComment = _trendComment(context.tendenciaEmocional);
    if (trendComment.isNotEmpty) parts.add(trendComment);

    return RecallResponse(
      text: parts.join(' '),
      memories: extracted.take(3).toList(),
      followUp: _buildFollowUp(extracted, context),
    );
  }

  List<String> getSuggestions(MemoryManager memoryManager) {
    final suggestions = <String>[];
    suggestions.addAll(memoryManager.getFollowUpSuggestions(maxSuggestions: 2));

    final recent = memoryManager.getRecent(limit: 3);
    for (final m in recent) {
      if (suggestions.length >= 4) break;
      final categoryPhrase = _categoryPhrases[m.category] ?? '';
      if (categoryPhrase.isNotEmpty) {
        suggestions.add(categoryPhrase);
      }
    }

    return suggestions.take(4).toList();
  }

  String _trendComment(String trend) {
    switch (trend) {
      case 'mejorando':
        return ' He notado que últimamente tus emociones van mejor.';
      case 'empeorando':
        return ' Parece que los últimos días han sido más difíciles.';
      case 'estable':
        return '';
      default:
        return '';
    }
  }

  String? _buildFollowUp(List<MemoryItem> memories, ConversationContext context) {
    if (memories.isEmpty) return null;
    final best = memories.first;
    final questions = _followUpQuestions[best.category];
    if (questions == null || questions.isEmpty) return null;
    return questions[_random.nextInt(questions.length)]
        .replaceAll('%s', best.value);
  }
}
