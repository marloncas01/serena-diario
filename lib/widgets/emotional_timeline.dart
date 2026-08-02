import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/emotion.dart';
import '../models/journal_entry.dart';
import '../theme/brand/brand_durations.dart';
import '../theme/brand/brand_radius.dart';
import '../theme/brand/brand_spacing.dart';
import 'glass_card.dart';
import 'ui/fade_in_child.dart';
import 'ui/premium_divider.dart';
import 'ui/section_title_premium.dart';

/// Línea de tiempo emocional con animación escalonada.
///
/// Muestra las últimas entradas como hitos de color, permitiendo ver de un
/// vistazo la evolución emocional reciente.
class EmotionalTimeline extends StatelessWidget {
  const EmotionalTimeline({super.key, required this.entries, this.limit = 10});

  final List<JournalEntry> entries;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final recent = entries.take(limit).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitlePremium(
            title: 'Tu timeline emocional',
            subtitle: 'Momentos recientes, en orden.',
            icon: Icons.timeline_rounded,
          ),
          PremiumDivider(withDot: true),
          const SizedBox(height: BrandSpacing.sm),
          for (var i = 0; i < recent.length; i++)
            FadeInChild(
              key: ValueKey('timeline_${recent[i].id}'),
              delay: Duration(milliseconds: 60 * i),
              duration: BrandDurations.medium,
              child: _TimelineItem(
                entry: recent[i],
                isLast: i == recent.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.entry, required this.isLast});

  final JournalEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emotion = emotionForLabel(entry.mood);
    final note = entry.note.trim();
    final date = DateFormat("EEEE, d MMM", 'es_ES').format(entry.createdAt);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Línea + nodo ──
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: emotion.color,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: emotion.color.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            emotion.color.withValues(alpha: 0.4),
                            theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: BrandSpacing.sm),
          // ── Contenido ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: emotion.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(BrandRadius.md),
                  border: Border.all(
                    color: emotion.color.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(emotion.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            emotion.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: emotion.color,
                            ),
                          ),
                        ),
                        Text(
                          date,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        note,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
