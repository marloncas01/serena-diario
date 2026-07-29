import 'package:flutter/material.dart';

class PremiumDivider extends StatelessWidget {
  const PremiumDivider({
    super.key,
    this.height = 1,
    this.indent = 0,
    this.color,
    this.withDot = false,
  });

  final double height;
  final double indent;
  final Color? color;
  final bool withDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = color ??
        (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : theme.colorScheme.outlineVariant);

    if (withDot) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: height,
                color: dividerColor,
              ),
            ),
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                height: height,
                color: dividerColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: height,
      margin: EdgeInsets.only(left: indent),
      color: dividerColor,
    );
  }
}
