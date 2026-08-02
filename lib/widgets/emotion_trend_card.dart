import 'package:flutter/material.dart';
import '../models/emotion.dart';
import '../theme/brand/brand_spacing.dart';
import 'glass_card.dart';

class EmotionTrendCard extends StatelessWidget {
  const EmotionTrendCard({
    super.key,
    required this.trends,
    this.totalEntries = 0,
  });

  final Map<String, int> trends;
  final int totalEntries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (trends.isEmpty) return const SizedBox.shrink();

    final maxCount = trends.values.fold<int>(0, (a, b) => a > b ? a : b);

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
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tendencia emocional',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
                  if (totalEntries > 0)
                    Flexible(
                      child: Text(
                        'Historial reciente',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: BrandSpacing.sm),
          ...trends.entries.take(5).map((entry) {
            final emotion = _findEmotion(entry.key);
            final color = emotion.color;
            final percentage = maxCount > 0 ? entry.value / maxCount : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTrendRow(
                theme,
                emotion,
                entry.value,
                color,
                percentage,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendRow(
    ThemeData theme,
    EmotionDefinition emotion,
    int count,
    Color color,
    double percentage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              emotion.emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                emotion.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  EmotionDefinition _findEmotion(String id) {
    return emotionById(id) ?? allEmotions.first;
  }
}
