import 'package:flutter/foundation.dart';
import '../models/emotion.dart';
import '../models/memory_item.dart';
import 'emotion_interpreter.dart';
import 'crisis_detector.dart';
import 'conversation_context_service.dart';
import 'emotional_response_engine.dart';
import 'ai_config_service.dart';
import 'providers/gemini_provider.dart';
import 'user_profile.dart';

/// Utilidad para inspeccionar una API key sin exponerla nunca completa.
class ApiKeyDiagnostics {
  ApiKeyDiagnostics._();

  static void logSummary(String key, {String origin = 'AI'}) {
    if (key.isEmpty) {
      debugPrint('[$origin] API KEY: vacía '
          '(no se pasó --dart-define=GEMINI_API_KEY)');
      return;
    }
    debugPrint('[$origin] API LENGTH: ${key.length}');
    debugPrint(
        '[$origin] START: ${key.substring(0, key.length >= 6 ? 6 : key.length)}');
    debugPrint(
        '[$origin] END: ${key.length > 4 ? key.substring(key.length - 4) : key}');
    final invalidChars = <int>[];
    for (final unit in key.codeUnits) {
      final char = String.fromCharCode(unit);
      if (!RegExp(r'[A-Za-z0-9_-]').hasMatch(char)) invalidChars.add(unit);
    }
    if (invalidChars.isNotEmpty) {
      debugPrint(
          '[$origin] [WARNING] La key contiene caracteres no permitidos '
          '(espacios, comillas, saltos de línea...). codePoints=$invalidChars');
    }
  }

  /// Normaliza una API key: elimina espacios, saltos de línea, tabulaciones
  /// y comillas simples/dobles que se hayan colado al copiar/pegar.
  static String sanitize(String raw) {
    var key = raw.trim();
    if (key.length >= 2 &&
        ((key.startsWith('"') && key.endsWith('"')) ||
            (key.startsWith("'") && key.endsWith("'")))) {
      key = key.substring(1, key.length - 1).trim();
    }
    return key.replaceAll(RegExp(r'[\r\n\t]'), '');
  }
}

class ResponseContext {
  const ResponseContext({
    required this.text,
    required this.analysis,
    required this.interpretation,
    required this.crisis,
    required this.memories,
    required this.relatedMemory,
    required this.history,
    required this.conversationContext,
    this.conversationHistory = const [],
    this.sex = UserSex.prefieroNoDecirlo,
  });

  final String text;
  final EmotionAnalysis analysis;
  final EmotionInterpretation interpretation;
  final CrisisResult crisis;
  final List<MemoryItem> memories;
  final MemoryItem? relatedMemory;
  final List<EmotionAnalysis> history;
  final ConversationContext? conversationContext;
  final List<ConversationMessage> conversationHistory;
  final UserSex sex;
}

abstract class AIProvider {
  String get name;
  bool get isAvailable;
  Future<EmotionalResponse> generateResponse(ResponseContext context);
  Future<String> generateInsight(ResponseContext context);
}

class FallbackProvider implements AIProvider {
  @override
  String get name => 'fallback';

  @override
  bool get isAvailable => true;

  @override
  Future<EmotionalResponse> generateResponse(ResponseContext context) async {
    return EmotionalResponseEngine.generateWithContext(context);
  }

  @override
  Future<String> generateInsight(ResponseContext context) async {
    return '';
  }
}

class AIProviderManager {
  AIProviderManager._();
  static final AIProviderManager _instance = AIProviderManager._();
  factory AIProviderManager() => _instance;

  AIProvider _provider = FallbackProvider();
  AIProvider get provider => _provider;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _lastInputText;
  EmotionalResponse? _lastResponse;

  final AIConfigService _config = AIConfigService();
  AIConfigService get config => _config;

  void registerProvider(AIProvider provider) {
    _provider = provider;
  }

  void useFallback() {
    _provider = FallbackProvider();
  }

  Future<void> init() async {
    await _config.load();

    try {
      const apiKey = String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isNotEmpty) {
        debugPrint('[AI] API key detectada, inicializando Gemini...');
        ApiKeyDiagnostics.logSummary(apiKey, origin: 'AI');
        final gemini = GeminiProvider(apiKey: apiKey);
        registerProvider(gemini);
        await gemini.init();
        debugPrint('[AI] Gemini available: ${gemini.isAvailable} '
            '(modelo: ${gemini.modelId})');
      } else {
        debugPrint('[AI] No API key, local mode only');
        useFallback();
      }
    } catch (e) {
      debugPrint('[AI] Init error: ${e.runtimeType}: $e');
      useFallback();
    }
  }

  Future<EmotionalResponse> generate(ResponseContext context) async {
    if (_lastInputText == context.text && _lastResponse != null) {
      debugPrint('[AI] Reusing cached response for identical input');
      return _lastResponse!;
    }

    if (_isProcessing) {
      return await FallbackProvider().generateResponse(context);
    }

    _isProcessing = true;
    try {
      if (_config.aiEnabled && _provider.isAvailable) {
        debugPrint('[AI] Using ${_provider.name}');
        final response = await _provider.generateResponse(context);

        await _config.addMessage(context.text, isUser: true);
        if (response.aiMessage != null) {
          await _config.addMessage(response.aiMessage!, isUser: false);
        }

        _lastInputText = context.text;
        _lastResponse = response;
        return response;
      }

      debugPrint('[AI] Using fallback (offline/local)');
      final response = await FallbackProvider().generateResponse(context);
      _lastInputText = context.text;
      _lastResponse = response;
      return response;
    } catch (e) {
      debugPrint('[AI] Error: $e, using fallback');
      final response = await FallbackProvider().generateResponse(context);
      _lastInputText = context.text;
      _lastResponse = response;
      return response;
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> clearConversationHistory() async {
    await _config.clearHistory();
  }
}
