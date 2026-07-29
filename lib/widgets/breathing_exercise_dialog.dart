import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import '../theme/brand/brand_spacing.dart';

class BreathingExerciseDialog extends StatefulWidget {
  const BreathingExerciseDialog({super.key});

  @override
  State<BreathingExerciseDialog> createState() =>
      _BreathingExerciseDialogState();
}

class _BreathingExerciseDialogState extends State<BreathingExerciseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  Timer? _phaseTimer;
  String _phase = 'Inhala';
  int _seconds = 4;
  int _cycles = 0;
  bool _finished = false;
  static const int _maxCycles = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _startInhale();
  }

  void _startInhale() {
    setState(() {
      _phase = 'Inhala';
      _seconds = 4;
    });
    _controller.forward(from: 0);
    _startCountdown(() {
      _startHold();
    });
  }

  void _startHold() {
    setState(() {
      _phase = 'Sostén';
      _seconds = 4;
    });
    _startCountdown(() {
      _startExhale();
    });
  }

  void _startExhale() {
    setState(() {
      _phase = 'Exhala';
      _seconds = 6;
    });
    _controller.reverse(from: 1.0);
    _startCountdown(() {
      _cycles++;
      if (_cycles >= _maxCycles) {
        setState(() => _finished = true);
      } else {
        _startInhale();
      }
    });
  }

  void _startCountdown(VoidCallback onDone) {
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        onDone();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _finished ? 'Ejercicio completado' : 'Respiración guiada',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: BrandSpacing.lg),
            if (_finished) ...[
              const Text('🌿', style: TextStyle(fontSize: 48)),
              const SizedBox(height: BrandSpacing.md),
              Text(
                'Completaste $_maxCycles ciclos de respiración.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: BrandSpacing.md),
              Text(
                '¿Cómo te sientes ahora?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              AnimatedBuilder(
                animation: _scaleAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _phase,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '$_seconds',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w300,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: BrandSpacing.md),
              Text(
                'Ciclo ${_cycles + 1} de $_maxCycles',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
            const SizedBox(height: BrandSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_finished)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                if (_finished)
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Listo'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
