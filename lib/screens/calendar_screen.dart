import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../providers/journal_provider.dart';
import '../theme/brand/brand_durations.dart';

import '../utils/entry_actions.dart';
import '../utils/journal_insights.dart';
import '../widgets/app_card.dart';
import '../widgets/dominant_emotion_badge.dart';
import '../widgets/empty_state.dart';
import '../widgets/ui/glass_bottom_sheet.dart';
import 'entry_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  DateTime _selected = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _currentMonth = DateUtils.dateOnly(DateTime.now());
  }

  void _previousMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selected = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selected = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
  }

  void _showDayEntries(DateTime day) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _DayEntriesSheet(day: day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > AppBreakpoints.compact;

    if (journal.status != JournalStatus.ready) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final days = List.generate(
      daysInMonth,
      (index) => DateTime(_currentMonth.year, _currentMonth.month, index + 1),
    );

    final recordsByDay = <DateTime, List<JournalEntry>>{};
    for (final entry in journal.entries) {
      final day = DateUtils.dateOnly(entry.createdAt);
      (recordsByDay[day] ??= []).add(entry);
    }

    final selectedEntries = recordsByDay[_selected] ?? const <JournalEntry>[];
    final monthEntries = journal.entries
        .where(
          (entry) =>
              entry.createdAt.year == _currentMonth.year &&
              entry.createdAt.month == _currentMonth.month,
        )
        .toList(growable: false);
    final monthMood = monthEntries.isNotEmpty
        ? JournalInsights.predominantMood(monthEntries)
        : moodByName('Normal');

    final isCurrentMonth =
        _currentMonth.year == now.year && _currentMonth.month == now.month;

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
            child: Text('Calendario', style: theme.textTheme.displaySmall),
          ),
          const SizedBox(height: 4),
          Text(
            'Observa tus emociones con perspectiva.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Month summary ──
          if (monthEntries.isNotEmpty) ...[
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _MonthStat(
                      value: '${monthEntries.length}',
                      label: 'entradas del mes',
                      color: theme.colorScheme.primary,
                      icon: Icons.edit_note_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MonthStat(
                      value: '${monthMood.emoji} ${monthMood.name}',
                      label: 'emoción predominante',
                      color: monthMood.color,
                      icon: Icons.mood_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── Calendar grid ──
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: const Icon(Icons.chevron_left_rounded),
                      tooltip: 'Mes anterior',
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: BrandDurations.normal,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Text(
                          toBeginningOfSentenceCase(
                            DateFormat(
                              'MMMM yyyy',
                              'es_ES',
                            ).format(_currentMonth),
                          )!,
                          key: ValueKey('$_currentMonth'),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: isCurrentMonth ? null : _nextMonth,
                      icon: const Icon(Icons.chevron_right_rounded),
                      tooltip: 'Mes siguiente',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                      .map(
                        (label) => Expanded(
                          child: Center(
                            child: Text(
                              label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.sm),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: days.first.weekday - 1 + days.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (_, index) {
                    if (index < days.first.weekday - 1) {
                      return const SizedBox();
                    }
                    final day = days[index - (days.first.weekday - 1)];
                    final records = recordsByDay[day] ?? const <JournalEntry>[];
                    final active = DateUtils.isSameDay(day, _selected);
                    final isToday = DateUtils.isSameDay(day, now);
                    return Semantics(
                      button: true,
                      label:
                          'Día ${day.day}${records.isEmpty ? '' : ', con entrada'}',
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = day);
                          _showDayEntries(day);
                        },
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: AnimatedContainer(
                          duration: BrandDurations.fast,
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.all(3),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: records.isNotEmpty
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      moodByName(records.first.mood).color,
                                      moodByName(
                                        records.first.mood,
                                      ).color.withValues(alpha: 0.6),
                                    ],
                                  )
                                : null,
                            color: records.isEmpty
                                ? (active
                                      ? theme.colorScheme.secondaryContainer
                                      : null)
                                : null,
                            border: Border.all(
                              color: active
                                  ? theme.colorScheme.primary
                                  : isToday
                                  ? theme.colorScheme.outline
                                  : Colors.transparent,
                              width: active ? 2.5 : 1,
                            ),
                            boxShadow: records.isNotEmpty && active
                                ? [
                                    BoxShadow(
                                      color: moodByName(
                                        records.first.mood,
                                      ).color.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontWeight: active || isToday
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Selected day detail ──
          AnimatedSwitcher(
            duration: BrandDurations.slow,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: selectedEntries.isEmpty
                ? const EmptyState(
                    key: ValueKey('empty'),
                    icon: Icons.event_available_outlined,
                    title: 'No registraste emociones este día',
                    message: 'Elige otro día o escribe una nueva reflexión.',
                  )
                : AppCard(
                    key: ValueKey(_selected),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    moodByName(
                                      selectedEntries.first.mood,
                                    ).color,
                                    moodByName(
                                      selectedEntries.first.mood,
                                    ).color.withValues(alpha: 0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  moodByName(selectedEntries.first.mood).emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                DateFormat(
                                  "EEEE, d 'de' MMMM",
                                  'es_ES',
                                ).format(_selected),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.pill,
                                  ),
                                ),
                                child: Text(
                                  '${selectedEntries.length} ${selectedEntries.length == 1 ? 'entrada' : 'entradas'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                          child: Row(
                            children: [
                              Text(
                                moodByName(selectedEntries.first.mood).emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Resumen emocional: ${JournalInsights.predominantMood(selectedEntries).name}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...selectedEntries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  moodByName(entry.mood).emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.note,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Mood legend ──
          Text('Indicadores de emoción', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: moods
                .map(
                  (mood) => Semantics(
                    label: 'Emoción: ${mood.name}',
                    child: Chip(
                      avatar: Text(mood.emoji),
                      label: Text(mood.name),
                      backgroundColor: mood.color,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  const _MonthStat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.5),
                color.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet con las entradas de un día del calendario y sus acciones.
class _DayEntriesSheet extends StatefulWidget {
  const _DayEntriesSheet({required this.day});

  final DateTime day;

  @override
  State<_DayEntriesSheet> createState() => _DayEntriesSheetState();
}

class _DayEntriesSheetState extends State<_DayEntriesSheet> {
  void _openEntry(BuildContext context, JournalEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EntryDetailScreen(entryId: entry.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journal = context.watch<JournalProvider>();
    final entries = journal.entries
        .where((e) => DateUtils.isSameDay(e.createdAt, widget.day))
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return GlassBottomSheet(
      title: toBeginningOfSentenceCase(
        DateFormat('EEEE, d', 'es_ES').format(widget.day),
      ),
      subtitle: entries.length == 1
          ? '1 entrada este día'
          : '${entries.length} entradas este día',
      child: entries.isEmpty
          ? EmptyState(
              icon: Icons.event_available_outlined,
              title: 'No registraste emociones este día',
              message: 'Elige otro día o escribe una nueva reflexión.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              shrinkWrap: true,
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final mood = moodByName(entry.mood);
                return AppCard(
                  onTap: () => _openEntry(context, entry),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  mood.color,
                                  mood.color.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mood.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm', 'es_ES').format(
                                    entry.createdAt,
                                  ),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Opciones de la entrada',
                            icon: Icon(
                              Icons.more_vert_rounded,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            onSelected: (value) {
                              if (value == 'view') _openEntry(context, entry);
                              if (value == 'edit') {
                                editEntrySheet(context, entry);
                              }
                              if (value == 'delete') {
                                confirmDeleteEntry(context, entry.id);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'view',
                                child: Text('Ver completo'),
                              ),
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (entry.dominantEmotionId != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: DominantEmotionBadge(
                            emotionId: entry.dominantEmotionId,
                            name: entry.dominantEmotionName,
                            emoji: entry.dominantEmotionEmoji,
                            intensity: entry.dominantEmotionIntensity,
                            compact: true,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        entry.note,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
