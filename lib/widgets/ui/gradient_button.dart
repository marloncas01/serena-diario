import 'package:flutter/material.dart';
import '../../theme/brand/brand_radius.dart';
import '../../theme/brand/brand_durations.dart';
import '../../theme/brand/brand_shadows.dart';

class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.gradient,
    this.textColor,
    this.height = 52,
    this.borderRadius,
    this.isLoading = false,
    this.isExpanded = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final Gradient? gradient;
  final Color? textColor;
  final double height;
  final double? borderRadius;
  final bool isLoading;
  final bool isExpanded;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
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
    _scale = Tween<double>(begin: 1, end: 0.96).animate(
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
    final effectiveGradient =
        widget.gradient ?? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
        );
    final effectiveTextColor = widget.textColor ?? Colors.white;
    final radius = widget.borderRadius ?? BrandRadius.md;

    final button = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
        onTapUp: widget.onPressed != null
            ? (_) {
                _controller.reverse();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: widget.onPressed != null ? () => _controller.reverse() : null,
        child: AnimatedContainer(
          duration: BrandDurations.fast,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.onPressed != null ? effectiveGradient : null,
            color: widget.onPressed == null
                ? theme.colorScheme.surfaceContainerHighest
                : null,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: widget.onPressed != null
                ? BrandShadows.coloredSoft(theme.colorScheme.primary)
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: effectiveTextColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: effectiveTextColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: effectiveTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (widget.isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
