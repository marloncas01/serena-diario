import 'package:flutter/material.dart';
import '../../theme/brand/brand_radius.dart';
import '../../theme/brand/brand_durations.dart';

class MoodChip extends StatefulWidget {
  const MoodChip({
    super.key,
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    this.color,
    this.size = MoodChipSize.normal,
  });

  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;
  final MoodChipSize size;

  @override
  State<MoodChip> createState() => _MoodChipState();
}

class _MoodChipState extends State<MoodChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: BrandDurations.fast,
    );
    _scale = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = widget.color ?? theme.colorScheme.primary;
    final isCompact = widget.size == MoodChipSize.compact;
    final horizontalPad = isCompact ? 10.0 : 14.0;
    final verticalPad = isCompact ? 6.0 : 10.0;
    final fontSize = isCompact ? 12.0 : 13.0;

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedContainer(
          duration: BrandDurations.fast,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: verticalPad,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? chipColor.withValues(alpha: 0.15)
                : chipColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(BrandRadius.pill),
            border: Border.all(
              color: widget.isSelected
                  ? chipColor.withValues(alpha: 0.5)
                  : chipColor.withValues(alpha: 0.15),
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: TextStyle(fontSize: fontSize + 4)),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: widget.isSelected ? chipColor : chipColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum MoodChipSize { normal, compact }
