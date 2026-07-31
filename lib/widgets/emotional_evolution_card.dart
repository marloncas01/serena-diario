import 'package:flutter/material.dart';
import '../services/emotional_history_service.dart';
import '../theme/brand/brand_spacing.dart';
import 'glass_card.dart';

class EmotionalEvolutionCard extends StatelessWidget {
  const EmotionalEvolutionCard({super.key, required this.report});

  final EmotionalHistoryReport report;

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
                child: const Icon(
                  Icons.show_chart,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Evolución emocional',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BrandSpacing.sm),
          _buildStatusIndicator(theme),
          const SizedBox(height: BrandSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statusColor(theme).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              report.descripcion,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (report.ciclosDetectados.isNotEmpty) ...[
            const SizedBox(height: BrandSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: report.ciclosDetectados.map((ciclo) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ciclo,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: BrandSpacing.sm),
          _buildTrendBar(theme, report.tendencia),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    if (report.hayMejora) {
      return _buildStatusChip(
        theme,
        '📈 Mejorando',
        theme.colorScheme.tertiary,
      );
    }
    if (report.hayRecaida) {
      return _buildStatusChip(
        theme,
        '💙 Acompañándote',
        theme.colorScheme.primary,
      );
    }
    if (report.esEstable) {
      return _buildStatusChip(
        theme,
        '⚖️ Estable',
        theme.colorScheme.secondary,
      );
    }
    return _buildStatusChip(
      theme,
      '📊 Analizando...',
      theme.colorScheme.outline,
    );
  }

  Widget _buildStatusChip(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTrendBar(ThemeData theme, double tendencia) {
    final label = tendencia > 0.1
        ? 'Tendencia positiva'
        : tendencia < -0.1
            ? 'Tendencia a la baja'
            : 'Tendencia estable';
    final color = tendencia > 0.1
        ? theme.colorScheme.tertiary
        : tendencia < -0.1
            ? theme.colorScheme.error
            : theme.colorScheme.primary;

    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ((tendencia + 1) / 2).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _statusColor(ThemeData theme) {
    if (report.hayMejora) return theme.colorScheme.tertiary;
    if (report.hayRecaida) return theme.colorScheme.primary;
    return theme.colorScheme.secondary;
  }
}
