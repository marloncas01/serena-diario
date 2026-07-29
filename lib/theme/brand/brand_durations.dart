import 'package:flutter/material.dart';

class BrandDurations {
  const BrandDurations._();

  // ── Named scale ──
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  static const Duration splash = Duration(milliseconds: 1200);

  // ── Semantic aliases ──
  static const Duration micro = instant;
  static const Duration transition = normal;
  static const Duration reveal = slow;

  // ── Curves ──
  static const Curve standard = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve spring = Curves.easeOutBack;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOut;
  static const Curve sharp = Curves.easeOutExpo;
}
