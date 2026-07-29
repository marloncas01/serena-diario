import 'package:flutter/material.dart';

class BrandShadows {
  const BrandShadows._();

  // ── Light mode shadows ──
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x080D0630),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A0D0630),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0D0D0630),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x120D0630),
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> high = [
    BoxShadow(
      color: Color(0x1A0D0630),
      blurRadius: 48,
      offset: Offset(0, 16),
      spreadRadius: -6,
    ),
  ];

  // ── Dark mode shadows ──
  static const List<BoxShadow> darkSubtle = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> darkSoft = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> darkMedium = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> darkElevated = [
    BoxShadow(
      color: Color(0x55000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  // ── Colored shadows ──
  static List<BoxShadow> colored(Color color, {double opacity = 0.2}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> coloredSoft(Color color, {double opacity = 0.12}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Context-aware helpers ──
  static List<BoxShadow> forContext(BuildContext context, {
    BoxShadow? light,
    BoxShadow? dark,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return [dark ?? const BoxShadow()];
    }
    return [light ?? const BoxShadow()];
  }

  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSoft : soft;
  }

  static List<BoxShadow> elevatedCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkMedium : medium;
  }
}
