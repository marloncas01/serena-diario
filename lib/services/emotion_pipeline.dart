import '../models/emotion.dart';
import '../models/memory_item.dart';
import 'emotion_engine.dart';
import 'emotion_interpreter.dart';
import 'emotional_response_engine.dart';
import 'crisis_detector.dart';
import 'memory_manager.dart';
import 'conversation_context_service.dart';
import 'ai_provider.dart';
import 'ai_config_service.dart';

class EmotionPipelineResult {
  const EmotionPipelineResult({
    required this.analysis,
    required this.interpretation,
    required this.crisis,
    required this.response,
    required this.memoriesAdded,
    required this.relatedMemory,
  });

  final EmotionAnalysis analysis;
  final EmotionInterpretation interpretation;
  final CrisisResult crisis;
  final EmotionalResponse response;
  final List<MemoryItem> memoriesAdded;
  final MemoryItem? relatedMemory;
}

class EmotionPipeline {
  EmotionPipeline._();

  static final EmotionPipeline _instance = EmotionPipeline._();
  factory EmotionPipeline() => _instance;

  final MemoryManager _memoryManager = MemoryManager();
  final List<EmotionAnalysis> _analysisHistory = [];
  final ConversationContextService _contextService =
      ConversationContextService();
  final AIProviderManager _aiManager = AIProviderManager();
  final AIConfigService _config = AIConfigService();

  bool _isInitialized = false;
  Future<void>? _initFuture;

  MemoryManager get memoryManager => _memoryManager;

  List<EmotionAnalysis> get analysisHistory =>
      List.unmodifiable(_analysisHistory);

  Future<void> init() async {
    if (_isInitialized) return;
    _initFuture ??= _doInit();
    await _initFuture;
  }

  Future<void> _doInit() async {
    await _aiManager.init();
    _isInitialized = true;
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized && _initFuture != null) {
      await _initFuture;
    }
  }

  Future<EmotionPipelineResult> processEntry(String text) async {
    await ensureInitialized();

    var analysis = EmotionEngine.analyze(text);
    final interpretation = EmotionInterpreter.interpret(analysis);
    final crisis = CrisisDetector.detectWithContext(
      text,
      history: _analysisHistory,
    );
    final memories = _memoryManager.addFromText(text);

    analysis = _fuseAnalysis(text, analysis);
    analysis = _applyCrisisToAnalysis(crisis, analysis);

    _analysisHistory.add(analysis);
    if (_analysisHistory.length > 100) {
      _analysisHistory.removeRange(0, _analysisHistory.length - 100);
    }

    final relatedMemory = _findRelatedMemory(text);

    final conversationContext = _contextService.buildContext(
      currentText: text,
      memories: _memoryManager.all,
      history: _analysisHistory,
    );

    final responseContext = ResponseContext(
      text: text,
      analysis: analysis,
      interpretation: interpretation,
      crisis: crisis,
      memories: _memoryManager.all,
      relatedMemory: relatedMemory,
      history: _analysisHistory,
      conversationContext: conversationContext,
      conversationHistory: _config.history,
    );

    if (crisis.highRisk) {
      return EmotionPipelineResult(
        analysis: analysis,
        interpretation: interpretation,
        crisis: crisis,
        response: EmotionalResponseEngine.generateWithCrisis(
          interpretation,
          crisis,
        ),
        memoriesAdded: memories,
        relatedMemory: relatedMemory,
      );
    }

    EmotionalResponse response;
    try {
      response = await _aiManager.generate(responseContext);
    } catch (_) {
      response = EmotionalResponseEngine.generateWithContext(responseContext);
    }

    return EmotionPipelineResult(
      analysis: analysis,
      interpretation: interpretation,
      crisis: crisis,
      response: response,
      memoriesAdded: memories,
      relatedMemory: relatedMemory,
    );
  }

  List<MemoryItem> getRecentMemories({int limit = 5}) {
    return _memoryManager.getMostImportant(limit: limit);
  }

  Map<String, int> getEmotionTrends({int lastDays = 7}) {
    final counts = <String, int>{};

    for (final analysis in _analysisHistory) {
      if (analysis.rankings.isEmpty) continue;
      for (final score in analysis.rankings.take(3)) {
        counts[score.emotion.name] = (counts[score.emotion.name] ?? 0) + 1;
      }
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(5));
  }

  static const Set<String> _criticalContextWords = {
    'muerte', 'murió', 'murio', 'falleció', 'fallecio', 'morirse',
    'duelo', 'funeral', 'entierro', 'hospital', 'cáncer', 'cancer',
    'accidente', 'operación', 'operacion', 'diagnóstico', 'diagnostico',
    'ruptura', 'divorcio', 'despedido', 'deprimido', 'deprimida',
    'depresión', 'depresion', 'desesperanza', 'desesperado',
    'llorar', 'llorando', 'lloré', 'llore',
    'no tiene sentido', 'no vale la pena', 'no aguanto', 'no soporto',
    'vacío', 'vacio', 'perder', 'perdí', 'perdi',
    'ataque de pánico', 'pánico', 'panico', 'ahogo', 'temblor',
    'insomnio', 'no puedo dormir',
  };

  static const Map<String, String> _criticalToEmotion = {
    'muerte': 'tristeza', 'murió': 'tristeza', 'murio': 'tristeza',
    'falleció': 'tristeza', 'fallecio': 'tristeza', 'morirse': 'tristeza',
    'duelo': 'tristeza', 'funeral': 'tristeza', 'entierro': 'tristeza',
    'hospital': 'tristeza', 'cáncer': 'tristeza', 'cancer': 'tristeza',
    'accidente': 'tristeza', 'operación': 'tristeza', 'operacion': 'tristeza',
    'diagnóstico': 'tristeza', 'diagnostico': 'tristeza',
    'ruptura': 'tristeza', 'divorcio': 'tristeza', 'despedido': 'tristeza',
    'deprimido': 'tristeza', 'deprimida': 'tristeza',
    'depresión': 'tristeza', 'depresion': 'tristeza',
    'llorar': 'tristeza', 'llorando': 'tristeza', 'lloré': 'tristeza', 'llore': 'tristeza',
    'perder': 'tristeza', 'perdí': 'tristeza', 'perdi': 'tristeza',
    'desesperanza': 'desesperanza', 'desesperado': 'desesperanza',
    'desesperada': 'desesperanza',
    'vacío': 'tristeza', 'vacio': 'tristeza',
    'no tiene sentido': 'desesperanza', 'no vale la pena': 'desesperanza',
    'no aguanto': 'desesperanza', 'no soporto': 'desesperanza',
    'ataque de pánico': 'ansiedad', 'pánico': 'ansiedad', 'panico': 'ansiedad',
    'ahogo': 'ansiedad', 'temblor': 'ansiedad',
    'insomnio': 'ansiedad', 'no puedo dormir': 'ansiedad',
  };

  static const Set<String> _positiveIds = {
    'alegria', 'felicidad', 'amor', 'gratitud', 'esperanza',
    'calma', 'orgullo', 'motivacion', 'inspiracion',
    'entusiasmo', 'ternura', 'ilusion', 'alivio', 'optimismo',
    'confianza', 'diversion', 'paz',
  };

  /// Si hay riesgo de crisis, fuerza la desesperanza como emoción dominante.
  EmotionAnalysis _applyCrisisToAnalysis(
    CrisisResult crisis,
    EmotionAnalysis analysis,
  ) {
    if (!crisis.highRisk) return analysis;

    final despair = emotionById('desesperanza');
    if (despair == null) return analysis;

    final others = analysis.rankings
        .where((s) => s.emotion.id != 'desesperanza' && s.emotion.id != 'tristeza')
        .take(2)
        .toList();

    final reranked = <EmotionScore>[
      EmotionScore(
        emotion: despair,
        percentage: double.parse(
          (70 - crisis.confidence * 5).toStringAsFixed(1),
        ),
        matchedKeywords: const [],
      ),
    ];

    final sadness = emotionById('tristeza');
    if (sadness != null) {
      reranked.add(EmotionScore(
        emotion: sadness,
        percentage: double.parse(
          (15 + crisis.confidence * 5).toStringAsFixed(1),
        ),
        matchedKeywords: const [],
      ));
    }

    for (final score in others) {
      reranked.add(EmotionScore(
        emotion: score.emotion,
        percentage: double.parse((score.percentage * 0.2).toStringAsFixed(1)),
        matchedKeywords: const [],
      ));
    }

    final allKw = List<String>.from(analysis.detectedKeywords);
    for (final trigger in crisis.triggers) {
      if (!allKw.contains(trigger)) allKw.add(trigger);
    }

    return EmotionAnalysis(
      rankings: reranked,
      confidence: double.parse(
        analysis.confidence.clamp(0, 100).toStringAsFixed(1),
      ),
      detectedKeywords: allKw..sort(),
      explanation: 'Se detectó un momento de alta vulnerabilidad. '
          'La desesperanza domina este análisis.\n'
          '${analysis.explanation}',
    );
  }

  EmotionAnalysis _fuseAnalysis(String text, EmotionAnalysis original) {
    if (original.rankings.isEmpty) return original;

    final normalized = text.toLowerCase();
    final detectedCritical = <String>[];
    String? forcedEmotion;

    for (final word in _criticalContextWords) {
      if (normalized.contains(word)) {
        detectedCritical.add(word);
        final mapped = _criticalToEmotion[word];
        if (mapped != null && forcedEmotion == null) {
          forcedEmotion = mapped;
        }
      }
    }

    if (detectedCritical.isEmpty) return original;

    final topEmotion = original.rankings.first.emotion;
    final topIsPositive = _positiveIds.contains(topEmotion.id);

    if (topIsPositive && forcedEmotion != null) {
      final forcedDef = emotionById(forcedEmotion);
      if (forcedDef != null) {
        final adjustedScores = <String, double>{};
        for (final score in original.rankings) {
          if (_positiveIds.contains(score.emotion.id)) {
            adjustedScores[score.emotion.id] = score.percentage * 0.1;
          } else {
            adjustedScores[score.emotion.id] = score.percentage;
          }
        }
        adjustedScores[forcedEmotion] = (adjustedScores[forcedEmotion] ?? 0) + 50.0;

        final entries = adjustedScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final total = entries.fold<double>(0, (s, e) => s + e.value);
        if (total == 0) return original;

        final reranked = <EmotionScore>[];
        for (final entry in entries) {
          final emotion = emotionById(entry.key);
          if (emotion == null) continue;
          final pct = (entry.value / total) * 100;
          if (pct < 1.0) continue;
          reranked.add(EmotionScore(
            emotion: emotion,
            percentage: double.parse(pct.toStringAsFixed(1)),
            matchedKeywords: const [],
          ));
        }

        if (reranked.isNotEmpty) {
          final allKw = List<String>.from(original.detectedKeywords);
          for (final w in detectedCritical) {
            if (!allKw.contains(w)) allKw.add(w);
          }
          return EmotionAnalysis(
            rankings: reranked,
            confidence: original.confidence,
            detectedKeywords: allKw..sort(),
            explanation: original.explanation,
          );
        }
      }
    }

    return original;
  }

  MemoryItem? _findRelatedMemory(String text) {
    final results = _memoryManager.search(text);
    if (results.isEmpty) return null;

    final recent = results.firstWhere(
      (m) => m.timesMentioned >= 2 || m.importance > 0.5,
      orElse: () => results.first,
    );
    return recent;
  }
}
