import 'package:flutter/material.dart';
import '../../theme/brand/brand_durations.dart';

class FadeInChild extends StatefulWidget {
  const FadeInChild({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = BrandDurations.slow,
    this.slideOffset = 15,
    this.curve = BrandDurations.standard,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideOffset;
  final Curve curve;

  @override
  State<FadeInChild> createState() => _FadeInChildState();
}

class _FadeInChildState extends State<FadeInChild>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: _slide.value * 100,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
