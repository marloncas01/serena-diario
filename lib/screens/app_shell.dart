import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/user_profile.dart';

import '../theme/brand/brand_durations.dart';
import '../theme/brand/brand_radius.dart';
import '../widgets/branding/logo_text.dart';
import 'calendar_screen.dart';
import 'diary_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'wellbeing_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  final _pages = List<Widget?>.filled(5, null);
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: BrandDurations.medium,
      value: 1,
    );
    _fade = Tween<double>(begin: 0.45, end: 1).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: BrandDurations.standard),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Widget _page(int index) {
    _pages[index] ??= switch (index) {
      0 => const DiaryScreen(),
      1 => CalendarScreen(
          onWriteTap: () {
            setState(() => _index = 0);
            _fadeCtrl.forward(from: 0.35);
          },
        ),
      2 => const WellbeingScreen(),
      3 => const StatisticsScreen(),
      4 => const SettingsScreen(),
      _ => const SizedBox.shrink(),
    };
    return _pages[index]!;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfile>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = isDark ? Colors.white : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
              width: 26,
              height: 26,
              cacheWidth:
                  (26 * MediaQuery.devicePixelRatioOf(context)).round(),
              filterQuality: FilterQuality.medium,
            ),
            const SizedBox(width: 8),
            LogoText(size: 18, color: logoColor),
            const Spacer(),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: logoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(BrandRadius.md),
                border: Border.all(
                  color: logoColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  profile.avatar,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _fade,
        builder: (context, child) => Opacity(
          opacity: _fade.value,
          child: child,
        ),
        child: IndexedStack(
          index: _index,
          children: List.generate(5, (i) => _page(i)),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          HapticFeedback.selectionClick();
          setState(() => _index = value);
          _fadeCtrl.forward(from: 0.35);
        },
        animationDuration: BrandDurations.normal,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
        elevation: 0,
        backgroundColor: isDark
            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa_rounded),
            label: 'Bienestar',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats_rounded),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
