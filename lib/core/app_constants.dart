import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class AppRadii {
  const AppRadii._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double card = 20;
  static const double control = 16;
  static const double pill = 999;
}

class AppDurations {
  const AppDurations._();
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration splash = Duration(milliseconds: 1200);
}

class AppCurves {
  const AppCurves._();
  static const Curve standard = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve spring = Curves.easeOutBack;
}

class AppBreakpoints {
  const AppBreakpoints._();
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
}

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0A0D0630), blurRadius: 16, offset: Offset(0, 4)),
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

  static List<BoxShadow> colored(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

const motivationalQuotes = [
  '"Hoy también cuenta, incluso en lo pequeño."',
  '"Cada palabra que escribes es un paso hacia ti."',
  '"No necesitas tenerlo todo claro. Solo empezar."',
  '"Tus sentimientos son válidos, todos ellos."',
  '"El simple acto de escribir ya es un avance."',
  '"Permítete sentir, después suelta."',
  '"No se trata de ser perfecto, sino de ser honesto."',
  '"Tu diario es un espejo de tu crecimiento."',
  '"A veces, escribir es la mejor forma de respirar."',
  '"Hoy escribes, mañana entiendes."',
  '"Cada entrada es un ladrillo en tu bienestar."',
  '"No hay prisa. Tu historia se escribe a su ritmo."',
  '"Lo que sientes hoy tiene un propósito, aunque no lo veas."',
  '"Reconocer lo pequeño es celebrar lo grande."',
  '"Escribir es escucharte a ti mismo."',
];
