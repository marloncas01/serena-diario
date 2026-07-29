import 'package:flutter/material.dart';
import '../../theme/brand/brand_radius.dart';
import '../../theme/brand/brand_spacing.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.author,
    this.icon = Icons.format_quote_rounded,
    this.gradient,
  });

  final String quote;
  final IconData? icon;
  final String? author;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(BrandSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primaryContainer,
                isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              ],
            ),
        borderRadius: BrandRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(BrandRadius.sm),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
                if (author != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    author!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
