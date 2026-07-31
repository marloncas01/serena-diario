import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    required this.child,
    this.primaryColor,
    this.secondaryColor,
    this.enableParticles = true,
  });

  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool enableParticles;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(12, (_) => _Particle.random());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = widget.primaryColor ??
        (isDark ? theme.colorScheme.primary : theme.colorScheme.primaryContainer);
    final secondary = widget.secondaryColor ??
        (isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primaryContainer.withValues(alpha: 0.5));

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, secondary],
            ),
          ),
        ),
        if (widget.enableParticles)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              size: Size.infinite,
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                color: isDark
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : theme.colorScheme.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });

  factory _Particle.random() {
    final rng = Random();
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      radius: 20 + rng.nextDouble() * 60,
      speed: 0.3 + rng.nextDouble() * 0.7,
      phase: rng.nextDouble() * pi * 2,
    );
  }

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  final List<_Particle> particles;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final dx = (p.x + sin(progress * pi * 2 * p.speed + p.phase) * 0.05) *
          size.width;
      final dy = (p.y + cos(progress * pi * 2 * p.speed + p.phase) * 0.05) *
          size.height;

      paint.color = color;
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
