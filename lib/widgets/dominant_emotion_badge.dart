import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../models/emotion.dart';

/// Badge visual de la emoción dominante: emoji + nombre + color + intensidad.
///
/// Se usa de forma consistente en tarjetas, calendario, detalle, historial,
/// dashboard y estadísticas para que la emoción dominante siempre se lea igual.
class DominantEmotionBadge extends StatelessWidget {
  const DominantEmotionBadge({
    super.key,
    this.emotionId,
    this.name,
    this.emoji,
    this.intensity,
    this.showIntensity = true,
    this.compact = false,
  });

  final String? emotionId;
  final String? name;
  final String? emoji;
  final double? intensity;
  final bool showIntensity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emotion = emotionId != null ? emotionById(emotionId!) : null;
    final color = emotion?.color ?? theme.colorScheme.secondary;
    final label = name ?? emotion?.name ?? 'Emoción';
    final face = emoji ?? emotion?.emoji ?? '✨';
    final value = (intensity ?? 0).clamp(0.0, 1.0);
    final percent = (value * 100).round();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(face, style: TextStyle(fontSize: compact ? 14 : 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showIntensity && intensity != null) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: compact ? 40 : 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$percent%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
