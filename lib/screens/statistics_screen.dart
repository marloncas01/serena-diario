import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../models/emotion.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../services/pdf_report_service.dart';
import '../services/user_profile.dart';
import '../theme/brand/brand_durations.dart';

import '../utils/journal_insights.dart';
import '../widgets/app_card.dart';
import '../widgets/dominant_emotion_badge.dart';
import '../widgets/empty_state.dart';
import '../widgets/ui/shimmer_loading.dart';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Estadísticas',
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Una mirada amable a tu práctica de escritura.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ExportReportButton(entries: entries),
            ],
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
                  final mood = emotionForLabel(item.key);
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

          // ── Top emociones (30) ──
          _EmotionsSection(entries: entries),
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
    final today = DateUtils.dateOnly(DateTime.now());
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
                const weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                final index = value.toInt();
                final date = today.subtract(Duration(days: 6 - index));
                final isLast = index == 6;
                final label = index >= 0 && index <= 6
                    ? weekdays[date.weekday - 1]
                    : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
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

class _EmotionsSection extends StatelessWidget {
  const _EmotionsSection({required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final withEmotion = JournalInsights.withEmotion(entries);
    final counts = JournalInsights.dominantEmotionCounts(entries);
    final categories = JournalInsights.categoryCounts(entries);
    final avgIntensity = JournalInsights.averageIntensity(entries);
    final analyzed = withEmotion.length;
    final predominant = JournalInsights.predominantEmotion(entries);

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final topTotal = sorted.isNotEmpty
        ? sorted.first.value
        : 1;

    final positive = categories[EmotionCategory.positiva] ?? 0;
    final negative = categories[EmotionCategory.negativa] ?? 0;
    final mixed = categories[EmotionCategory.mixta] ?? 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tus 30 emociones',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            analyzed == 0
                ? 'Guarda entradas para descubrir tus emociones.'
                : 'Analizadas en $analyzed ${analyzed == 1 ? 'entrada' : 'entradas'}.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Top emociones ──
          if (top.isNotEmpty) ...[
            Text('Las que más aparecen', style: theme.textTheme.labelMedium),
            const SizedBox(height: 10),
            ...top.map((item) {
              final emotion = emotionById(item.key);
              if (emotion == null) return const SizedBox.shrink();
              final percent = item.value / topTotal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(emotion.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  emotion.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.value}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            child: LinearProgressIndicator(
                              value: percent.clamp(0.0, 1.0),
                              color: emotion.color,
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
              );
            }),
            const SizedBox(height: AppSpacing.sm),
          ],

          // ── Categorías ──
          Text('Balance emocional', style: theme.textTheme.labelMedium),
          const SizedBox(height: 10),
          _CategoryBar(
            label: 'Positivas',
            emoji: '😊',
            color: theme.colorScheme.tertiary,
            value: positive,
            total: analyzed,
          ),
          const SizedBox(height: 10),
          _CategoryBar(
            label: 'Negativas',
            emoji: '😔',
            color: theme.colorScheme.error,
            value: negative,
            total: analyzed,
          ),
          const SizedBox(height: 10),
          _CategoryBar(
            label: 'Mixtas',
            emoji: '🤔',
            color: theme.colorScheme.tertiary,
            value: mixed,
            total: analyzed,
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Intensidad promedio ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.tertiary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.speed_rounded,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intensidad promedio',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        avgIntensity == 0
                            ? 'Aún sin datos'
                            : '${(avgIntensity * 100).round()}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (avgIntensity > 0) ...[
                  const Spacer(),
                  DominantEmotionBadge(
                    emotionId: predominant?.id,
                    name: predominant?.name,
                    emoji: predominant?.emoji,
                    intensity: avgIntensity,
                    compact: true,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Evolución semanal ──
          Text('Evolución semanal', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            'Positivas y negativas por día (últimos 7 días).',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 140, child: _EmotionWeeklyChart(entries: entries)),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.label,
    required this.emoji,
    required this.color,
    required this.value,
    required this.total,
  });

  final String label;
  final String emoji;
  final Color color;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = total > 0 ? value / total : 0.0;
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              color: color,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(
            '${(percent * 100).round()}%',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmotionWeeklyChart extends StatelessWidget {
  const _EmotionWeeklyChart({required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final days = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    }, growable: false);

    List<double> positive = [];
    List<double> negative = [];
    for (final day in days) {
      final dayEntries =
          entries.where((e) => DateUtils.isSameDay(e.createdAt, day));
      var pos = 0;
      var neg = 0;
      for (final entry in dayEntries) {
        final emotion = emotionById(entry.dominantEmotionId ?? '');
        if (emotion == null) continue;
        if (emotion.category == EmotionCategory.positiva) pos++;
        if (emotion.category == EmotionCategory.negativa) neg++;
      }
      positive.add(pos.toDouble());
      negative.add(neg.toDouble());
    }

    final maxY = [
      ...positive,
      ...negative,
      1.0,
    ].reduce((a, b) => a > b ? a : b) + 1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 3).ceilToDouble().clamp(1, double.infinity),
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                final index = value.toInt();
                final label = index >= 0 && index < days.length
                    ? weekdays[days[index].weekday - 1]
                    : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.primary,
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
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(7, (i) => FlSpot(i.toDouble(), positive[i])),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.tertiary,
                theme.colorScheme.tertiary.withValues(alpha: 0.5),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: List.generate(7, (i) => FlSpot(i.toDouble(), negative[i])),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.error,
                theme.colorScheme.error.withValues(alpha: 0.6),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        ],
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
              color: color,
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

class _ExportReportButton extends StatefulWidget {
  const _ExportReportButton({required this.entries});

  final List<JournalEntry> entries;

  @override
  State<_ExportReportButton> createState() => _ExportReportButtonState();
}

class _ExportReportButtonState extends State<_ExportReportButton> {
  bool _isExporting = false;

  Future<void> _export() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final profile = context.read<UserProfile>();
      await PdfReportService().generateAndShare(
        entries: widget.entries,
        userName: profile.userName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('Informe PDF generado correctamente.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('No se pudo generar el informe PDF.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: 'Exportar informe PDF',
      child: InkWell(
        onTap: _isExporting ? null : _export,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.tertiary,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.md),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ShimmerLoading(
            enabled: _isExporting,
            child: Center(
              child: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
