import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/app_texts.dart';
import 'database/hive_journal_database.dart';
import 'providers/journal_provider.dart';
import 'screens/app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_preferences.dart';
import 'services/emotion_pipeline.dart';
import 'services/theme_controller.dart';
import 'services/user_profile.dart';
import 'theme/app_theme.dart';
import 'widgets/ui/serena_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  final platformDark =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          platformDark ? Brightness.light : Brightness.dark,
    ),
  );

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured - continue without cloud features
  }

  EmotionPipeline().init();
  runApp(const SerenaApp());
}

class SerenaApp extends StatelessWidget {
  const SerenaApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => JournalProvider(HiveJournalDatabase())..initialize(),
      ),
      ChangeNotifierProvider(create: (_) => UserProfile()..load()),
      ChangeNotifierProvider(create: (_) => ThemeController()..initialize()),
    ],
    child: Consumer<ThemeController>(
      builder: (context, theme, _) => MaterialApp(
        title: AppTexts.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(style: theme.themeStyle, font: theme.font),
        darkTheme: AppTheme.dark(style: theme.themeStyle, font: theme.font),
        themeMode: theme.mode,
        locale: const Locale('es', 'ES'),
        supportedLocales: const [Locale('es', 'ES')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Stack(
            fit: StackFit.expand,
            children: [
              SerenaBackgroundView(
                background: theme.background,
                isDark: isDark,
              ),
              AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            ],
          );
        },
        home: const StartupGate(),
      ),
    ),
  );
}

enum _StartupStage { splash, onboarding, setup, app }

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  _StartupStage _stage = _StartupStage.splash;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve({bool skipSplash = false}) async {
    if (!skipSplash) {
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    final prefs = AppPreferences();
    final hasOnboarding = await prefs.hasCompletedOnboarding;
    if (!hasOnboarding) {
      if (mounted) setState(() => _stage = _StartupStage.onboarding);
      return;
    }
    if (!mounted) return;
    final profile = context.read<UserProfile>();
    final hasSetup = await prefs.hasCompletedSetup;
    if (!mounted) return;
    await profile.load();
    if (!mounted) return;
    setState(() => _stage = hasSetup ? _StartupStage.app : _StartupStage.setup);
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _StartupStage.splash:
        return const SplashScreen();
      case _StartupStage.onboarding:
        return OnboardingScreen(
          onComplete: () => _resolve(skipSplash: true),
        );
      case _StartupStage.setup:
        return const SetupScreen();
      case _StartupStage.app:
        return const AppShell();
    }
  }
}
