import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../data/motivational_quotes.dart';
import '../providers/journal_provider.dart';
import '../services/emotional_history_service.dart';
import '../services/emotion_pipeline.dart';
import '../theme/brand/brand_durations.dart';
import '../utils/journal_insights.dart';
import '../widgets/empty_state.dart';
import '../widgets/emotional_evolution_card.dart';
import '../widgets/emotional_timeline.dart';
import '../widgets/glass_card.dart';
import '../widgets/ui/premium_divider.dart';

/// Pantalla "Mi evolución": recorrido completo del estado emocional del
/// usuario, con reporte de tendencias, estadísticas de constancia, línea de
/// tiempo y una frase inspiradora según su momento.
class EvolutionScreen extends StatelessWidget {
  const EvolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journal = context.watch<JournalProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > AppBreakpoints.compact;
    final horizontalPadding = isWide ? 32.0 : 16.0;

    if (journal.status != JournalStatus.ready) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = journal.entries;
    final pipeline = EmotionPipeline();
    final report =
        EmotionalHistoryService().analyze(pipeline.analysisHistory);

    final daysAnalyzed = report.diasAnalizados;
    final streak = JournalInsights.streak(entries);
    final positiveRatio = JournalInsights.positiveRatio(entries);
    final totalEntries = entries.length;

    final quote = _quoteFor(report);

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          24,
          horizontalPadding,
          110,
        ),
        children: [
          Semantics(
            header: true,
            child: Text('Mi evolución', style: theme.textTheme.displaySmall),
          ),
          const SizedBox(height: 4),
          Text(
            'Así ha sido tu camino emocional.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (entries.isEmpty)
            EmptyState(
              icon: Icons.auto_graph_rounded,
              title: 'Aún no hay evolución que mostrar',
              message:
                  'Escribe tus primeras reflexiones y aquí verás cómo avanza '
                  'tu estado emocional.',
            )
          else ...[
            // ── Estado actual ──
            EmotionalEvolutionCard(report: report),
            const SizedBox(height: AppSpacing.md),

            // ── Constancia ──
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu constancia',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          value: '$totalEntries',
                          label: 'entradas',
                          icon: Icons.edit_note_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: _MiniStat(
                          value: '$daysAnalyzed',
                          label: 'días analizados',
                          icon: Icons.insights_rounded,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      Expanded(
                        child: _MiniStat(
                          value: '$streak',
                          label: 'racha en días',
                          icon: Icons.local_fire_department_rounded,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      Expanded(
                        child: _MiniStat(
                          value:
                              '${positiveRatio.toStringAsFixed(0)}%',
                          label: 'días positivos',
                          icon: Icons.favorite_rounded,
                          color: Colors.green.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Línea de tiempo ──
            EmotionalTimeline(entries: entries, limit: 15),
            const SizedBox(height: AppSpacing.md),

            // ── Frase inspiradora ──
            GlassCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
                  theme.colorScheme.tertiaryContainer.withValues(alpha: 0.45),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Palabras para ti',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  PremiumDivider(withDot: false),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: BrandDurations.normal,
                    child: Text(
                      quote,
                      key: ValueKey(quote),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _quoteFor(EmotionalHistoryReport report) {
    if (report.hayMejora) {
      return MotivationalQuotes.forCategory('crecimiento');
    }
    if (report.hayRecaida) {
      return MotivationalQuotes.forCategory('esperanza');
    }
    return MotivationalQuotes.forCategory('autocuidado');
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

