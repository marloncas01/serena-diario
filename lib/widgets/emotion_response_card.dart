import 'package:flutter/material.dart';
import '../models/emotion.dart';
import '../models/memory_item.dart';
import '../services/emotional_response_engine.dart';
import '../services/crisis_detector.dart';
import 'glass_card.dart';

class EmotionResponseCard extends StatelessWidget {
  const EmotionResponseCard({
    super.key,
    required this.response,
    required this.crisis,
    this.analysis,
    this.memoriesAdded,
    this.onDismiss,
  });

  final EmotionalResponse response;
  final CrisisResult crisis;
  final EmotionAnalysis? analysis;
  final List<MemoryItem>? memoriesAdded;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (crisis.highRisk) {
      return _buildCrisisCard(context, theme);
    }

    return _buildResponseCard(context, theme);
  }

  Widget _buildCrisisCard(BuildContext context, ThemeData theme) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderColor: theme.colorScheme.error.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shield, size: 20, color: theme.colorScheme.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Serena se preocupa por ti',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            response.validation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Detecté estas palabras: ${crisis.triggers.join(", ")}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCrisisResources(context, theme),
          if (onDismiss != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDismiss,
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCrisisResources(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Líneas de ayuda:',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _buildResourceRow(theme, 'Línea de la Vida', '800-290-0024'),
          const SizedBox(height: 4),
          _buildResourceRow(theme, 'SAPTEL', '800-713-3257'),
          const SizedBox(height: 4),
          _buildResourceRow(theme, 'Emergencias', '911'),
        ],
      ),
    );
  }

  Widget _buildResourceRow(ThemeData theme, String name, String number) {
    return Row(
      children: [
        Icon(Icons.phone, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '$name: ',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          number,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildResponseCard(BuildContext context, ThemeData theme) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Serena te dice...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  tooltip: 'Descartar',
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (response.greeting.isNotEmpty) ...[
            _buildSection(
              theme,
              response.greeting,
              Icons.waving_hand,
              theme.colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
          ],
          if (response.validation.isNotEmpty) ...[
            _buildSection(
              theme,
              response.validation,
              Icons.favorite,
              theme.colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
          ],
          if (response.interpretation.isNotEmpty) ...[
            _buildSection(
              theme,
              response.interpretation,
              Icons.psychology,
              theme.colorScheme.secondary,
            ),
            const SizedBox(height: 12),
          ],
          if (response.suggestion.isNotEmpty) ...[
            _buildSection(
              theme,
              response.suggestion,
              Icons.lightbulb,
              theme.colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
          ],
          if (response.reflectionQuestion.isNotEmpty) ...[
            _buildSection(
              theme,
              response.reflectionQuestion,
              Icons.help_outline,
              theme.colorScheme.primary,
            ),
          ],
          if (analysis != null && analysis!.rankings.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildEmotionChips(theme, analysis!),
            const SizedBox(height: 10),
            _buildConfidenceBadge(theme, analysis!),
          ],
          if (memoriesAdded != null && memoriesAdded!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark,
                    size: 16,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Serena guardó ${memoriesAdded!.length} recuerdo'
                      '${memoriesAdded!.length == 1 ? '' : 's'} de tu día.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    String text,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionChips(ThemeData theme, EmotionAnalysis analysis) {
    final top3 = analysis.rankings.take(3).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: top3.map((score) {
        final color = score.emotion.color;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            '${score.emotion.emoji} ${score.emotion.name}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfidenceBadge(ThemeData theme, EmotionAnalysis analysis) {
    final pct = (analysis.confidence * 100).round();
    final label = pct >= 80
        ? 'Alta'
        : pct >= 50
        ? 'Media'
        : 'Baja';
    final color = pct >= 80
        ? theme.colorScheme.tertiary
        : pct >= 50
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;

    return Row(
      children: [
        Icon(Icons.gps_fixed, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Confianza del análisis:',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$label ($pct%)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
