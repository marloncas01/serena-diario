import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../ai_provider.dart';
import '../prompt_builder.dart';
import '../emotional_response_engine.dart';
import '../ai_config_service.dart';

class GeminiProvider implements AIProvider {
  GeminiProvider({
    required String apiKey,
    String? modelId,
  })  : _apiKey = ApiKeyDiagnostics.sanitize(apiKey),
        _modelId = modelId ?? AIConfigService.geminiModelFromEnvironment {
    ApiKeyDiagnostics.logSummary(_apiKey, origin: 'Gemini');
  }

  static const _requestTimeout = Duration(seconds: 20);

  final String _apiKey;
  final String _modelId;

  GenerativeModel? _model;
  bool _available = false;

  bool get isInitialized => _available;

  String get modelId => _modelId;

  GenerativeModel get _getModel {
    _model ??= GenerativeModel(
      model: _modelId,
      apiKey: _apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(
            HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
      ],
      generationConfig: GenerationConfig(
        temperature: 0.85,
        topP: 0.9,
        topK: 40,
        maxOutputTokens: 300,
      ),
    );
    return _model!;
  }

  @override
  String get name => 'gemini';

  @override
  bool get isAvailable => _available;

  Future<void> init() async {
    if (_apiKey.isEmpty) {
      debugPrint('[Gemini] Init: SKIP (API key vacía tras normalizar)');
      _available = false;
      AIConfigService().setProviderAvailable(false);
      return;
    }
    try {
      final response = await _getModel.generateContent([
        Content.text('hola'),
      ]).timeout(_requestTimeout);
      _available = response.text != null && response.text!.isNotEmpty;
      debugPrint('[Gemini] Init: ${_available ? "OK" : "FAIL"} '
          '(modelo: $_modelId)');
    } catch (e) {
      debugPrint('[Gemini] Init failed: ${e.runtimeType}: $e');
      _available = false;
    }
    AIConfigService().setProviderAvailable(_available);
  }

  @override
  Future<EmotionalResponse> generateResponse(ResponseContext context) async {
    if (!_available) {
      return await FallbackProvider().generateResponse(context);
    }

    try {
      final prompt = PromptBuilder.buildResponsePrompt(context);
      final response =
          await _getModel.generateContent([Content.text(prompt)]).timeout(
        _requestTimeout,
      );

      if (response.text == null || response.text!.isEmpty) {
        return await FallbackProvider().generateResponse(context);
      }

      final local = await FallbackProvider().generateResponse(context);
      return EmotionalResponse(
        greeting: local.greeting,
        validation: local.validation,
        interpretation: local.interpretation,
        suggestion: local.suggestion,
        reflectionQuestion: local.reflectionQuestion,
        emergencyRisk: local.emergencyRisk,
        aiMessage: response.text,
      );
    } catch (e) {
      debugPrint('[Gemini] Error: ${e.runtimeType}: $e');
      _available = false;
      return await FallbackProvider().generateResponse(context);
    }
  }

  @override
  Future<String> generateInsight(ResponseContext context) async {
    if (!_available) return '';

    try {
      final prompt = PromptBuilder.buildInsightPrompt(context);
      final response =
          await _getModel.generateContent([Content.text(prompt)]).timeout(
        _requestTimeout,
      );
      return response.text ?? '';
    } catch (e) {
      debugPrint('[Gemini] Insight error: ${e.runtimeType}: $e');
      _available = false;
      return '';
    }
  }

  void invalidate() {
    _available = false;
    _model = null;
  }
}
