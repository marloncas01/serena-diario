import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/app_constants.dart';
import '../data/motivational_quotes.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../services/spotify_service.dart';
import '../services/user_profile.dart';
import '../theme/app_colors.dart';
import '../theme/brand/brand_durations.dart';
import '../utils/journal_insights.dart';
import 'breathing_exercise_dialog.dart';
import 'glass_card.dart';
import 'section_title.dart';

class QuoteBar extends StatelessWidget {
  const QuoteBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quote = MotivationalQuotes.dailyQuote();
    return AnimatedOpacity(
      duration: BrandDurations.slow,
      opacity: 1,
      child: Text(
        quote,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.entries,
    required this.profile,
  });

  final List<JournalEntry> entries;
  final UserProfile profile;

  String _buildGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final streak = JournalInsights.streak(entries);
    final mood = JournalInsights.predominantMood(entries);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > AppBreakpoints.compact;

    return Semantics(
      button: true,
      label: 'Avatar de perfil. Toca para cambiar.',
      child: GlassCard(
        padding: EdgeInsets.all(isWide ? AppSpacing.xl : AppSpacing.lg),
        gradient: isDark ? AppColors.darkHeroGradient : AppColors.heroGradient,
        elevation: true,
        borderColor: Colors.transparent,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: BrandDurations.normal,
                width: isWide ? 56 : 48,
                height: isWide ? 56 : 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    profile.avatar,
                    style: TextStyle(fontSize: isWide ? 30 : 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_buildGreeting()}, ${profile.greetingName}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWide ? 24 : 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat("EEEE, d 'de' MMMM", 'es_ES').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const QuoteBar(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  icon: Icons.local_fire_department_rounded,
                  value: '$streak',
                  label: 'racha',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HeroStat(
                  icon: Icons.menu_book_rounded,
                  value: '${entries.length}',
                  label: 'entradas',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HeroStat(
                  icon: Icons.emoji_emotions_outlined,
                  value: mood.name,
                  label: 'predominante',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuickActions extends StatefulWidget {
  const QuickActions({
    super.key,
    this.onWriteTap,
    this.onWriteModeSelected,
    this.mood,
  });

  final VoidCallback? onWriteTap;
  final ValueChanged<String>? onWriteModeSelected;
  final String? mood;

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  int _waterCount = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Acciones rápidas'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ActionButton(
                icon: Icons.air_rounded,
                label: 'Respirar',
                color: theme.colorScheme.tertiary,
                onTap: () => _openBreathing(context),
              ),
              _ActionButton(
                icon: Icons.directions_walk_rounded,
                label: 'Caminar',
                color: theme.colorScheme.secondary,
                onTap: () => _startWalkActivity(context),
              ),
              _ActionButton(
                icon: Icons.water_drop_rounded,
                label: 'Agua',
                color: theme.colorScheme.primary,
                onTap: () => _logWater(context),
              ),
              _ActionButton(
                icon: Icons.music_note_rounded,
                label: 'Música',
                color: theme.colorScheme.tertiary,
                onTap: () => _openMusic(context),
              ),
              _ActionButton(
                icon: Icons.edit_rounded,
                label: 'Escribir',
                color: theme.colorScheme.primary,
                onTap: () => _openWriteOptions(context),
              ),
              _ActionButton(
                icon: Icons.menu_book_rounded,
                label: 'Leer',
                color: theme.colorScheme.secondary,
                onTap: () => _startReading(context),
              ),
              _ActionButton(
                icon: Icons.bedtime_outlined,
                label: 'Dormir',
                color: theme.colorScheme.tertiary,
                onTap: () => _logSleep(context),
              ),
              _ActionButton(
                icon: Icons.self_improvement_rounded,
                label: 'Meditar',
                color: theme.colorScheme.primary,
                onTap: () => _startMeditation(context),
              ),
              _ActionButton(
                icon: Icons.phone_rounded,
                label: 'Llamar',
                color: theme.colorScheme.secondary,
                onTap: () => _callSomeone(context),
              ),
              _ActionButton(
                icon: Icons.park_rounded,
                label: 'Aire libre',
                color: theme.colorScheme.tertiary,
                onTap: () => _goOutside(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openBreathing(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const BreathingExerciseDialog(),
    );
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Respiración completada. ¡Bien por ti! 🌿'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _startWalkActivity(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🚶 Caminata',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Da una caminata de 10 minutos.\nEl movimiento ayuda a tu bienestar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Caminata registrada! 🚶‍♀️'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como realizado'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        ),
      ),
    );
  }

  void _logWater(BuildContext context) {
    _waterCount++;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('💧', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _waterCount == 1
                    ? '¡Primer vaso registrado! Sigue así.'
                    : 'Vaso $_waterCount registrado. ¡Hidratarte es cuidarte!',
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openMusic(BuildContext context) async {
    final currentMood = widget.mood ?? 'Normal';
    final launched = await SpotifyService().openPlaylistByEmotion(currentMood);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              launched ? '🎵' : '⚠️',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                launched
                    ? 'Abriendo música para tu estado: $currentMood'
                    : 'No se pudo abrir Spotify. Inténtalo de nuevo.',
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openWriteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Qué deseas escribir?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _WriteOption(
                icon: Icons.edit_note_rounded,
                title: 'Diario libre',
                subtitle: 'Escribe lo que sientas',
                onTap: () => _selectMode(ctx, 'Diario libre'),
              ),
              _WriteOption(
                icon: Icons.mood_outlined,
                title: 'Quiero desahogarme',
                subtitle: 'Suelta lo que traes dentro',
                onTap: () => _selectMode(ctx, 'Desahogo'),
              ),
              _WriteOption(
                icon: Icons.checklist_rounded,
                title: 'Organizar mis ideas',
                subtitle: 'Acomoda tus pensamientos',
                onTap: () => _selectMode(ctx, 'Ideas'),
              ),
              _WriteOption(
                icon: Icons.sentiment_satisfied_alt_rounded,
                title: 'Guardar un buen momento',
                subtitle: 'Registra algo positivo',
                onTap: () => _selectMode(ctx, 'Buen momento'),
              ),
              _WriteOption(
                icon: Icons.nightlight_round,
                title: 'Escribir antes de dormir',
                subtitle: 'Cierra el día con una reflexión',
                onTap: () => _selectMode(ctx, 'Nocturno'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectMode(BuildContext ctx, String mode) {
    Navigator.pop(ctx);
    HapticFeedback.selectionClick();
    if (widget.onWriteTap != null) widget.onWriteTap!();
    if (widget.onWriteModeSelected != null) widget.onWriteModeSelected!(mode);
  }

  void _startReading(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📚 Tiempo de lectura. ¡Disfruta!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _logSleep(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24,
          MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '🌙 Registro de sueño',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                '¿Qué tal dormiste anoche?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _SleepQualityChip(label: 'Muy bien 😊', onTap: () { Navigator.pop(ctx); _showSleepConfirmation(context); }),
                  _SleepQualityChip(label: 'Bien 🙂', onTap: () { Navigator.pop(ctx); _showSleepConfirmation(context); }),
                  _SleepQualityChip(label: 'Regular 😐', onTap: () { Navigator.pop(ctx); _showSleepConfirmation(context); }),
                  _SleepQualityChip(label: 'Mal 😔', onTap: () { Navigator.pop(ctx); _showSleepConfirmation(context); }),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showSleepConfirmation(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌙 Sueño registrado. ¡Descansa bien!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startMeditation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const BreathingExerciseDialog(),
    );
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🧘 Meditación completada. ¡Namaste!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _callSomeone(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📞 Llama a alguien importante hoy.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _goOutside(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌳 Sal al aire libre. Un paseo corto ayuda mucho.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

class _WriteOption extends StatelessWidget {
  const _WriteOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: BrandDurations.instant,
    );
    _scale = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: Tooltip(
        message: widget.label,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: GestureDetector(
            onTapDown: (_) => _animController.forward(),
            onTapUp: (_) {
              _animController.reverse();
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onTapCancel: () => _animController.reverse(),
            child: AnimatedContainer(
              duration: BrandDurations.fast,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 16, color: widget.color),
                  const SizedBox(width: 6),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class MoodSummaryCard extends StatelessWidget {
  const MoodSummaryCard({
    super.key,
    required this.entries,
  });

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mood = JournalInsights.predominantMood(entries);
    final moodObj = moodByName(mood.name);
    final totalMoods = entries.length;
    final moodCount = entries.where((e) => e.mood == mood.name).length;
    final percentage = totalMoods > 0 ? (moodCount / totalMoods) * 100 : 0;
    final todayCount = entries.where((e) =>
        e.createdAt.day == DateTime.now().day &&
        e.createdAt.month == DateTime.now().month &&
        e.createdAt.year == DateTime.now().year).length;
    final streak = JournalInsights.streak(entries);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gradient: isDark ? null : AppColors.moodGradient(mood.name),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: moodObj.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(moodObj.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado predominante',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mood.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: moodObj.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(moodObj.color),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _MoodMeta(label: 'Hoy', value: '$todayCount registros'),
              const SizedBox(width: AppSpacing.md),
              _MoodMeta(label: 'Racha', value: '$streak días'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodMeta extends StatelessWidget {
  const _MoodMeta({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class InsightsSection extends StatelessWidget {
  const InsightsSection({super.key, required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final streak = JournalInsights.streak(entries);
    final lastActiveDays = (DateTime.now().difference(entries.first.createdAt).inDays);
    final counts = JournalInsights.dailyCounts(entries);
    final daysThisWeek = counts.where((c) => c > 0).length;
    final totalWords = JournalInsights.totalWords(entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Insights', icon: Icons.lightbulb_outline_rounded),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _InsightCard(
              icon: Icons.local_fire_department_rounded,
              text: streak > 0
                  ? '$streak días consecutivos registrando. ¡Sigue así!'
                  : 'Empieza hoy tu racha.',
              color: theme.colorScheme.tertiary,
            ),
            _InsightCard(
              icon: Icons.edit_note_rounded,
              text: daysThisWeek > 0
                  ? 'Esta semana has escrito $daysThisWeek de 7 días.'
                  : 'Llevas $lastActiveDays día(s) sin escribir.',
              color: theme.colorScheme.secondary,
            ),
            _InsightCard(
              icon: Icons.text_fields_rounded,
              text: 'Llevas $totalWords palabras escritas.',
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            _InsightCard(
              icon: Icons.trending_up_rounded,
              text: entries.length > 1
                  ? 'Tu constancia importa. Cada entrada suma.'
                  : 'Este es el inicio de algo importante.',
              color: theme.colorScheme.tertiary,
            ),
          ],
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? color : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({super.key, required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final recent = entries.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Actividad reciente', icon: Icons.history_rounded),
        const SizedBox(height: AppSpacing.sm),
        ...recent.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final mood = moodByName(e.mood);
          final isLast = i == recent.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
            child: _ActivityItem(e: e, mood: mood),
          );
        }),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.e, required this.mood});
  final JournalEntry e;
  final Mood mood;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [mood.color, mood.color.withValues(alpha: 0.6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(mood.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat("d 'de' MMMM · HH:mm", 'es_ES').format(e.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (e.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      e.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (e.tags.isNotEmpty)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '#${e.tags.first}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GoalProgressWidget extends StatelessWidget {
  const GoalProgressWidget({super.key, required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streak = JournalInsights.streak(entries);
    final counts = JournalInsights.dailyCounts(entries);
    final daysThisWeek = counts.where((c) => c > 0).length;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Objetivos'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _GoalStat(
                  value: '$daysThisWeek/7',
                  label: 'días activos',
                  progress: daysThisWeek / 7,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _GoalStat(
                  value: '$streak',
                  label: 'racha actual',
                  progress: streak / 30,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalStat extends StatelessWidget {
  const _GoalStat({
    required this.value,
    required this.label,
    required this.progress,
    required this.color,
  });

  final String value;
  final String label;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 5,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class MiniSparkline extends StatelessWidget {
  const MiniSparkline({super.key, required this.data, this.color, this.height = 40});

  final List<double> data;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = color ?? theme.colorScheme.primary;
    if (data.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _SparklinePainter(data, lineColor),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.data, this.color);
  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = (maxVal - minVal).clamp(1, double.maxFinite);
    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minVal) / range) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final dotsPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minVal) / range) * (size.height - 4) - 2;
      canvas.drawCircle(Offset(x, y), i == data.length - 1 ? 3.5 : 0, dotsPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

class _SleepQualityChip extends StatelessWidget {
  const _SleepQualityChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
