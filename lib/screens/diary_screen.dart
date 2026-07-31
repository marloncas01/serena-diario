import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/app_texts.dart';
import '../models/journal_entry.dart';
import '../models/memory_item.dart';
import '../models/mood.dart';
import '../providers/journal_provider.dart';
import '../services/app_preferences.dart';

import '../theme/brand/brand_durations.dart';

import '../theme/brand/brand_radius.dart';
import '../theme/brand/brand_shadows.dart';
import '../theme/brand/brand_spacing.dart';
import '../utils/app_feedback.dart';
import '../utils/journal_insights.dart';
import '../models/emotion.dart';
import '../services/emotion_pipeline.dart';
import '../services/emotional_profile_service.dart';
import '../services/emotional_history_service.dart';
import '../services/emotional_insights_service.dart';
import '../services/recommendation_engine.dart';
import '../services/journal_summary_service.dart';
import '../services/mood_emotion_mapper.dart';
import '../widgets/empty_state.dart';
import '../widgets/emotion_response_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/smart_dashboard.dart';
import '../widgets/section_title.dart';
import '../widgets/journal_entry_card.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  final _searchController = TextEditingController();
  String _selectedMood = 'Normal';
  String _query = '';
  String _writeMode = '';
  bool _isSaving = false;
  bool _isDraftSaving = false;
  bool _isProcessingAI = false;
  bool _showMoodOverride = false;
  Timer? _draftTimer;
  bool _showEntryForm = false;
  final _pipeline = EmotionPipeline();
  EmotionPipelineResult? _lastPipelineResult;
  final _profileService = EmotionalProfileService();
  final _historyService = EmotionalHistoryService();
  final _insightsService = EmotionalInsightsService();
  final _recEngine = RecommendationEngine();
  final _summaryService = JournalSummaryService();

  // Cached computation results
  EmotionalProfile? _cachedProfile;
  EmotionalHistoryReport? _cachedHistoryReport;
  List<Insight> _cachedInsights = const [];
  List<Recommendation> _cachedRecommendations = const [];
  WeeklySummary? _cachedWeeklySummary;
  MonthlySummary? _cachedMonthlySummary;
  int _lastEntriesLength = -1;
  int _lastAnalysisLength = -1;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  Future<void> _restoreDraft() async {
    final draft = await AppPreferences().draft;
    if (!mounted || draft['note']!.isEmpty) return;
    setState(() {
      _noteController.text = draft['note']!;
      _tagsController.text = draft['tags']!;
      _selectedMood = draft['mood']!;
      _showEntryForm = true;
    });
  }

  void _scheduleDraft() {
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 650), () async {
      if (!mounted) return;
      setState(() => _isDraftSaving = true);
      await AppPreferences().saveDraft(
        note: _noteController.text,
        tags: _tagsController.text,
        mood: _selectedMood,
      );
      if (mounted) setState(() => _isDraftSaving = false);
    });
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _noteController.dispose();
    _tagsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _tags => _tagsController.text
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  int get _wordCount => JournalInsights.wordCount(_noteController.text);

  int get _readingTime => (_wordCount / 200).ceil().clamp(1, 99);

  String _getDynamicHint() {
    final hour = DateTime.now().hour;
    final wordCount = _wordCount;
    if (wordCount == 0) {
      if (hour < 6) return '¿No puedes dormir? Escribe lo que tengas en mente...';
      if (hour < 12) return '¿Cómo empezó tu mañana?';
      if (hour < 15) return '¿Qué tal tu día hasta ahora?';
      if (hour < 19) return '¿Cómo te sentiste hoy?';
      return '¿Cómo fue tu día? Cierra con una reflexión.';
    }
    if (wordCount < 20) return 'Sigue escribiendo, estás empezando bien...';
    if (wordCount < 50) return 'Vas muy bien, ya tienes ideas claras.';
    if (wordCount < 100) return '¡Excelente reflexión! ¿Algo más que quieras añadir?';
    if (wordCount < 200) return 'Buen texto. ¿Quieres agregar etiquetas?';
    return '¡Gran entrada! Puedes guardar cuando quieras.';
  }

  Future<void> _save() async {
    if (_isSaving) return;
    HapticFeedback.lightImpact();
    setState(() => _isSaving = true);
    final text = _noteController.text;
    final saved = await context.read<JournalProvider>().add(
      mood: _selectedMood,
      note: text,
      tags: _tags,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) {
      _noteController.clear();
      _tagsController.clear();
      await AppPreferences().clearDraft();
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() => _showEntryForm = false);
      AppFeedback.success(context, AppTexts.saved);

      setState(() => _isProcessingAI = true);
      try {
        final result = await _pipeline.processEntry(text);
        if (!mounted) return;

        final detectedMood = MoodEmotionMapper.moodFromEmotionAnalysis(
          result.analysis,
        );
        final entries = context.read<JournalProvider>().entries;
        if (entries.isNotEmpty) {
          final lastEntry = entries.first;
          if (lastEntry.mood == 'Normal' && detectedMood != 'Normal') {
            await context.read<JournalProvider>().update(
              lastEntry.copyWith(mood: detectedMood),
            );
          }
        }

        setState(() {
          _lastPipelineResult = result;
          _isProcessingAI = false;
          _selectedMood = detectedMood;
        });
      } catch (_) {
        if (mounted) setState(() => _isProcessingAI = false);
      }
    } else {
      if (!mounted) return;
      AppFeedback.error(
        context,
        context.read<JournalProvider>().errorMessage ??
            AppTexts.duplicateWarning,
      );
    }
  }

  Future<bool> _confirmDelete(String id) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text('¿Eliminar esta entrada?'),
        content: const Text(
          'Podrás deshacer esta acción durante unos segundos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppTexts.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppTexts.deleteEntry),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return false;
    final deleted = await context.read<JournalProvider>().delete(id);
    if (!mounted || deleted == null) return false;
    HapticFeedback.mediumImpact();
    AppFeedback.show(
      context,
      'Entrada eliminada',
      action: SnackBarAction(
        label: AppTexts.undo.toUpperCase(),
        onPressed: () => context.read<JournalProvider>().restore(deleted),
      ),
    );
    return true;
  }

  Future<void> _editEntry(JournalEntry entry) async {
    HapticFeedback.lightImpact();
    final note = TextEditingController(text: entry.note);
    final tags = TextEditingController(text: entry.tags.join(', '));
    var mood = entry.mood;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppTexts.editEntry,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: moods
                      .map(
                        (item) => AnimatedScale(
                          scale: mood == item.name ? 1.05 : 1.0,
                          duration: AppDurations.fast,
                          curve: Curves.easeOutCubic,
                          child: ChoiceChip(
                            label: Text('${item.emoji} ${item.name}'),
                            selected: mood == item.name,
                            selectedColor: item.color,
                            onSelected: (_) =>
                                setSheetState(() => mood = item.name),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: note,
                  minLines: 4,
                  maxLines: 8,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu reflexión',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tags,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.sell_outlined),
                    hintText: AppTexts.tagsCommaHint,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    child: const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || saved != true) {
      note.dispose();
      tags.dispose();
      return;
    }
    final updated = await context.read<JournalProvider>().update(
      entry.copyWith(mood: mood, note: note.text, tags: tags.text.split(',')),
    );
    note.dispose();
    tags.dispose();
    if (mounted) {
      updated
          ? AppFeedback.success(context, AppTexts.editSaved)
          : AppFeedback.error(context, AppTexts.editFailed);
    }
  }

  void _showAllMemories(BuildContext context) {
    final allMemories = _pipeline.memoryManager.all;
    if (allMemories.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Memorias de Serena',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allMemories.length,
                itemBuilder: (_, i) {
                  final m = allMemories[i];
                  return ListTile(
                    leading: Text(
                      m.category.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(
                      m.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${m.category.label} · mencionado ${m.timesMentioned} vez${m.timesMentioned == 1 ? '' : 'es'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > AppBreakpoints.compact;
    final padding = isWide ? 32.0 : 16.0;

    if (journal.status == JournalStatus.loading) {
      return Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }
    if (journal.status == JournalStatus.error) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar el diario',
        message: journal.errorMessage ?? 'Inténtalo de nuevo más tarde.',
      );
    }

    final filtered = journal.entries
        .where((entry) {
          final source = '${entry.note} ${entry.tags.join(' ')} ${entry.mood}'
              .toLowerCase();
          return source.contains(_query.toLowerCase());
        })
        .toList(growable: false);

    final currentEntriesLength = journal.entries.length;
    final currentAnalysisLength = _pipeline.analysisHistory.length;

    if (currentEntriesLength != _lastEntriesLength ||
        currentAnalysisLength != _lastAnalysisLength) {
      _lastEntriesLength = currentEntriesLength;
      _lastAnalysisLength = currentAnalysisLength;

      _cachedProfile = _profileService.generate(
        history: _pipeline.analysisHistory,
        memories: _pipeline.memoryManager.all,
        entries: journal.entries,
      );
      _cachedHistoryReport = _historyService.analyze(_pipeline.analysisHistory);
      _cachedInsights = _insightsService.generateInsights(
        history: _pipeline.analysisHistory,
        entries: journal.entries,
        memories: _pipeline.memoryManager.all,
      );
      if (_cachedProfile != null && _cachedHistoryReport != null) {
        _cachedRecommendations = _recEngine.generate(
          profile: _cachedProfile!,
          history: _cachedHistoryReport!,
          memories: _pipeline.memoryManager.all,
          emotionHistory: _pipeline.analysisHistory,
        );
      } else {
        _cachedRecommendations = [];
      }
      _cachedWeeklySummary = _summaryService.generateWeekly(
        history: _pipeline.analysisHistory,
        entries: journal.entries,
      );
      _cachedMonthlySummary = _summaryService.generateMonthly(
        history: _pipeline.analysisHistory,
        entries: journal.entries,
      );
    }

    final emotionalProfile = _cachedProfile;
    final historyReport = _cachedHistoryReport;
    final insights = _cachedInsights;
    final recommendations = _cachedRecommendations;
    final weeklySummary = _cachedWeeklySummary;
    final monthlySummary = _cachedMonthlySummary;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SmartDashboard(
                  entries: journal.entries,
                  emotionHistory: _pipeline.analysisHistory,
                  profile: emotionalProfile,
                  historyReport: historyReport,
                  insights: insights,
                  recommendations: recommendations,
                  weeklySummary: weeklySummary,
                  monthlySummary: monthlySummary,
                  memories: _pipeline.getRecentMemories(),
                  trends: _pipeline.getEmotionTrends(),
                  onWriteTap: () => setState(() => _showEntryForm = true),
                  onWriteModeSelected: (mode) {
                    setState(() {
                      _showEntryForm = true;
                      _writeMode = mode;
                    });
                  },
                  onViewAllMemories: () => _showAllMemories(context),
                  selectedMood: _selectedMood,
                  isProcessingAI: _isProcessingAI,
                  lastPipelineResult: _lastPipelineResult,
                ),
                const SizedBox(height: BrandSpacing.md),

                if (_isProcessingAI) ...[
                  const _ThinkingIndicator(),
                  const SizedBox(height: BrandSpacing.md),
                ],

                if (_lastPipelineResult != null) ...[
                  _DetectedEmotionBanner(
                    analysis: _lastPipelineResult!.analysis,
                    selectedMood: _selectedMood,
                    showOverride: _showMoodOverride,
                    onToggleOverride: () => setState(() => _showMoodOverride = !_showMoodOverride),
                    onMoodSelected: (moodName) async {
                      setState(() {
                        _selectedMood = moodName;
                        _showMoodOverride = false;
                      });
                      final entries = context.read<JournalProvider>().entries;
                      if (entries.isNotEmpty) {
                        final lastEntry = entries.first;
                        await context.read<JournalProvider>().update(
                          lastEntry.copyWith(mood: moodName),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: BrandSpacing.md),
                ],

                if (_lastPipelineResult != null) ...[
                  EmotionResponseCard(
                    response: _lastPipelineResult!.response,
                    crisis: _lastPipelineResult!.crisis,
                    analysis: _lastPipelineResult!.analysis,
                    memoriesAdded: _lastPipelineResult!.memoriesAdded,
                    onDismiss: () =>
                        setState(() => _lastPipelineResult = null),
                  ),
                  const SizedBox(height: BrandSpacing.md),
                ],

                if (_pipeline.memoryManager.getFollowUpSuggestions().isNotEmpty) ...[
                  _FollowUpSuggestions(
                    suggestions: _pipeline.memoryManager.getFollowUpSuggestions(),
                  ),
                  const SizedBox(height: BrandSpacing.md),
                ],

                _buildEntryToggle(theme, isDark),
                const SizedBox(height: BrandSpacing.md),

                _buildSearchBar(theme, isDark),
                const SizedBox(height: BrandSpacing.md),

                SectionTitle(
                  title: _query.isEmpty
                      ? 'Entradas recientes'
                      : 'Resultados (${filtered.length})',
                  icon: _query.isEmpty ? Icons.history_rounded : null,
                ),
                const SizedBox(height: BrandSpacing.sm),
              ]),
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: _query.isEmpty
                    ? Icons.menu_book_outlined
                    : Icons.search_off_rounded,
                title: _query.isEmpty
                    ? AppTexts.noEntries
                    : 'No encontramos coincidencias',
                message: _query.isEmpty
                    ? AppTexts.noEntriesHint
                    : 'Prueba con otras palabras o etiquetas.',
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final entry = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Dismissible(
                      key: ValueKey(entry.id),
                      direction: DismissDirection.horizontal,
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await _editEntry(entry);
                          return false;
                        }
                        return _confirmDelete(entry.id);
                      },
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(BrandRadius.lg),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.errorContainer,
                              theme.colorScheme.error,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(BrandRadius.lg),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      child: JournalEntryCard(
                        entry: entry,
                        onEdit: () => _editEntry(entry),
                        onDelete: () => _confirmDelete(entry.id),
                      ),
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryToggle(ThemeData theme, bool isDark) {
    return AnimatedSize(
      duration: BrandDurations.normal,
      curve: BrandDurations.standard,
      child: _showEntryForm
          ? _buildEntryForm(theme, isDark)
          : Semantics(
              button: true,
              label: 'Crear nueva entrada de diario',
              child: GlassCard(
              onTap: () => setState(() => _showEntryForm = true),
              padding: const EdgeInsets.all(BrandSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(BrandRadius.md),
                      boxShadow: BrandShadows.coloredSoft(
                        theme.colorScheme.primary,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nueva entrada',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '¿Qué pasó hoy?',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Semantics(
      label: 'Buscar en tu diario',
      child: GlassCard(
        padding: EdgeInsets.zero,
        elevation: false,
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            suffixIcon: _query.isEmpty
                ? null
                : Tooltip(
                    message: 'Limpiar búsqueda',
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
                  ),
            hintText: 'Buscar en tu diario',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryForm(ThemeData theme, bool isDark) {
    final modePrompts = <String, String>{
      'Diario libre': '¿Qué pequeño momento te hizo sentir bien hoy?',
      'Desahogo': '¿Qué necesitas soltar hoy?',
      'Ideas': '¿Qué ideas quieres organizar?',
      'Buen momento': '¿Qué bueno te pasó hoy?',
      'Nocturno': '¿Cómo fue tu día? Cierra con una reflexión.',
    };
    final prompt = modePrompts[_writeMode] ?? modePrompts['Diario libre']!;

    final dynamicHint = _getDynamicHint();

    return GlassCard(
      padding: const EdgeInsets.all(BrandSpacing.base),
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
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.surfaceContainerHighest,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(BrandRadius.sm),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 18,
                  color: isDark ? Colors.white : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _writeMode.isNotEmpty ? _writeMode : 'Pregunta del día',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const Spacer(),
              Tooltip(
                message: 'Cerrar formulario',
                child: InkWell(
                  onTap: () => setState(() {
                    _showEntryForm = false;
                    _writeMode = '';
                  }),
                  borderRadius: BorderRadius.circular(BrandRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prompt,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            minLines: 3,
            maxLines: 6,
            onChanged: (_) {
              setState(() {});
              _scheduleDraft();
            },
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: dynamicHint,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tagsController,
            onChanged: (_) => _scheduleDraft(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.sell_outlined),
              hintText: AppTexts.tagsHint,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.text_fields_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_wordCount palabras · $_readingTime min',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (_isDraftSaving)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              Semantics(
                button: true,
                label: _isSaving ? AppTexts.saving : AppTexts.saveEntry,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.bookmark_add_outlined),
                  label: Text(
                    _isSaving ? AppTexts.saving : AppTexts.saveEntry,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetectedEmotionBanner extends StatelessWidget {
  const _DetectedEmotionBanner({
    required this.analysis,
    required this.selectedMood,
    required this.showOverride,
    required this.onToggleOverride,
    required this.onMoodSelected,
  });

  final EmotionAnalysis analysis;
  final String selectedMood;
  final bool showOverride;
  final VoidCallback onToggleOverride;
  final ValueChanged<String> onMoodSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = analysis.rankings.isNotEmpty ? analysis.rankings.first : null;
    final confidence = analysis.confidence.round();
    final mood = moodByName(selectedMood);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (top?.emotion.color ?? theme.colorScheme.primary)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    top?.emotion.emoji ?? mood.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Serena detectó',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${top?.emotion.emoji ?? mood.emoji} ${top?.emotion.name ?? mood.name}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$confidence%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onToggleOverride,
              icon: Icon(
                showOverride ? Icons.expand_less : Icons.expand_more,
                size: 16,
              ),
              label: const Text('Cambiar emoción'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          if (showOverride) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: moods
                  .map(
                    (item) => ChoiceChip(
                      label: Text('${item.emoji} ${item.name}'),
                      selected: selectedMood == item.name,
                      selectedColor: item.color,
                      onSelected: (_) => onMoodSelected(item.name),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThinkingIndicator extends StatefulWidget {
  const _ThinkingIndicator();

  @override
  State<_ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<_ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<int> _dots;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _dots = IntTween(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: BrandSpacing.md),
          Expanded(
            child: AnimatedBuilder(
              animation: _dots,
              builder: (context, child) {
                final dots = '.' * _dots.value;
                return Text(
                  'Serena está pensando$dots',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpSuggestions extends StatelessWidget {
  const _FollowUpSuggestions({required this.suggestions});

  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Row(
                children: [
                  Icon(
                    Icons.question_answer_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seguimiento',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 8),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                s,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
