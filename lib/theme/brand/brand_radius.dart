import 'package:flutter/material.dart';

class BrandRadius {
  const BrandRadius._();

  // ── Named scale ──
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double pill = 999;

  // ── BorderRadius presets ──
  static const BorderRadius noneBorder = BorderRadius.zero;
  static const BorderRadius xsBorder = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlBorder = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(pill));

  // ── Semantic presets ──
  static const BorderRadius card = lgBorder;
  static const BorderRadius button = mdBorder;
  static const BorderRadius input = mdBorder;
  static const BorderRadius chip = pillBorder;
  static const BorderRadius dialog = xxlBorder;
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
  static const BorderRadius snackBar = lgBorder;

  // ── Selective radius ──
  static BorderRadius top(double radius) => BorderRadius.vertical(
    top: Radius.circular(radius),
  );

  static BorderRadius bottom(double radius) => BorderRadius.vertical(
    bottom: Radius.circular(radius),
  );

  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft),
    topRight: Radius.circular(topRight),
    bottomLeft: Radius.circular(bottomLeft),
    bottomRight: Radius.circular(bottomRight),
  );
}
