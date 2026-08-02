import 'package:flutter/material.dart';

import '../widgets/branding/serena_logo.dart';
import '../core/app_constants.dart';
import '../services/app_preferences.dart';
import '../theme/brand/brand_durations.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  var _page = 0;
  bool _isFinishing = false;

  static const _slides = [
    (
      icon: Icons.auto_stories_rounded,
      title: 'Bienvenido a Serena',
      subtitle: 'Un diario inteligente para mirar tu día con más calma.',
    ),
    (
      icon: Icons.lock_rounded,
      title: 'Tu historia es privada',
      subtitle: 'Todo permanece únicamente en tu dispositivo. Siempre es tuyo.',
    ),
    (
      icon: Icons.favorite_rounded,
      title: 'Bienestar emocional',
      subtitle: 'Registra lo que sientes y descubre tus pequeños patrones.',
    ),
  ];

  Future<void> _finish() async {
    if (_isFinishing) return;
    _isFinishing = true;
    await AppPreferences().completeOnboarding();
    widget.onComplete();
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

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.all(24),
            child: constraints.maxHeight < 600
                ? SingleChildScrollView(
                    child: _buildCompactContent(theme, isDark),
                  )
                : Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: SerenaLogo(size: 42, color: theme.colorScheme.primary),
                      ),
                      const Spacer(flex: 2),
                      Expanded(
                        flex: 6,
                        child: _buildPageView(theme, isDark),
                      ),
                      _buildIndicators(),
                      const SizedBox(height: 32),
                      _buildButton(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContent(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.topLeft,
          child: SerenaLogo(size: 42, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 300,
          child: _buildPageView(theme, isDark),
        ),
        const SizedBox(height: 16),
        _buildIndicators(),
        const SizedBox(height: 24),
        _buildButton(),
      ],
    );
  }

  Widget _buildPageView(ThemeData theme, bool isDark) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: (value) => setState(() => _page = value),
      itemCount: _slides.length,
      itemBuilder: (context, index) {
        final slide = _slides[index];
        return AnimatedOpacity(
          duration: BrandDurations.slow,
          opacity: _page == index ? 1 : 0.3,
          child: AnimatedScale(
            scale: _page == index ? 1.0 : 0.9,
            duration: BrandDurations.slow,
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(
                                theme.colorScheme.primary,
                                Colors.black,
                                0.25,
                              )!,
                              Color.lerp(
                                theme.colorScheme.tertiary,
                                Colors.black,
                                0.25,
                              )!,
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: index == 0
                                ? [theme.colorScheme.primary, theme.colorScheme.primary]
                                : index == 1
                                    ? [theme.colorScheme.secondary, theme.colorScheme.primary]
                                    : [theme.colorScheme.tertiary, theme.colorScheme.primary],
                          ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    slide.icon,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  slide.title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  slide.subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => AnimatedContainer(
          duration: BrandDurations.normal,
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(4),
          width: _page == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _page == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _page == _slides.length - 1
            ? _finish
            : () => _controller.nextPage(
                duration: BrandDurations.slow,
                curve: Curves.easeOutCubic,
              ),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
        ),
        child: Text(
          _page == _slides.length - 1 ? 'Comenzar' : 'Continuar',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
