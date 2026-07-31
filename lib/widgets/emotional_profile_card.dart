import 'package:flutter/material.dart';
import '../services/emotional_profile_service.dart';
import '../services/emotional_history_service.dart';
import '../theme/brand/brand_spacing.dart';
import 'glass_card.dart';

class EmotionalProfileCard extends StatelessWidget {
  const EmotionalProfileCard({
    super.key,
    required this.profile,
    this.historyReport,
  });

  final EmotionalProfile profile;
  final EmotionalHistoryReport? historyReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tu perfil emocional',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (historyReport != null)
                _TrendBadge(report: historyReport!),
            ],
          ),
          const SizedBox(height: BrandSpacing.sm),
          _buildPlainLanguageSummary(theme, historyReport),
          const SizedBox(height: BrandSpacing.md),
          _buildMetricRow(
            theme,
            'Emoción predominante',
            profile.emocionPredominante,
            Icons.emoji_emotions,
          ),
          _buildProgressBar(
            theme,
            'Ansiedad',
            profile.nivelAnsiedad,
            theme.colorScheme.secondary,
          ),
          _buildProgressBar(
            theme,
            'Estabilidad',
            profile.estabilidadEmocional,
            theme.colorScheme.tertiary,
          ),
          _buildProgressBar(
            theme,
            'Emociones positivas',
            profile.porcentajePositivas,
            theme.colorScheme.tertiary,
          ),
          _buildProgressBar(
            theme,
            'Emociones negativas',
            profile.porcentajeNegativas,
            theme.colorScheme.error.withValues(alpha: 0.7),
          ),
          const SizedBox(height: BrandSpacing.sm),
          if (profile.fortalezas.isNotEmpty) ...[
            Text(
              'Fortalezas',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 4),
            ...profile.fortalezas.take(3).map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $f',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            )),
            const SizedBox(height: BrandSpacing.sm),
          ],
          if (profile.aspectosTrabajar.isNotEmpty) ...[
            Text(
              'Aspectos a trabajar',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 4),
            ...profile.aspectosTrabajar.take(3).map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $a',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            )),
          ],
          const SizedBox(height: BrandSpacing.sm),
          _buildProgresoGeneral(theme, profile.nivelProgreso),
          if (profile.personasMencionadas.isNotEmpty) ...[
            const SizedBox(height: BrandSpacing.sm),
            _buildPersonasMencionadas(theme, profile.personasMencionadas),
          ],
        ],
      ),
    );
  }

  Widget _buildPlainLanguageSummary(
    ThemeData theme,
    EmotionalHistoryReport? report,
  ) {
    if (report == null) return const SizedBox.shrink();

    final parts = <String>[];

    if (report.hayMejora) {
      parts.add('Tus emociones están mejorando');
    } else if (report.hayRecaida) {
      parts.add('Has tenido días difíciles');
    } else if (report.esEstable) {
      parts.add('Te sientes más estable');
    }

    if (profile.estabilidadEmocional > 0.7) {
      parts.add('con buena estabilidad emocional');
    } else if (profile.estabilidadEmocional < 0.3) {
      parts.add('con altibajos frecuentes');
    }

    if (profile.porcentajePositivas > 0.6) {
      parts.add('la mayoría de tus emociones son positivas');
    } else if (profile.porcentajeNegativas > 0.6) {
      parts.add('ha habido muchas emociones difíciles');
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    final summary = '${parts.first}${parts.length > 1 ? ', ${parts.sublist(1).join(" y ")}' : ''}.';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label: ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    ThemeData theme,
    String label,
    double value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(value * 100).round()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgresoGeneral(ThemeData theme, double progress) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nivel de progreso general',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonasMencionadas(ThemeData theme, List<String> personas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personas importantes',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: personas.take(5).map((p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              p,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.report});

  final EmotionalHistoryReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String text;
    Color color;
    IconData icon;

    if (report.hayMejora) {
      text = 'Mejorando';
      color = theme.colorScheme.tertiary;
      icon = Icons.trending_up;
    } else if (report.hayRecaida) {
      text = 'Difícil';
      color = theme.colorScheme.error;
      icon = Icons.trending_down;
    } else if (report.esEstable) {
      text = 'Estable';
      color = theme.colorScheme.tertiary;
      icon = Icons.trending_flat;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
