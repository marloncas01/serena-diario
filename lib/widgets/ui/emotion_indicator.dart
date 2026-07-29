import 'package:flutter/material.dart';
import '../../theme/brand/brand_radius.dart';
import '../../theme/brand/brand_durations.dart';

class EmotionIndicator extends StatefulWidget {
  const EmotionIndicator({
    super.key,
    required this.emoji,
    required this.label,
    this.color,
    this.value = 1.0,
    this.showProgress = false,
    this.size = 48,
  });

  final String emoji;
  final String label;
  final Color? color;
  final double value;
  final bool showProgress;
  final double size;

  @override
  State<EmotionIndicator> createState() => _EmotionIndicatorState();
}

class _EmotionIndicatorState extends State<EmotionIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: BrandDurations.medium,
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: BrandDurations.spring),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (widget.showProgress)
                SizedBox(
                  width: widget.size + 8,
                  height: widget.size + 8,
                  child: CircularProgressIndicator(
                    value: widget.value.clamp(0, 1),
                    strokeWidth: 3,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BrandRadius.lg),
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: TextStyle(fontSize: widget.size * 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
