import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/theme_controller.dart';

/// Lightweight full-screen background for Serena.
///
/// Each option is a soft gradient plus a few painted decorative shapes.
/// No heavy images: everything is drawn with [CustomPainter].
class SerenaBackgroundView extends StatelessWidget {
  const SerenaBackgroundView({
    super.key,
    required this.background,
    required this.isDark,
  });

  final SerenaBackground background;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainter(background: background, isDark: isDark),
      size: Size.infinite,
    );
  }
}

/// Small rounded preview of a background, used in pickers.
class SerenaBackgroundPreview extends StatelessWidget {
  const SerenaBackgroundPreview({
    super.key,
    required this.background,
    required this.isDark,
    this.width = 72,
    this.height = 48,
  });

  final SerenaBackground background;
  final bool isDark;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _BackgroundPainter(background: background, isDark: isDark),
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter({required this.background, required this.isDark});

  final SerenaBackground background;
  final bool isDark;

  static const _purple = Color(0xFF7C6FF0);
  static const _deepPurple = Color(0xFF2D1B69);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    switch (background) {
      case SerenaBackground.minimalista:
        _paintMinimal(canvas, rect);
      case SerenaBackground.bosque:
        _paintBosque(canvas, rect);
      case SerenaBackground.montanas:
        _paintMontanas(canvas, rect);
      case SerenaBackground.lluvia:
        _paintLluvia(canvas, rect);
      case SerenaBackground.noche:
        _paintNoche(canvas, rect);
      case SerenaBackground.aurora:
        _paintAurora(canvas, rect);
      case SerenaBackground.galaxia:
        _paintGalaxia(canvas, rect);
    }
  }

  void _paintMinimal(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF12111A), const Color(0xFF1B1925)]
              : [const Color(0xFFF6F3FD), const Color(0xFFFDFBFF)],
        ).createShader(rect),
    );
    final soft = Paint()
      ..color = (isDark ? _purple : _deepPurple).withValues(alpha: isDark ? 0.10 : 0.05);
    canvas.drawCircle(
      Offset(rect.width * 0.9, rect.height * 0.12),
      rect.width * 0.4,
      soft,
    );
    canvas.drawCircle(
      Offset(rect.width * 0.1, rect.height * 0.85),
      rect.width * 0.35,
      soft,
    );
  }

  void _paintBosque(Canvas canvas, Rect rect) {
    final top = isDark ? const Color(0xFF0E1B14) : const Color(0xFFDDF1E4);
    final bottom = isDark ? const Color(0xFF16241C) : const Color(0xFFB7DFC8);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    final tree = Paint()
      ..color = (isDark ? const Color(0xFF0A130E) : const Color(0xFF8FBF9F))
          .withValues(alpha: isDark ? 0.7 : 0.55);
    final trunk = Paint()
      ..color = (isDark ? const Color(0xFF070D09) : const Color(0xFF7DA98C))
          .withValues(alpha: isDark ? 0.7 : 0.5);
    final rng = Random(7);
    final n = 7;
    for (var i = 0; i < n; i++) {
      final cx = rect.width * (0.05 + 0.15 * i + rng.nextDouble() * 0.04);
      final baseY = rect.height * (0.78 + 0.03 * rng.nextDouble());
      final scale = 0.8 + rng.nextDouble() * 0.6;
      final w = rect.width * 0.16 * scale;
      final h = rect.height * 0.34 * scale;
      _drawTree(canvas, cx, baseY, w, h, tree, trunk);
    }
  }

  void _drawTree(
    Canvas canvas,
    double cx,
    double baseY,
    double w,
    double h,
    Paint tree,
    Paint trunk,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, baseY + 8),
          width: w * 0.12,
          height: 20,
        ),
        const Radius.circular(4),
      ),
      trunk,
    );
    final path = Path()
      ..moveTo(cx, baseY - h)
      ..lineTo(cx + w / 2, baseY - h * 0.3)
      ..lineTo(cx - w / 2, baseY - h * 0.3)
      ..close();
    canvas.drawPath(path, tree);
  }

  void _paintMontanas(Canvas canvas, Rect rect) {
    final top = isDark ? const Color(0xFF0E1220) : const Color(0xFFDCE7F5);
    final bottom = isDark ? const Color(0xFF1A1F33) : const Color(0xFFB9CBE8);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    final sun = Paint()
      ..color = isDark
          ? const Color(0xFF7C86A8).withValues(alpha: 0.5)
          : const Color(0xFFFFE0B2).withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(rect.width * 0.78, rect.height * 0.2),
      rect.width * 0.09,
      sun,
    );
    final far = Paint()
      ..color = (isDark ? const Color(0xFF232A44) : const Color(0xFFA6BBDD))
          .withValues(alpha: 0.8);
    final near = Paint()
      ..color = (isDark ? const Color(0xFF2E3654) : const Color(0xFF8FA9CF))
          .withValues(alpha: 0.8);
    _drawMountain(canvas, rect.width * 0.15, rect.height, rect.width * 0.7,
        rect.height * 0.35, far);
    _drawMountain(canvas, rect.width * 0.7, rect.height, rect.width * 0.85,
        rect.height * 0.45, near);
  }

  void _drawMountain(
    Canvas canvas,
    double cx,
    double baseY,
    double w,
    double h,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(cx - w / 2, baseY)
      ..lineTo(cx, baseY - h)
      ..lineTo(cx + w / 2, baseY)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintLluvia(Canvas canvas, Rect rect) {
    final top = isDark ? const Color(0xFF121622) : const Color(0xFFDDE8F2);
    final bottom = isDark ? const Color(0xFF1A2030) : const Color(0xFFC2D6E8);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    final drop = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = (isDark ? Colors.white : const Color(0xFF5E7E9C))
          .withValues(alpha: isDark ? 0.12 : 0.18);
    final rng = Random(21);
    for (var i = 0; i < 26; i++) {
      final x = rng.nextDouble() * rect.width;
      final y = rng.nextDouble() * rect.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 10, y + 24),
        drop,
      );
    }
  }

  void _paintNoche(Canvas canvas, Rect rect) {
    final top = isDark ? const Color(0xFF0B0E1C) : const Color(0xFF232B4E);
    final bottom = isDark ? const Color(0xFF161A30) : const Color(0xFF3A4470);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    final rng = Random(42);
    final star = Paint()..color = Colors.white;
    for (var i = 0; i < 60; i++) {
      star.color = Colors.white.withValues(
        alpha: 0.15 + rng.nextDouble() * 0.7,
      );
      final x = rng.nextDouble() * rect.width;
      final y = rng.nextDouble() * rect.height * 0.85;
      final r = 0.6 + rng.nextDouble() * 1.6;
      canvas.drawCircle(Offset(x, y), r, star);
    }
    canvas.drawCircle(
      Offset(rect.width * 0.82, rect.height * 0.22),
      rect.width * 0.05,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _paintAurora(Canvas canvas, Rect rect) {
    final top = isDark ? const Color(0xFF0A1220) : const Color(0xFF1B2B4B);
    final bottom = isDark ? const Color(0xFF0E1826) : const Color(0xFF2E4A6B);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    final bands = [
      const Color(0xFF2BD576).withValues(alpha: 0.22),
      const Color(0xFF7C6FF0).withValues(alpha: 0.18),
      const Color(0xFF3BA3FF).withValues(alpha: 0.14),
    ];
    for (var b = 0; b < bands.length; b++) {
      final paint = Paint()
        ..color = bands[b]
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      final path = Path();
      final baseY = rect.height * (0.45 + b * 0.12);
      path.moveTo(-rect.width * 0.1, baseY);
      for (var i = 0; i <= 10; i++) {
        final x = rect.width * (i / 10 - 0.1);
        final y =
            baseY +
            sin(i * 0.9 + b) * rect.height * 0.06;
        path.lineTo(x, y);
      }
      path.lineTo(rect.width * 1.1, baseY + rect.height * 0.12);
      path.lineTo(-rect.width * 0.1, baseY + rect.height * 0.12);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintGalaxia(Canvas canvas, Rect rect) {
    final top = isDark ? const Color(0xFF100B22) : const Color(0xFF2A1E4A);
    final bottom = isDark ? const Color(0xFF1A1034) : const Color(0xFF3D2B63);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    final nebula = Paint()
      ..color = _purple.withValues(alpha: isDark ? 0.12 : 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(
      Offset(rect.width * 0.3, rect.height * 0.25),
      rect.width * 0.35,
      nebula,
    );
    final nebula2 = Paint()
      ..color = const Color(0xFFE91E8C).withValues(alpha: isDark ? 0.08 : 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawCircle(
      Offset(rect.width * 0.8, rect.height * 0.75),
      rect.width * 0.3,
      nebula2,
    );
    final rng = Random(99);
    final star = Paint()..color = Colors.white;
    for (var i = 0; i < 80; i++) {
      star.color = Colors.white.withValues(
        alpha: 0.12 + rng.nextDouble() * 0.75,
      );
      final x = rng.nextDouble() * rect.width;
      final y = rng.nextDouble() * rect.height;
      final r = 0.5 + rng.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), r, star);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.background != background || oldDelegate.isDark != isDark;
}
