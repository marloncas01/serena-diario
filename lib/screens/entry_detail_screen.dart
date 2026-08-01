import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/app_texts.dart';
import '../models/emotion.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../providers/journal_provider.dart';
import '../services/ai_provider.dart';
import '../services/crisis_detector.dart';
import '../services/emotion_engine.dart';
import '../services/emotion_interpreter.dart';
import '../services/emotional_response_engine.dart';
import '../utils/entry_actions.dart';
import '../widgets/app_card.dart';
import '../widgets/dominant_emotion_badge.dart';

/// Pantalla de detalle de una entrada: reflexión completa, análisis emocional
/// y la respuesta de Serena (regenerada de forma local y determinista).
class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final entries = journal.entries.where((e) => e.id == entryId).toList();
    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Esta entrada ya no existe.')),
      );
    }
    return _EntryDetailBody(entry: entries.first);
  }
}

class _EntryDetailBody extends StatelessWidget {
  const _EntryDetailBody({required this.entry});

  final JournalEntry entry;

  _AnalysisData _compute() {
    final analysis = EmotionEngine.analyze(entry.note);
    final interpretation = EmotionInterpreter.interpret(analysis);
    final crisis = CrisisDetector.detect(entry.note);
    final response = EmotionalResponseEngine.generateWithContext(
      ResponseContext(
        text: entry.note,
        analysis: analysis,
        interpretation: interpretation,
        crisis: crisis,
        memories: const [],
        relatedMemory: null,
        history: const [],
        conversationContext: null,
      ),
    );
    return _AnalysisData(analysis, interpretation, crisis, response);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = moodByName(entry.mood);
    final data = _compute();
    final wordCount = entry.note
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat("EEEE, d 'de' MMMM · HH:mm", 'es_ES').format(
            entry.createdAt,
          ),
        ),
        actions: [
          IconButton(
            tooltip: AppTexts.editEntry,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => editEntrySheet(context, entry),
          ),
          IconButton(
            tooltip: AppTexts.deleteEntry,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final deleted = await confirmDeleteEntry(context, entry.id);
              if (deleted && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          // ── Cabecera: mood + emoción dominante ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'mood-${entry.id}',
                      child: Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              mood.color,
                              mood.color.withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mood.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$wordCount palabras',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (entry.dominantEmotionId != null) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DominantEmotionBadge(
                      emotionId: entry.dominantEmotionId,
                      name: entry.dominantEmotionName,
                      emoji: entry.dominantEmotionEmoji,
                      intensity: entry.dominantEmotionIntensity,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  entry.note,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
                ),
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entry.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                            ),
                            child: Text(
                              '#$tag',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Análisis emocional ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análisis emocional',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.interpretation.summary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...data.analysis.rankings.take(4).map(
                      (score) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              score.emotion.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          score.emotion.name,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        '${score.percentage.round()}%',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: score.emotion.color,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.pill,
                                    ),
                                    child: LinearProgressIndicator(
                                      value: (score.percentage / 100)
                                          .clamp(0.0, 1.0),
                                      color: score.emotion.color,
                                      minHeight: 6,
                                      backgroundColor: theme
                                          .colorScheme.surfaceContainerHighest,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (data.crisis.highRisk) ...[
                  const Divider(height: 8),
                  const SizedBox(height: 4),
                  _CrisisBanner(confidence: data.crisis.confidence),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Respuesta de Serena ──
          AppCard(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35),
              ],
            ),
            elevation: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💜', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Lo que Serena vio',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ResponseLine(text: data.response.greeting),
                _ResponseLine(text: data.response.validation),
                _ResponseLine(text: data.response.interpretation),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Recomendación',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.response.suggestion,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Reflexión sugerida',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.response.reflectionQuestion,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseLine extends StatelessWidget {
  const _ResponseLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
          height: 1.4,
        ),
      ),
    );
  }
}

class _CrisisBanner extends StatelessWidget {
  const _CrisisBanner({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 18, color: theme.colorScheme.error),
              const SizedBox(width: 6),
              Text(
                'Momento de alta vulnerabilidad',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Hay personas que pueden ayudarte. Línea de la Vida: 800 911 2000.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisData {
  const _AnalysisData(this.analysis, this.interpretation, this.crisis, this.response);

  final EmotionAnalysis analysis;
  final EmotionInterpretation interpretation;
  final CrisisResult crisis;
  final EmotionalResponse response;
}
