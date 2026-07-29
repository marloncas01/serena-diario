import 'ai_provider.dart';

class PromptBuilder {
  PromptBuilder._();

  static const _personalityPrompt = '''
Eres Serena, una amiga inteligente que acompaña a las personas en su bienestar emocional.

REGLAS INQUEBRANTABLES:
- Habla como una amiga cercana, no como terapeuta ni psicóloga.
- NUNCA digas "como psicóloga" o "como terapeuta".
- NUNCA diagnostiques enfermedades mentales.
- NUNCA juzgues lo que la persona siente o vive.
- Sé cálida, empática, genuina y respetuosa.
- Usa español latino natural, conversacional, nada formal.
- Máximo 250 palabras por respuesta.
- Termina normalmente con una pregunta abierta que invite a seguir compartiendo.
- Sé observadora: nota patrones emocionales sin ser invasiva.
- Valida sentimientos antes de ofrecer perspectivas.
- No des consejos médicos ni psicológicos profesionales.

REGLAS DE ANÁLISIS EMOCIONAL:
- Si el texto menciona muerte, pérdida, duelo, enfermedad grave, hospital, cáncer, accidente, divorcio, ruptura o despedida, la emoción principal DEBE ser tristeza o desesperanza. NUNCA felicidad.
- Si el texto describe síntomas de ansiedad (ataque de pánico, no poder respirar, temblor, insomnio), la emoción principal DEBE ser ansiedad.
- Si el texto expresa soledad o abandono, la emoción principal DEBE ser soledad.
- NUNCA clasifiques una frase claramente negativa como positiva.
- Prioriza la emoción que refleje el contexto real, no solo palabras sueltas.''';

  static String buildResponsePrompt(ResponseContext context) {
    final buffer = StringBuffer();
    buffer.writeln(_personalityPrompt);
    buffer.writeln();
    buffer.writeln('=== CONTEXTO EMOCIONAL ===');

    if (context.analysis.rankings.isNotEmpty) {
      final top = context.analysis.rankings.first;
      buffer.writeln('Emoción principal: ${top.emotion.name} '
          '(${(top.percentage * 100).round()}%)');
      if (context.analysis.rankings.length > 1) {
        final second = context.analysis.rankings[1];
        buffer.writeln('Emoción secundaria: ${second.emotion.name} '
            '(${(second.percentage * 100).round()}%)');
      }
    }

    buffer.writeln('Explicación: ${context.interpretation.summary}');
    buffer.writeln('Patrón: ${context.interpretation.pattern.name}');

    if (context.crisis.highRisk) {
      buffer.writeln('⚠ Crisis detectada: ${context.crisis.triggers.join(", ")}');
    }

    if (context.analysis.rankings.isNotEmpty) {
      final topEmotion = context.analysis.rankings.first.emotion;
      final topCategory = topEmotion.category;
      buffer.writeln('Categoría emocional detectada: $topCategory');
    }

    final textLower = context.text.toLowerCase();
    final criticalWords = ['muerte', 'murió', 'murio', 'falleció', 'fallecio',
      'duelo', 'hospital', 'cáncer', 'cancer', 'accidente', 'ruptura',
      'divorcio', 'despedido', 'perder', 'llorar', 'llorando',
      'deprimido', 'deprimida', 'depresión', 'vacío', 'no tiene sentido',
      'no vale la pena', 'no aguanto', 'ataque', 'pánico', 'panico',
      'respirar', 'ahogo', 'temblor', 'insomnio', 'no puedo dormir',
    ];
    final detectedCritical = criticalWords.where((w) => textLower.contains(w)).toList();
    if (detectedCritical.isNotEmpty) {
      buffer.writeln('⚠ Palabras de contexto crítico detectadas: ${detectedCritical.join(", ")}');
      buffer.writeln('IMPORTANTE: Prioriza tristeza/ansiedad/desesperanza. NUNCA felicidad.');
    }

    if (context.memories.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Memorias importantes del usuario:');
      for (final mem in context.memories.take(5)) {
        final cat = mem.category.name;
        buffer.writeln('- [$cat] ${mem.value} '
            '(mencionado ${mem.timesMentioned} veces)');
      }
    }

    if (context.relatedMemory != null) {
      buffer.writeln('Memoria relacionada: ${context.relatedMemory!.value}');
    }

    if (context.history.length > 3) {
      final recent = context.history.skip(context.history.length - 5);
      final emotionNames = recent
          .map((e) => e.rankings.isNotEmpty
              ? e.rankings.first.emotion.name
              : 'neutral')
          .toList();
      buffer.writeln();
      buffer.writeln('Tendencia emocional reciente: '
          '${emotionNames.join(", ")}');
    }

    if (context.conversationContext != null) {
      final ctx = context.conversationContext!;
      if (ctx.temasRecurrentes.isNotEmpty) {
        buffer.writeln('Temas recurrentes: ${ctx.temasRecurrentes.join(", ")}');
      }
      buffer.writeln('Tendencia general: ${ctx.tendenciaEmocional}');
    }

    if (context.conversationHistory.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Historial de conversación reciente:');
      final recent =
          context.conversationHistory.skip(context.conversationHistory.length - 6);
      for (final msg in recent) {
        final role = msg.isUser ? 'Tú' : 'Serena';
        final text =
            msg.text.length > 80 ? '${msg.text.substring(0, 80)}...' : msg.text;
        buffer.writeln('$role: $text');
      }
    }

    buffer.writeln();
    buffer.writeln('=== ENTRADA DEL USUARIO ===');
    buffer.writeln(context.text);
    buffer.writeln();
    buffer.writeln(
        'Responde como Serena, con empatía genuina y en español natural.');

    return buffer.toString();
  }

  static String buildInsightPrompt(ResponseContext context) {
    final buffer = StringBuffer();
    buffer.writeln(_personalityPrompt);
    buffer.writeln();
    buffer.writeln('Genera un insight emocional breve (1-2 oraciones).');
    buffer.writeln('Sé observadora pero no invasiva.');
    buffer.writeln();

    if (context.history.isNotEmpty) {
      final recent = context.history.skip(
        context.history.length > 5 ? context.history.length - 5 : 0,
      );
      buffer.writeln('Tendencia: '
          '${recent.map((e) => e.rankings.isNotEmpty ? e.rankings.first.emotion.name : "neutral").join(", ")}');
    }

    if (context.memories.isNotEmpty) {
      buffer.writeln('Memorias clave: '
          '${context.memories.map((m) => m.value).join("; ")}');
    }

    buffer.writeln('Patrón: ${context.interpretation.pattern.name}');

    return buffer.toString();
  }

  static String buildConversationPrompt(ResponseContext context) {
    final buffer = StringBuffer();
    buffer.writeln(_personalityPrompt);
    buffer.writeln();

    if (context.conversationContext != null) {
      final ctx = context.conversationContext!;
      if (ctx.temasRecurrentes.isNotEmpty) {
        buffer.writeln('Tema actual: ${ctx.temasRecurrentes.first}');
      }
    }

    if (context.conversationHistory.isNotEmpty) {
      buffer.writeln('Historial:');
      final recent =
          context.conversationHistory.skip(context.conversationHistory.length - 6);
      for (final msg in recent) {
        final role = msg.isUser ? 'Tú' : 'Serena';
        buffer.writeln('$role: ${msg.text}');
      }
    }

    buffer.writeln();
    buffer.writeln('Usuario: ${context.text}');

    return buffer.toString();
  }
}
