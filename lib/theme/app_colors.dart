import 'package:flutter/material.dart';

import '../models/emotion.dart';

class AppColors {
  const AppColors._();

  // ── Brand - refined with depth and elegance ──
  static const lavender = Color(0xFFE8E0F0);
  static const softPurple = Color(0xFF7C6FF0);
  static const deepPurple = Color(0xFF4A3B8F);
  static const plum = Color(0xFF5E4B91);
  static const jewel = Color(0xFF2D1B69);
  static const indigo = Color(0xFF3F51B5);

  // ── Surfaces - warm, premium ──
  static const canvas = Color(0xFFF8F7FC);
  static const surface = Color(0xFFFDFCFF);
  static const muted = Color(0xFF7C7A8A);
  static const outline = Color(0xFFE1DEE8);
  static const subtleBorder = Color(0xFFEAE8F0);

  // ── Mood palette - soft, muted, elegant ──
  static const peach = Color(0xFFFFD5C2);
  static const mint = Color(0xFFBFE6D9);
  static const rose = Color(0xFFFCCFD6);
  static const calm = Color(0xFFC6DFD0);
  static const tired = Color(0xFFD4CEF0);

  // ── Extended pastels ──
  static const blush = Color(0xFFFFE6EB);
  static const sky = Color(0xFFD6E4F0);
  static const cream = Color(0xFFFFF3E0);
  static const sage = Color(0xFFC8E6C9);
  static const mauve = Color(0xFFDDD0F0);

  // ── Glass & glow ──
  static const glassWhite = Color(0x33FFFFFF);
  static const glassBlack = Color(0x1A000000);
  static const glowPurple = Color(0x40AC9DF5);

  // ── Semantic - vibrant but refined ──
  static const success = Color(0xFF27AE60);
  static const info = Color(0xFF5B8DEF);
  static const warning = Color(0xFFF5A623);
  static const error = Color(0xFFD32F2F);

  // ── Dark surfaces - deep, not pure black ──
  static const darkSurface = Color(0xFF1C1927);
  static const darkCard = Color(0xFF252230);
  static const darkScaffold = Color(0xFF14121C);
  static const darkElevated = Color(0xFF2E2A3C);
  static const darkLight = Color(0xFF3B364A);
  static const darkBorder = Color(0xFF363240);

  // ── Gradients - smooth and modern ──
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepPurple, softPurple],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softPurple, indigo],
  );

  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD5C2), Color(0xFFFFAB91)],
  );

  static const mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBFE6D9), Color(0xFF9DD5C0)],
  );

  static const peachGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD5C2), Color(0xFFFFBFA3)],
  );

  static const roseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFCCFD6), Color(0xFFF5B7C1)],
  );

  static const skyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD6E4F0), Color(0xFFB0C4DE)],
  );

  static const darkHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A3B8F), Color(0xFF6F62D0)],
  );

  static const glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassWhite, glassBlack],
  );

  static Gradient moodGradient(String mood) {
    final emotion = emotionForLabel(mood);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [emotion.color, Color.lerp(emotion.color, Colors.white, 0.5)!],
    );
  }
}
