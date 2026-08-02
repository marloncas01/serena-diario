import 'package:flutter/material.dart';

import '../services/emotional_pattern_analyzer.dart';
import '../services/pattern_insight_generator.dart';
import '../theme/brand/brand_spacing.dart';
import 'glass_card.dart';

class PatternInsightsCard extends StatelessWidget {
  const PatternInsightsCard({
    super.key,
    required this.report,
    required this.insights,
  });

  final EmotionalPatternReport? report;
  final List<PatternInsight> insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _buildStats();
    final pillWidth = (MediaQuery.sizeOf(context).width - 48) / 2;

    if (report == null || report!.totalEntries < 2) {
      return const SizedBox.shrink();
    }
    if (stats.isEmpty && insights.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Inteligencia emocional',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BrandSpacing.sm),
          if (stats.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats
                  .map((stat) => _statPill(theme, stat, pillWidth))
                  .toList(),
            ),
            const SizedBox(height: BrandSpacing.sm),
          ],
          ...insights.take(4).map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _insightItem(theme, insight),
            ),
          ),
        ],
      ),
    );
  }

  List<({String emoji, String label, String value})> _buildStats() {
    final report = this.report;
    if (report == null) return const [];

    final stats = <({String emoji, String label, String value})>[];

    final predominant = report.predominantEmotion;
    if (predominant != null) {
      stats.add((
        emoji: predominant.emoji,
        label: 'Emoción más frecuente',
        value: predominant.name,
      ));
    }

    final biggest = report.biggestMoodChange;
    if (biggest != null) {
      stats.add((
        emoji: '🔀',
        label: 'Mayor cambio de ánimo',
        value: '${biggest.fromEmotion.name} → ${biggest.toEmotion.name}',
      ));
    }

    if (report.mostActiveWeekday != null) {
      stats.add((
        emoji: '📅',
        label: 'Día más activo',
        value: report.mostActiveWeekday!,
      ));
    }

    if (report.predominantHourSlot != null) {
      stats.add((
        emoji: '🕰️',
        label: 'Horario predominante',
        value: report.predominantHourSlot!,
      ));
    }

    if (report.positiveStreak >= 2) {
      stats.add((
        emoji: '🔥',
        label: 'Racha positiva',
        value: '${report.positiveStreak} días',
      ));
    }

    if (report.negativeStreak >= 2) {
      stats.add((
        emoji: '🤍',
        label: 'Racha difícil',
        value: '${report.negativeStreak} días',
      ));
    }

    if (report.emotionalDiversity >= 3) {
      stats.add((
        emoji: '🌈',
        label: 'Diversidad emocional',
        value: '${report.emotionalDiversity} emociones',
      ));
    }

    return stats;
  }

  Widget _statPill(
    ThemeData theme,
    ({String emoji, String label, String value}) stat,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(stat.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.value,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightItem(ThemeData theme, PatternInsight insight) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight.message,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
