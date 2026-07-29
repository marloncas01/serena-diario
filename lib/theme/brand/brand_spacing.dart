import 'package:flutter/material.dart';

class BrandSpacing {
  const BrandSpacing._();

  // ── Base unit ──
  static const double unit = 4;

  // ── Named scale ──
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  // ── Semantic aliases ──
  static const double pagePadding = base;
  static const double sectionGap = xl;
  static const double cardPadding = base;
  static const double itemGap = sm;
  static const double inlineGap = xs;
  static const double iconGap = sm;

  // ── EdgeInsets presets ──
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(base);
  static const EdgeInsets paddingLg = EdgeInsets.all(xl);
  static const EdgeInsets paddingXl = EdgeInsets.all(xxl);

  static const EdgeInsets horizontalPage = EdgeInsets.symmetric(
    horizontal: base,
  );
  static const EdgeInsets horizontalWide = EdgeInsets.symmetric(
    horizontal: xxl,
  );

  static const EdgeInsets verticalSection = EdgeInsets.symmetric(
    vertical: xl,
  );

  // ── Helpers ──
  static double responsive(
    BuildContext context, {
    required double compact,
    required double medium,
    required double expanded,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return expanded;
    if (width >= 840) return medium;
    return compact;
  }

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) =>
      screenWidth(context) < 600;

  static bool isMedium(BuildContext context) {
    final w = screenWidth(context);
    return w >= 600 && w < 1200;
  }

  static bool isExpanded(BuildContext context) =>
      screenWidth(context) >= 1200;
}
