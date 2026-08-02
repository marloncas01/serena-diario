import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../models/emotion.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../utils/entry_actions.dart';
import '../widgets/empty_state.dart';
import '../widgets/journal_entry_card.dart';
import 'entry_detail_screen.dart';

/// Historial completo de entradas con búsqueda, filtros y ordenación.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _emotionId;
  String? _category;
  double _minIntensity = 0;
  DateTime? _from;
  DateTime? _to;
  bool _newestFirst = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<JournalEntry> _filter(List<JournalEntry> entries) {
    final q = _query.trim().toLowerCase();
    final result = <JournalEntry>[];
    for (final entry in entries) {
      if (q.isNotEmpty) {
        final source =
            '${entry.note} ${entry.tags.join(' ')} ${entry.mood} '
                    '${entry.dominantEmotionName ?? ''}'
                .toLowerCase();
        if (!source.contains(q)) continue;
      }
      if (_emotionId != null && entry.dominantEmotionId != _emotionId) {
        continue;
      }
      if (_category != null) {
        final category = entry.dominantEmotionCategory;
        if (category == null || category != _category) continue;
      }
      if ((entry.dominantEmotionIntensity ?? 0) < _minIntensity) continue;
      if (_from != null &&
          DateUtils.dateOnly(entry.createdAt).isBefore(
            DateUtils.dateOnly(_from!),
          )) {
        continue;
      }
      if (_to != null &&
          DateUtils.dateOnly(entry.createdAt).isAfter(
            DateUtils.dateOnly(_to!),
          )) {
        continue;
      }
      result.add(entry);
    }
    return result;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _from != null && _to != null
          ? DateTimeRange(start: _from!, end: _to!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
    );
    if (range == null) return;
    setState(() {
      _from = DateUtils.dateOnly(range.start);
      _to = DateUtils.dateOnly(range.end);
    });
  }

  void _openEntry(BuildContext context, JournalEntry entry) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EntryDetailScreen(entryId: entry.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > AppBreakpoints.compact;
    final padding = isWide ? 32.0 : 16.0;

    final filtered = _filter(journal.entries);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            tooltip: _newestFirst
                ? 'Ordenar de más antiguo a más reciente'
                : 'Ordenar de más reciente a más antiguo',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _newestFirst
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                key: ValueKey(_newestFirst),
              ),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _newestFirst = !_newestFirst);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                    hintText: 'Buscar en tu diario',
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildEmotionFilter(theme),
                      const SizedBox(width: 8),
                      _buildCategoryFilter(theme),
                      const SizedBox(width: 8),
                      _buildIntensityFilter(theme),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: Icon(
                          Icons.date_range_rounded,
                          size: 16,
                          color: _from != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        label: Text(_from != null && _to != null
                            ? '${_from!.day}/${_from!.month}/${_from!.year} – ${_to!.day}/${_to!.month}/${_to!.year}'
                            : 'Fechas'),
                        onSelected: (_) => _pickDateRange(),
                        selected: _from != null,
                      ),
                      if (_from != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Quitar filtros',
                          icon: const Icon(Icons.filter_alt_off_outlined),
                          onPressed: () => setState(() {
                            _from = null;
                            _to = null;
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Row(
              children: [
                Text(
                  filtered.length == 1
                      ? '1 entrada'
                      : '${filtered.length} entradas',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: () => setState(() {
                      _query = '';
                      _emotionId = null;
                      _category = null;
                      _minIntensity = 0;
                      _from = null;
                      _to = null;
                      _searchController.clear();
                    }),
                    child: const Text('Limpiar filtros'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: journal.entries.isEmpty
                        ? Icons.auto_stories_outlined
                        : Icons.search_off_rounded,
                    title: journal.entries.isEmpty
                        ? 'Aún no hay entradas'
                        : 'No encontramos coincidencias',
                    message: journal.entries.isEmpty
                        ? 'Escribe tu primera reflexión para verla aquí.'
                        : 'Prueba con otras palabras o quita algunos filtros.',
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = _newestFirst
                          ? filtered[index]
                          : filtered[filtered.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: JournalEntryCard(
                          entry: entry,
                          onTap: () => _openEntry(context, entry),
                          onEdit: () => editEntrySheet(context, entry),
                          onDelete: () => confirmDeleteEntry(context, entry.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _emotionId != null ||
      _category != null ||
      _minIntensity > 0 ||
      _from != null ||
      _to != null ||
      _query.trim().isNotEmpty;

  Widget _buildEmotionFilter(ThemeData theme) {
    return FilterChip(
      avatar: const Icon(Icons.mood_rounded, size: 16),
      label: Text(_emotionId == null
          ? 'Emoción'
          : (emotionById(_emotionId!)?.name ?? 'Emoción')),
      selected: _emotionId != null,
      onSelected: (selected) {
        if (selected && _emotionId != null) {
          setState(() => _emotionId = null);
          return;
        }
        showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Filtrar por emoción',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.clear_all_rounded),
              title: const Text('Todas las emociones'),
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _emotionId = null);
              },
            ),
            const Divider(height: 1),
            ...allEmotions.map(
              (emotion) => ListTile(
                leading: Text(emotion.emoji, style: const TextStyle(fontSize: 20)),
                title: Text(emotion.name),
                subtitle: Text(
                  _categoryLabel(emotion.category),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: _emotionId == emotion.id
                    ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() => _emotionId = emotion.id);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildCategoryFilter(ThemeData theme) {
    return FilterChip(
      avatar: const Icon(Icons.category_outlined, size: 16),
      label: Text(_category == null
          ? 'Categoría'
          : _category == EmotionCategory.positiva.name
              ? 'Positivas'
              : _category == EmotionCategory.negativa.name
                  ? 'Negativas'
                  : 'Mixtas'),
      selected: _category != null,
      onSelected: (selected) {
        if (selected && _category != null) {
          setState(() => _category = null);
          return;
        }
        showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filtrar por categoría',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.clear_all_rounded),
              title: const Text('Todas las categorías'),
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _category = null);
              },
            ),
            ...EmotionCategory.values.map(
              (category) => ListTile(
                leading: Text(_categoryEmoji(category),
                    style: const TextStyle(fontSize: 20)),
                title: Text(_categoryLabel(category)),
                trailing: _category == category.name
                    ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() => _category = category.name);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildIntensityFilter(ThemeData theme) {
    final levels = [
      (0.0, 'Cualquier intensidad'),
      (0.34, 'Baja (34%+)'),
      (0.5, 'Media (50%+)'),
      (0.67, 'Alta (67%+)'),
    ];
    final current = levels.indexWhere((l) => l.$1 == _minIntensity);
    return FilterChip(
      avatar: Icon(
        Icons.speed_rounded,
        size: 16,
        color: _minIntensity > 0
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(current <= 0 ? 'Intensidad' : levels[current].$2),
      selected: _minIntensity > 0,
      onSelected: (selected) {
        if (selected && _minIntensity > 0) {
          setState(() => _minIntensity = 0);
          return;
        }
        showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filtrar por intensidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            ...levels.map(
              (level) => ListTile(
                leading: Icon(
                  Icons.speed_rounded,
                  color: level.$1 > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(level.$2),
                trailing: _minIntensity == level.$1
                    ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() => _minIntensity = level.$1);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

  String _categoryLabel(EmotionCategory category) => switch (category) {
        EmotionCategory.positiva => 'Positiva',
        EmotionCategory.negativa => 'Negativa',
        EmotionCategory.mixta => 'Mixta',
      };

  String _categoryEmoji(EmotionCategory category) => switch (category) {
        EmotionCategory.positiva => '😊',
        EmotionCategory.negativa => '😔',
        EmotionCategory.mixta => '🤔',
      };
}
