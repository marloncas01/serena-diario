import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../providers/journal_provider.dart';
import '../theme/brand/brand_durations.dart';

import '../utils/journal_insights.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.select<JournalProvider, List<JournalEntry>>(
      (provider) => provider.entries,
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > AppBreakpoints.compact;

    if (entries.isEmpty) {
      return const SafeArea(
        child: EmptyState(
          icon: Icons.query_stats_rounded,
          title: 'Tus estadísticas aparecerán aquí',
          message: 'Escribe algunas entradas para descubrir tus patrones.',
        ),
      );
    }

    final weekly = JournalInsights.dailyCounts(entries);
    final moods = JournalInsights.moodCounts(entries);
    final totalWords = JournalInsights.totalWords(entries);
    final predominant = JournalInsights.predominantMood(entries);
    final monthly = JournalInsights.dailyCounts(entries, days: 30);
    final annual = List.generate(12, (index) {
      final date = DateTime.now();
      final month = DateTime(date.year, date.month - (11 - index));
      return entries
          .where(
            (entry) =>
                entry.createdAt.year == month.year &&
                entry.createdAt.month == month.month,
          )
          .length;
    }, growable: false);
    final avgWords = (totalWords / entries.length).round();

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
            child: Text('Estadísticas', style: theme.textTheme.displaySmall),
          ),
          const SizedBox(height: 4),
          Text(
            'Una mirada amable a tu práctica de escritura.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Quick stats ──
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - AppSpacing.sm * 3) / 4
                    : (screenWidth - 32 - AppSpacing.sm) / 2,
                child: _Stat(
                  value: '${entries.length}',
                  label: 'entradas',
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - AppSpacing.sm * 3) / 4
                    : (screenWidth - 32 - AppSpacing.sm) / 2,
                child: _Stat(
                  value: '$totalWords',
                  label: 'palabras',
                  color: theme.colorScheme.tertiary,
                ),
              ),
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - AppSpacing.sm * 3) / 4
                    : (screenWidth - 32 - AppSpacing.sm) / 2,
                child: _Stat(
                  value: '${JournalInsights.streak(entries)}',
                  label: 'racha',
                  color: theme.colorScheme.secondary,
                ),
              ),
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - AppSpacing.sm * 3) / 4
                    : (screenWidth - 32 - AppSpacing.sm) / 2,
                child: _Stat(
                  value: '$avgWords',
                  label: 'promedio',
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Weekly chart ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actividad semanal', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  JournalInsights.weeklyInsight(entries),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(height: 190, child: _WeeklyChart(values: weekly)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Monthly rhythm ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ritmo mensual', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Entradas de los últimos 30 días.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(height: 140, child: _ActivityLine(values: monthly)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Annual overview ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actividad anual', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Distribución de entradas por mes.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(height: 140, child: _ActivityLine(values: annual)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Emotional distribution ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emociones registradas',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                ...moods.entries.map((item) {
                  final mood = moodByName(item.key);
                  final percent = item.value / entries.length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                mood.color,
                                mood.color.withValues(alpha: 0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      mood.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '${(percent * 100).round()}%',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.pill,
                                ),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  color: mood.color,
                                  minHeight: 8,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Predominant mood ──
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
                      theme.colorScheme.primary,
                    ],
                  ),
            elevation: false,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      predominant.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emoción predominante',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        predominant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Promedio: $avgWords palabras por entrada',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
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

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final max = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b).toDouble();
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        minY: 0,
        maxY: max + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: max > 0
              ? (max / 3).ceilToDouble().clamp(1, double.infinity)
              : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Theme.of(context).colorScheme.primary,
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    '${spot.y.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                .toList(),
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
              (index) => FlSpot(index.toDouble(), values[index].toDouble()),
            ),
            isCurved: true,
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: BrandDurations.slow,
      curve: Curves.easeOutCubic,
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final maxY = values.isEmpty
        ? 1.0
        : (values.reduce((a, b) => a > b ? a : b) + 1).toDouble();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0
              ? (maxY / 3).ceilToDouble().clamp(1, double.infinity)
              : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Theme.of(context).colorScheme.primary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  '${rod.toY.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                final index = value.toInt();
                final isLast = index == labels.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    index >= 0 && index < labels.length ? labels[index] : '',
                    style: TextStyle(
                      fontWeight: isLast ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 12,
                      color: isLast
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          values.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index].toDouble(),
                width: 20,
                gradient: index == values.length - 1
                    ? LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
                      )
                    : LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        ],
                      ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
      duration: BrandDurations.slow,
      curve: Curves.easeOutCubic,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
