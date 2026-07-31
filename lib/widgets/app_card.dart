import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import 'ui/fade_in_child.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.padding,
    this.onTap,
    this.margin,
    this.elevation = true,
  });

  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = FadeInChild(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: gradient != null
            ? null
            : (color ?? Theme.of(context).cardTheme.color),
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: gradient != null
            ? null
            : Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.2 : 0.4,
                ),
              ),
        boxShadow: !elevation
            ? null
            : isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppShadows.soft,
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
