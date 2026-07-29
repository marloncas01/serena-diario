import 'package:flutter/material.dart';
import 'brand_durations.dart';

class BrandAnimations {
  const BrandAnimations._();

  // ── Fade transition helpers ──
  static Widget fadeIn({
    required Animation<double> animation,
    required Widget child,
    double begin = 0,
    double end = 1,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(parent: animation, curve: BrandDurations.standard),
      ),
      child: child,
    );
  }

  static Widget fadeSlideUp({
    required Animation<double> animation,
    required Widget child,
    double slideOffset = 20,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: (animation.value * 2).clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }

  // ── Scale animation helper ──
  static Widget scaleIn({
    required Animation<double> animation,
    required Widget child,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: animation,
          curve: BrandDurations.spring,
        ),
      ),
      child: child,
    );
  }

  // ── Slide transition helper ──
  static Widget slideUp({
    required Animation<double> animation,
    required Widget child,
    double offset = 30,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, offset / 100),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: BrandDurations.standard),
      ),
      child: child,
    );
  }

  static Widget slideRight({
    required Animation<double> animation,
    required Widget child,
    double offset = 30,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(-offset / 100, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: BrandDurations.standard),
      ),
      child: child,
    );
  }

  // ── Staggered list animation ──
  static Widget staggeredListItem({
    required int index,
    required Animation<double> animation,
    required Widget child,
    Duration delay = const Duration(milliseconds: 60),
  }) {
    final itemDelay = delay * index;
    final adjustedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
        (itemDelay.inMilliseconds / 1000).clamp(0, 0.8),
        1.0,
        curve: BrandDurations.standard,
      ),
    );
    return fadeSlideUp(animation: adjustedAnimation, child: child);
  }
}
