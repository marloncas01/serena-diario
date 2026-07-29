import 'dart:math';
import 'package:flutter/material.dart';

class LogoIcon extends StatelessWidget {
  const LogoIcon({
    super.key,
    this.size = 64,
    this.color = Colors.white,
    this.showGlow = false,
  });

  final double size;
  final Color color;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoIconPainter(
          color: color,
          showGlow: showGlow,
        ),
      ),
    );
  }
}

class _LogoIconPainter extends CustomPainter {
  _LogoIconPainter({required this.color, this.showGlow = false});

  final Color color;
  final bool showGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(size.width, size.height) / 2;

    if (showGlow) {
      _paintGlow(canvas, cx, cy, r);
    }

    _paintCrescent(canvas, cx, cy, r);
    _paintPages(canvas, cx, cy, r);
    _paintSpark(canvas, cx, cy, r);
  }

  void _paintGlow(Canvas canvas, double cx, double cy, double r) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 1.5),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), r * 1.5, glowPaint);
  }

  void _paintCrescent(Canvas canvas, double cx, double cy, double r) {
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

  void _paintPages(Canvas canvas, double cx, double cy, double r) {
    final pagePaint = Paint()
      ..color = color.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.0, r * 0.045)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final leftPage = Path();
    leftPage.moveTo(cx - r * 0.22, cy + r * 0.42);
    leftPage.cubicTo(
      cx - r * 0.18, cy + r * 0.05,
      cx - r * 0.05, cy - r * 0.25,
      cx + r * 0.02, cy - r * 0.35,
    );
    canvas.drawPath(leftPage, pagePaint);

    final rightPage = Path();
    rightPage.moveTo(cx + r * 0.22, cy + r * 0.42);
    rightPage.cubicTo(
      cx + r * 0.18, cy + r * 0.05,
      cx + r * 0.05, cy - r * 0.25,
      cx - r * 0.02, cy - r * 0.35,
    );
    canvas.drawPath(rightPage, pagePaint);
  }

  void _paintSpark(Canvas canvas, double cx, double cy, double r) {
    final sparkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final sx = cx - r * 0.02;
    final sy = cy - r * 0.28;
    final outerR = r * 0.11;
    final innerR = r * 0.035;

    final sparkPath = Path();
    for (var i = 0; i < 4; i++) {
      final angle = -pi / 2 + (i * pi) / 2;
      final innerAngle1 = angle + pi / 4;
      final innerAngle2 = angle - pi / 4;

      final ox = sx + outerR * cos(angle);
      final oy = sy + outerR * sin(angle);
      final ix1 = sx + innerR * cos(innerAngle1);
      final iy1 = sy + innerR * sin(innerAngle1);
      final ix2 = sx + innerR * cos(innerAngle2);
      final iy2 = sy + innerR * sin(innerAngle2);

      if (i == 0) {
        sparkPath.moveTo(ox, oy);
      } else {
        sparkPath.lineTo(ox, oy);
      }
      sparkPath.lineTo(ix1, iy1);
      sparkPath.lineTo(ix2, iy2);
    }
    sparkPath.close();
    canvas.drawPath(sparkPath, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.showGlow != showGlow;

  @override
  bool hitTest(Offset position) => false;
}
