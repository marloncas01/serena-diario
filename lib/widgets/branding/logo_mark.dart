import 'dart:math';
import 'package:flutter/material.dart';

class LogoMark extends StatelessWidget {
  const LogoMark({
    super.key,
    this.size = 24,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoMarkPainter(color),
      ),
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  _LogoMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(size.width, size.height) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(cx - r * 0.08, cy - r * 0.95);
    path.cubicTo(
      cx - r * 0.85, cy - r * 0.85,
      cx - r * 0.95, cy + r * 0.15,
      cx - r * 0.35, cy + r * 0.80,
    );
    path.cubicTo(
      cx - r * 0.05, cy + r * 1.05,
      cx + r * 0.45, cy + r * 0.90,
      cx + r * 0.65, cy + r * 0.45,
    );
    path.cubicTo(
      cx + r * 0.85, cy + r * 0.05,
      cx + r * 0.55, cy - r * 0.55,
      cx + r * 0.08, cy - r * 0.80,
    );

    final cutPath = Path();
    cutPath.moveTo(cx + r * 0.05, cy - r * 0.65);
    cutPath.cubicTo(
      cx + r * 0.55, cy - r * 0.40,
      cx + r * 0.60, cy + r * 0.15,
      cx + r * 0.30, cy + r * 0.45,
    );
    cutPath.cubicTo(
      cx + r * 0.00, cy + r * 0.75,
      cx - r * 0.45, cy + r * 0.65,
      cx - r * 0.55, cy + r * 0.25,
    );
    cutPath.cubicTo(
      cx - r * 0.70, cy - r * 0.35,
      cx - r * 0.35, cy - r * 0.80,
      cx + r * 0.05, cy - r * 0.65,
    );

    final crescent = Path.combine(
      PathOperation.difference,
      path,
      cutPath,
    );

    canvas.drawPath(crescent, paint);
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) =>
      oldDelegate.color != color;

  @override
  bool hitTest(Offset position) => false;
}
