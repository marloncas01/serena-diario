import 'package:flutter/material.dart';
import '../../theme/brand/brand_radius.dart';
import '../../theme/brand/brand_spacing.dart';

class StatBadge extends StatelessWidget {
  const StatBadge({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.isCompact = false,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? themeColor.withValues(alpha: 0.1);

    return Container(
      padding: EdgeInsets.all(isCompact ? BrandSpacing.sm : BrandSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BrandRadius.lg),
      ),
      child: isCompact
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: themeColor),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: themeColor,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: themeColor),
                const SizedBox(height: BrandSpacing.sm),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}
