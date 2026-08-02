import 'package:flutter/material.dart';
import 'brand_colors.dart';

class BrandGradients {
  const BrandGradients._();

  // ── Primary gradients ──
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.deepPurple, BrandColors.softPurple],
  );

  static const LinearGradient heroDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.purple800, BrandColors.purple600],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.softPurple, BrandColors.indigo],
  );

  static const LinearGradient subtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.purple50, BrandColors.lavender],
  );

  // ── Surface gradients ──
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.glassWhite, BrandColors.glassBlack],
  );

  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      Color(0x00000000),
      Color(0x1AFFFFFF),
      Color(0x00000000),
    ],
  );

  // ── Utility ──
  static LinearGradient radial({
    required Color center,
    required Color edge,
    Alignment alignment = Alignment.center,
  }) {
    return LinearGradient(
      begin: alignment,
      end: Alignment.bottomRight,
      colors: [center, edge],
    );
  }
}
