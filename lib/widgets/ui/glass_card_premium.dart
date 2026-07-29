import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/brand/brand_radius.dart';
import '../../theme/brand/brand_shadows.dart';

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
    this.blurAmount = 10,
    this.opacity = 0.7,
  });

  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool elevation;
  final Color? borderColor;
  final double blurAmount;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final card = ClipRRect(
      borderRadius: BrandRadius.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: margin,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: gradient != null
                ? null
                : (isDark
                    ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: opacity)
                    : Colors.white.withValues(alpha: opacity)),
            gradient: gradient,
            borderRadius: BrandRadius.card,
            border: Border.all(
              color: borderColor ??
                  (isDark
                      ? theme.colorScheme.outline.withValues(alpha: 0.3)
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
              width: 0.5,
            ),
            boxShadow: elevation
                ? (isDark ? BrandShadows.darkSoft : BrandShadows.soft)
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BrandRadius.card,
          child: card,
        ),
      );
    }
    return card;
  }
}
