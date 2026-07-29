import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../providers/journal_provider.dart';

import '../utils/journal_insights.dart';
import '../widgets/app_card.dart';

class WellbeingScreen extends StatelessWidget {
  const WellbeingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.select<JournalProvider, List<JournalEntry>>(
      (provider) => provider.entries,
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > AppBreakpoints.compact;

    final weeklyEntries = _lastSevenDays(entries);
    final streak = _streak(entries);
    final dominantMood = entries.isEmpty
        ? moodByName('Normal')
        : JournalInsights.predominantMood(entries);
    final goal = weeklyEntries.where((items) => items.isNotEmpty).length;
    final avgWords = entries.isNotEmpty
        ? (JournalInsights.totalWords(entries) / entries.length).round()
        : 0;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          isWide ? 32 : 16,
          24,
          isWide ? 32 : 16,
          110,
        ),
        children: [
          Semantics(
            header: true,
            child: Text('Bienestar', style: theme.textTheme.displaySmall),
          ),
          const SizedBox(height: 4),
          Text(
            'Pequeños datos para acompañarte mejor.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Metrics grid ──
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - AppSpacing.md) / 2
                    : (screenWidth - 32 - AppSpacing.md) / 2,
                child: _Metric(
                  value: '${entries.length}',
                  label: 'reflexiones',
                  icon: Icons.menu_book_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - AppSpacing.md) / 2
                    : (screenWidth - 32 - AppSpacing.md) / 2,
                child: _Metric(
                  value: '$streak',
                  label: 'días de racha',
                  icon: Icons.local_fire_department_rounded,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - AppSpacing.md) / 2
                    : (screenWidth - 32 - AppSpacing.md) / 2,
                child: _Metric(
                  value: '$avgWords',
                  label: 'palabras promedio',
                  icon: Icons.text_fields_rounded,
                  color: theme.colorScheme.secondary,
                ),
              ),
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - AppSpacing.md) / 2
                    : (screenWidth - 32 - AppSpacing.md) / 2,
                child: _Metric(
                  value: '$goal/7',
                  label: 'días esta semana',
                  icon: Icons.flag_rounded,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Weekly emotional chart ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu semana emocional', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Cada barra representa tus momentos registrados.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      final records = weeklyEntries[index];
                      final mood = records.isEmpty
                          ? null
                          : moodByName(records.first.mood);
                      final height = records.isEmpty
                          ? 8.0
                          : 30.0 + (records.length.clamp(1, 5) * 18);
                      const dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                      final isToday = index == 6;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: AppDurations.normal,
                            curve: Curves.easeOutCubic,
                            width: 28,
                            height: height,
                            decoration: BoxDecoration(
                              gradient: mood != null
                                  ? LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        mood.color,
                                        mood.color.withValues(alpha: 0.5),
                                      ],
                                    )
                                  : null,
                              color: mood == null
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              border: isToday
                                  ? Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: mood != null
                                  ? [
                                      BoxShadow(
                                        color: mood.color.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dayLabels[index],
                            style: TextStyle(
                              fontWeight: isToday
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              fontSize: 12,
                              color: isToday
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Trend insight ──
          AppCard(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                      theme.colorScheme.secondary,
                    ],
                  ),
            elevation: false,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      dominantMood.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tendencia reciente: ${dominantMood.name}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Respira profundo tres veces. No necesitas resolverlo todo hoy.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Weekly goal ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.flag_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Objetivo suave de la semana',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '$goal/7',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: LinearProgressIndicator(
                    value: goal / 7,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$goal de 7 días dedicando un momento a ti',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<List<JournalEntry>> _lastSevenDays(List<JournalEntry> entries) {
    final today = DateUtils.dateOnly(DateTime.now());
    return List.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      return entries
          .where((entry) => DateUtils.isSameDay(entry.createdAt, day))
          .toList(growable: false);
    });
  }

  int _streak(List<JournalEntry> entries) {
    final days = entries
        .map((entry) => DateUtils.dateOnly(entry.createdAt))
        .toSet();
    var day = DateUtils.dateOnly(DateTime.now());
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
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
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.6),
                  color.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
