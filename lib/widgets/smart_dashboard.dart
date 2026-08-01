import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/emotion.dart';
import '../models/journal_entry.dart';
import '../models/memory_item.dart';
import '../services/emotion_pipeline.dart';
import '../services/emotional_profile_service.dart';
import '../services/emotional_history_service.dart';
import '../services/emotional_insights_service.dart';
import '../services/recommendation_engine.dart';
import '../services/smart_advice_engine.dart';
import '../services/smart_spotify_service.dart';
import '../services/achievement_service.dart';
import '../services/journal_summary_service.dart';
import '../services/user_profile.dart';
import '../utils/journal_insights.dart';
import '../widgets/dashboard_components.dart';
import '../widgets/glass_card.dart';
import '../widgets/memory_card.dart';
import '../widgets/emotion_trend_card.dart';
import '../widgets/emotional_profile_card.dart';
import '../widgets/emotional_evolution_card.dart';
import '../widgets/insights_card.dart';
import '../widgets/recommendations_card.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/weekly_summary_card.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/emotional_summary_card.dart';
import '../theme/brand/brand_spacing.dart';

class _DashboardSection {
  const _DashboardSection({
    required this.id,
    required this.priority,
    required this.builder,
  });

  final String id;
  final int priority;
  final WidgetBuilder builder;
}

class SmartDashboard extends StatefulWidget {
  const SmartDashboard({
    super.key,
    required this.entries,
    required this.emotionHistory,
    this.profile,
    this.historyReport,
    this.insights = const [],
    this.recommendations = const [],
    this.weeklySummary,
    this.monthlySummary,
    this.memories = const [],
    this.trends = const {},
    this.onWriteTap,
    this.onWriteModeSelected,
    this.onViewAllMemories,
    this.selectedMood,
    this.isProcessingAI = false,
    this.lastPipelineResult,
  });

  final List<JournalEntry> entries;
  final List<EmotionAnalysis> emotionHistory;
  final EmotionalProfile? profile;
  final EmotionalHistoryReport? historyReport;
  final List<Insight> insights;
  final List<Recommendation> recommendations;
  final WeeklySummary? weeklySummary;
  final MonthlySummary? monthlySummary;
  final List<MemoryItem> memories;
  final Map<String, int> trends;
  final VoidCallback? onWriteTap;
  final ValueChanged<String>? onWriteModeSelected;
  final VoidCallback? onViewAllMemories;
  final String? selectedMood;
  final bool isProcessingAI;
  final EmotionPipelineResult? lastPipelineResult;

  @override
  State<SmartDashboard> createState() => _SmartDashboardState();
}

class _SmartDashboardState extends State<SmartDashboard> {
  SmartAdvice? _smartAdvice;
  SmartMusicRecommendation? _smartMusic;
  List<Achievement> _recentAchievements = [];

  @override
  void initState() {
    super.initState();
    _computeDashboard();
  }

  @override
  void didUpdateWidget(SmartDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries.length != oldWidget.entries.length ||
        widget.emotionHistory.length != oldWidget.emotionHistory.length) {
      _computeDashboard();
    }
  }

  Future<void> _computeDashboard() async {
    if (widget.entries.isEmpty && widget.emotionHistory.isEmpty) {
      if (!mounted) return;
      setState(() {
        _smartAdvice = SmartAdviceEngine().generate(
          entries: [],
          emotionHistory: [],
          profile: null,
          historyReport: null,
          memories: [],
          streak: 0,
        );
      });
      return;
    }

    final pipeline = EmotionPipeline();
    final profile = widget.profile;
    final historyReport = widget.historyReport;
    final streak = JournalInsights.streak(widget.entries);

    final advice = SmartAdviceEngine().generate(
      entries: widget.entries,
      emotionHistory: widget.emotionHistory,
      profile: profile,
      historyReport: historyReport,
      memories: pipeline.memoryManager.all,
      streak: streak,
    );

    final currentMood = widget.selectedMood ?? 'Normal';
    final music = SmartSpotifyService().getSmartRecommendation(
      currentMood: currentMood,
      recentEntries: widget.entries,
      memories: pipeline.memoryManager.all,
    );

    if (!mounted) return;
    setState(() {
      _smartAdvice = advice;
      _smartMusic = music;
    });

    try {
      await AchievementService().checkAll(widget.entries);
      if (!mounted) return;
      final all = await AchievementService().getUnlocked();
      if (!mounted) return;
      setState(() {
        _recentAchievements = all.take(3).toList();
      });
    } catch (_) {
      // Achievement check is non-critical
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfile>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sections = _buildSections(profile, isDark);

    return Column(
      children: sections.map((s) => s.builder(context)).toList(),
    );
  }

  List<_DashboardSection> _buildSections(UserProfile profile, bool isDark) {
    final sections = <_DashboardSection>[];

    sections.add(_DashboardSection(
      id: 'header',
      priority: 100,
      builder: (_) => Column(
        children: [
          HeroHeader(entries: widget.entries, profile: profile),
          const SizedBox(height: BrandSpacing.md),
        ],
      ),
    ));

    if (widget.entries.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'mood_summary',
        priority: 95,
        builder: (_) => Column(
          children: [
            MoodSummaryCard(entries: widget.entries),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.entries.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'emotional_summary',
        priority: 93,
        builder: (_) => Column(
          children: [
            EmotionalSummaryCard(entries: widget.entries),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    sections.add(_DashboardSection(
      id: 'daily_tip',
      priority: 90,
      builder: (_) => const Column(
        children: [
          DailyTipCard(),
          SizedBox(height: BrandSpacing.md),
        ],
      ),
    ));

    if (_smartAdvice != null) {
      sections.add(_DashboardSection(
        id: 'smart_advice',
        priority: 88,
        builder: (_) => Column(
          children: [
            _SmartAdviceCard(advice: _smartAdvice!),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (_smartMusic != null) {
      sections.add(_DashboardSection(
        id: 'smart_music',
        priority: 85,
        builder: (_) => Column(
          children: [
            _SmartMusicCard(recommendation: _smartMusic!),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (_recentAchievements.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'achievements',
        priority: 82,
        builder: (_) => Column(
          children: [
            _AchievementsCard(achievements: _recentAchievements),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    sections.add(_DashboardSection(
      id: 'quick_actions',
      priority: 80,
      builder: (_) => Column(
        children: [
          QuickActions(
            onWriteTap: widget.onWriteTap,
            onWriteModeSelected: widget.onWriteModeSelected,
            mood: widget.selectedMood,
          ),
          const SizedBox(height: BrandSpacing.md),
        ],
      ),
    ));

    if (widget.insights.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'insights',
        priority: 75,
        builder: (_) => Column(
          children: [
            InsightsCard(insights: widget.insights),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.recommendations.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'recommendations',
        priority: 70,
        builder: (_) => Column(
          children: [
            RecommendationsCard(recommendations: widget.recommendations),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.memories.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'memories',
        priority: 65,
        builder: (_) => Column(
          children: [
            MemoryCard(
              memories: widget.memories,
              onViewAll: widget.onViewAllMemories,
            ),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.trends.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'trends',
        priority: 60,
        builder: (_) => Column(
          children: [
            EmotionTrendCard(
              trends: widget.trends,
              totalEntries: widget.emotionHistory.length,
            ),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.entries.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'insights_section',
        priority: 55,
        builder: (_) => Column(
          children: [
            InsightsSection(entries: widget.entries),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.entries.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'goal',
        priority: 50,
        builder: (_) => Column(
          children: [
            GoalProgressWidget(entries: widget.entries),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.emotionHistory.isNotEmpty && widget.profile != null) {
      sections.add(_DashboardSection(
        id: 'emotional_profile',
        priority: 45,
        builder: (_) => Column(
          children: [
            EmotionalProfileCard(
              profile: widget.profile!,
              historyReport: widget.historyReport,
            ),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.emotionHistory.isNotEmpty && widget.weeklySummary != null) {
      sections.add(_DashboardSection(
        id: 'weekly_summary',
        priority: 40,
        builder: (_) => Column(
          children: [
            WeeklySummaryCard(summary: widget.weeklySummary!),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.emotionHistory.isNotEmpty && widget.monthlySummary != null) {
      sections.add(_DashboardSection(
        id: 'monthly_summary',
        priority: 35,
        builder: (_) => Column(
          children: [
            MonthlySummaryCard(summary: widget.monthlySummary!),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.emotionHistory.isNotEmpty && widget.historyReport != null) {
      sections.add(_DashboardSection(
        id: 'evolution',
        priority: 30,
        builder: (_) => Column(
          children: [
            EmotionalEvolutionCard(report: widget.historyReport!),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.entries.isNotEmpty) {
      sections.add(_DashboardSection(
        id: 'activity',
        priority: 25,
        builder: (_) => Column(
          children: [
            ActivityTimeline(entries: widget.entries),
            const SizedBox(height: BrandSpacing.md),
          ],
        ),
      ));
    }

    if (widget.entries.isEmpty) {
      sections.add(_DashboardSection(
        id: 'empty_state',
        priority: 10,
        builder: (_) => _EmptyDashboard(),
      ));
    }

    sections.sort((a, b) => b.priority.compareTo(a.priority));

    return sections;
  }
}

class _SmartAdviceCard extends StatelessWidget {
  const _SmartAdviceCard({required this.advice});

  final SmartAdvice advice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(advice.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advice.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
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

class _SmartMusicCard extends StatelessWidget {
  const _SmartMusicCard({required this.recommendation});

  final SmartMusicRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.music_note_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.playlistName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  recommendation.genre,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  const _AchievementsCard({required this.achievements});

  final List<Achievement> achievements;

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
                Icons.emoji_events_rounded,
                size: 20,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Logros recientes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...achievements.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(a.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          a.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Tu diario emocional',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe tu primera entrada para comenzar a conocer tus emociones.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
