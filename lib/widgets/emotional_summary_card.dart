import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_constants.dart';
import '../models/journal_entry.dart';
import '../utils/journal_insights.dart';
import '../widgets/glass_card.dart';
import 'dominant_emotion_badge.dart';

/// Resumen emocional compacto para el dashboard: emoción predominante,
/// racha actual, último registro y promedio de intensidad.
class EmotionalSummaryCard extends StatelessWidget {
  const EmotionalSummaryCard({super.key, required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final withEmotion = JournalInsights.withEmotion(entries);
    final predominant = JournalInsights.predominantEmotion(withEmotion);
    final streak = JournalInsights.streak(entries);
    final avgIntensity = JournalInsights.averageIntensity(entries);
    final last = entries.isNotEmpty ? entries.first : null;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.tertiaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Resumen emocional',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (predominant != null) ...[
            DominantEmotionBadge(
              emotionId: predominant.id,
              name: predominant.name,
              emoji: predominant.emoji,
              intensity: avgIntensity,
            ),
            const SizedBox(height: 12),
          ] else
            Text(
              'Escribe un poco más para descubrir tus patrones emocionales.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Racha',
                  value: '$streak ${streak == 1 ? 'día' : 'días'}',
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  icon: Icons.speed_rounded,
                  label: 'Intensidad',
                  value: avgIntensity == 0
                      ? '—'
                      : '${(avgIntensity * 100).round()}%',
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  icon: Icons.history_rounded,
                  label: 'Último',
                  value: last == null
                      ? '—'
                      : DateFormat('d MMM', 'es_ES').format(last.createdAt),
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
