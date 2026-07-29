import 'package:flutter/material.dart';
import '../core/app_texts.dart';
import '../widgets/branding/logo_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _loaderController;

  late final Animation<double> _fadeLogo;
  late final Animation<double> _scaleLogo;
  late final Animation<double> _rotateLogo;
  late final Animation<double> _fadeTitle;
  late final Animation<double> _fadeTagline;
  late final Animation<double> _fadeLoader;
  late final Animation<double> _loaderProgress;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeLogo = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
      ),
    );

    _scaleLogo = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutBack),
      ),
    );

    _rotateLogo = Tween<double>(begin: -0.15, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.05, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _fadeTitle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.50, curve: Curves.easeOut),
      ),
    );

    _fadeTagline = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.40, 0.65, curve: Curves.easeOut),
      ),
    );

    _fadeLoader = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
      ),
    );

    _loaderProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    _loaderController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              _buildLogo(),
              const SizedBox(height: 28),
              _buildTitle(),
              const SizedBox(height: 10),
              _buildTagline(),
              const Spacer(flex: 2),
              _buildLoader(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, _) {
        return Opacity(
          opacity: _fadeLogo.value,
          child: Transform.scale(
            scale: _scaleLogo.value,
              child: Transform.rotate(
                angle: _rotateLogo.value,
                child: Image.asset(
                  isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
                  width: 120,
                  height: 120,
                ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _fadeTitle,
      child: LogoText(
        size: 46,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _fadeTagline,
      child: Text(
        AppTexts.tagline,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.70),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoader() {
    return FadeTransition(
      opacity: _fadeLoader,
      child: AnimatedBuilder(
        animation: _loaderController,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _loaderProgress.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFAC9DF5),
                          Color(0xFFFFFFFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Preparando tu espacio...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
