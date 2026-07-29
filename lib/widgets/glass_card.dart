import 'package:flutter/material.dart';
import '../core/app_constants.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding,
    this.onTap,
    this.margin,
    this.elevation = true,
    this.borderColor,
  });

  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool elevation;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final card = Semantics(
      container: true,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: gradient != null
              ? null
              : theme.colorScheme.surface,
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: borderColor ?? theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
          boxShadow: elevation
              ? (isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ])
              : null,
        ),
        child: child,
      ),
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: card,
        ),
      );
    }
    return card;
  }
}
