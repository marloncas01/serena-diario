import 'package:flutter/material.dart';

import '../models/journal_entry.dart';
import '../theme/brand/brand_spacing.dart';
import '../utils/journal_insights.dart';
import 'glass_card.dart';
import 'ui/animated_counter.dart';
import 'ui/premium_divider.dart';
import 'ui/quote_card.dart';
import 'ui/section_title_premium.dart';
import 'ui/stat_badge.dart';

/// Tarjetas premium del dashboard: estadísticas vivas con contadores animados.
class PremiumStatsCard extends StatelessWidget {
  const PremiumStatsCard({
    super.key,
    required this.entries,
    required this.achievementsCount,
    this.totalAchievements = 0,
  });

  final List<JournalEntry> entries;
  final int achievementsCount;
  final int totalAchievements;

  int get _daysThisMonth {
    final now = DateTime.now();
    return entries
        .where(
          (e) => e.createdAt.year == now.year && e.createdAt.month == now.month,
        )
        .map((e) => e.createdAt.day)
        .toSet()
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streak = JournalInsights.streak(entries);

    final stats = <_StatData>[
      _StatData(
        value: streak,
        label: 'Días de racha',
        icon: Icons.local_fire_department_rounded,
        color: theme.colorScheme.tertiary,
      ),
      _StatData(
        value: entries.length,
        label: 'Reflexiones',
        icon: Icons.menu_book_rounded,
        color: theme.colorScheme.primary,
      ),
      _StatData(
        value: _daysThisMonth,
        label: 'Días este mes',
        icon: Icons.calendar_month_rounded,
        color: theme.colorScheme.secondary,
      ),
      _StatData(
        value: achievementsCount,
        label: 'Logros',
        icon: Icons.emoji_events_rounded,
        color: theme.colorScheme.error,
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitlePremium(
            title: 'Tu progreso',
            subtitle: 'Constancia que puedes ver.',
            icon: Icons.insights_rounded,
            trailing: totalAchievements > 0
                ? StatBadge(
                    isCompact: true,
                    icon: Icons.emoji_events_rounded,
                    value: '$achievementsCount/$totalAchievements',
                    label: 'logros',
                    color: theme.colorScheme.tertiary,
                  )
                : null,
          ),
          PremiumDivider(withDot: true),
          const SizedBox(height: BrandSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final itemWidth = maxWidth > 640
                  ? (maxWidth - BrandSpacing.md * 3) / 4
                  : (maxWidth - BrandSpacing.md) / 2;
              return Wrap(
                spacing: BrandSpacing.md,
                runSpacing: BrandSpacing.md,
                children: stats
                    .map(
                      (stat) => SizedBox(
                        width: itemWidth,
                        child: _PremiumStat(stat: stat),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color color;
}

class _PremiumStat extends StatelessWidget {
  const _PremiumStat({required this.stat});

  final _StatData stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(BrandSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stat.color.withValues(alpha: 0.14),
            stat.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stat.color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, size: 18, color: stat.color),
          const SizedBox(height: BrandSpacing.sm),
          AnimatedCounter(
            value: stat.value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: stat.color,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de cita de bienestar, rotada diariamente.
class PremiumQuoteCard extends StatelessWidget {
  const PremiumQuoteCard({super.key});

  static const _quotes = <(String, String)>[
    ('Escribir no es mostrar tus heridas, es dejar de sangrar en silencio.', 'Reflexión'),
    ('Una página al día mantiene la tormenta a raya.', 'Ritual'),
    ('Lo que no se nombra no se puede sanar.', 'Práctica'),
    ('Tu diario es el espejo donde la tormenta se vuelve paisaje.', 'Serena'),
    ('Cada línea que escribes es un ladrillo de tu paz interior.', 'Serena'),
    ('No escribes para ser leído, escribes para ser libre.', 'Serena'),
    ('Las palabras que te dices a ti mismo importan más que cualquier otra.', 'Autocuidado'),
    ('Hoy también es un buen día para dejarte caer en las páginas.', 'Serena'),
  ];

  @override
  Widget build(BuildContext context) {
    final dayIndex = DateTime.now().difference(DateTime(2024)).inDays;
    final (quote, author) = _quotes[dayIndex % _quotes.length];
    return QuoteCard(quote: quote, author: '— $author');
  }
}
