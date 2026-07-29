import 'package:flutter/material.dart';
import '../../theme/brand/brand_radius.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.emoji,
    this.size = 48,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.showShadow = false,
    this.showBorder = false,
  });

  final String emoji;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool showShadow;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final border = showBorder
        ? Border.all(
            color: borderColor ?? theme.colorScheme.primary,
            width: borderWidth > 0 ? borderWidth : 2,
          )
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BrandRadius.lg),
        border: border,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
