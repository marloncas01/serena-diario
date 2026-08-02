import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/app_texts.dart';
import '../providers/journal_provider.dart';
import '../services/theme_controller.dart';
import '../services/user_profile.dart';
import '../services/ai_config_service.dart';
import '../services/ai_provider.dart';
import '../utils/app_feedback.dart';
import '../theme/brand/brand_durations.dart';

import '../theme/brand/brand_radius.dart';
import '../theme/brand/brand_shadows.dart';
import '../theme/brand/brand_spacing.dart';
import '../widgets/glass_card.dart';
import '../widgets/ui/serena_background.dart';
import '../services/cloud/auth_service_firebase.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final entries = context.select<JournalProvider, int>(
      (provider) => provider.entries.length,
    );
    final estimatedStorage = context.select<JournalProvider, int>(
      (provider) => provider.entries.fold(
        0,
        (sum, entry) => sum + entry.note.length + entry.tags.join().length,
      ),
    );
    final themeController = context.watch<ThemeController>();
    final profile = context.watch<UserProfile>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > AppBreakpoints.compact;
    final padding = isWide ? 32.0 : 16.0;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 110),
        children: [
          _buildProfileCard(context, theme, profile),
          const SizedBox(height: BrandSpacing.xl),

          _buildGoalSection(context, profile, theme),
          const SizedBox(height: BrandSpacing.xl),

          _buildPersonalitySection(context, profile, theme),
          const SizedBox(height: BrandSpacing.xl),

          _buildAppearanceSection(context, themeController, theme, isDark),
          const SizedBox(height: BrandSpacing.xl),

          _buildPreferencesSection(context, theme),
          const SizedBox(height: BrandSpacing.xl),

          _buildAccountSection(context, theme),
          const SizedBox(height: BrandSpacing.xl),

          _buildAISection(context, theme),
          const SizedBox(height: BrandSpacing.xl),

          _buildInfoSection(entries, estimatedStorage, theme, screenWidth, isWide),
          const SizedBox(height: BrandSpacing.xl),

          _buildAboutSection(context, theme),
          const SizedBox(height: BrandSpacing.xxl),

          Center(
            child: Text(
              AppTexts.privacyNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme, UserProfile profile) {
    final isDark = theme.brightness == Brightness.dark;
    final foreground = isDark
        ? Color.lerp(
            theme.colorScheme.onPrimary,
            theme.colorScheme.onSecondary,
            0.5,
          )!
        : Colors.white;
    final foregroundSoft = foreground.withValues(alpha: isDark ? 0.7 : 0.6);
    return GlassCard(
      gradient: LinearGradient(
        colors: isDark
            ? [
                Color.lerp(
                  theme.colorScheme.primary,
                  Colors.black,
                  0.18,
                )!,
                Color.lerp(
                  theme.colorScheme.secondary,
                  Colors.black,
                  0.18,
                )!,
              ]
            : [theme.colorScheme.primary, theme.colorScheme.secondary],
      ),
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(BrandSpacing.xl),
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(BrandRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.avatar,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.userName.isNotEmpty
                            ? profile.userName
                            : 'Tu espacio personal',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: foregroundSoft,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(BrandRadius.pill),
                  ),
                  child: Text(
                    'Editar perfil',
                    style: TextStyle(
                      color: foregroundSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: foreground,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    ThemeController controller,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Apariencia'),
        const SizedBox(height: BrandSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThemeStylePicker(context, controller, theme, isDark),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildBackgroundPicker(context, controller, theme, isDark),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildFontPicker(context, controller, theme),
              const Divider(height: 1, indent: 68),
              SwitchListTile(
                secondary: _SettingsIcon(
                  icon: Icons.dark_mode_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text(AppTexts.darkMode),
                subtitle: Text(
                  controller.mode == ThemeMode.dark ? 'Activado' : 'Desactivado',
                ),
                value: controller.mode == ThemeMode.dark,
                onChanged: controller.setDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeStylePicker(
    BuildContext context,
    ThemeController controller,
    ThemeData theme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(BrandSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tema',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                controller.themeStyle.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: BrandSpacing.md),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: SerenaThemeStyle.values.map((style) {
              final selected = controller.themeStyle == style;
              return GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await controller.setThemeStyle(style);
                },
                child: AnimatedContainer(
                  duration: BrandDurations.fast,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: style.seedColor,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: isDark
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                    boxShadow: selected
                        ? BrandShadows.colored(style.seedColor, opacity: 0.4)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPicker(
    BuildContext context,
    ThemeController controller,
    ThemeData theme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BrandSpacing.base,
        vertical: BrandSpacing.base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.landscape_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Fondo',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: BrandSpacing.md),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: SerenaBackground.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final bg = SerenaBackground.values[index];
                final selected = controller.background == bg;
                return GestureDetector(
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await controller.setBackground(bg);
                  },
                  child: AnimatedContainer(
                    duration: BrandDurations.fast,
                    width: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(BrandRadius.lg),
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SerenaBackgroundPreview(
                          background: bg,
                          isDark: isDark,
                          width: 64,
                          height: 40,
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          bg.icon,
                          size: 14,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bg.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: selected ? FontWeight.w700 : null,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontPicker(
    BuildContext context,
    ThemeController controller,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(BrandSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_fields_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tipografía',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: BrandSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SerenaFont.values.map((font) {
              final selected = controller.font == font;
              return ChoiceChip(
                label: Text(
                  font.label,
                  style: TextStyle(
                    fontFamily: font.bodyFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: selected,
                selectedColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: selected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
                onSelected: (_) async {
                  HapticFeedback.selectionClick();
                  await controller.setFont(font);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalitySection(
    BuildContext context,
    UserProfile profile,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Personalidad de Serena'),
        const SizedBox(height: BrandSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: SerenaPersonality.values.map((p) {
              final selected = profile.personality == p;
              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(p.label),
                subtitle: Text(
                  p.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () => profile.setPersonality(p),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Preferencias'),
        const SizedBox(height: BrandSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: _SettingsIcon(
                  icon: Icons.lock_outline_rounded,
                  color: theme.colorScheme.tertiary,
                ),
                title: const Text(AppTexts.privacy),
                subtitle: const Text(AppTexts.privacyNote),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(BrandRadius.pill),
                  ),
                  child: Text(
                    'Hive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 68),
              ListTile(
                leading: _SettingsIcon(
                  icon: Icons.file_upload_outlined,
                  color: theme.colorScheme.tertiary,
                ),
                title: const Text(AppTexts.export_),
                subtitle: const Text('Preparado para una futura versión'),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
                onTap: () => _showComingSoon(context),
              ),
              const Divider(height: 1, indent: 68),
              ListTile(
                leading: _SettingsIcon(
                  icon: Icons.notifications_outlined,
                  color: theme.colorScheme.error,
                ),
                title: const Text(AppTexts.reminders),
                subtitle: const Text('Próximamente'),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context, ThemeData theme) {
    try {
      final auth = AuthServiceFirebase();
      final user = auth.getCurrentUser();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Cuenta'),
          const SizedBox(height: BrandSpacing.sm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: user != null
                ? Column(
                    children: [
                      ListTile(
                        leading: _SettingsIcon(
                          icon: Icons.account_circle_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(user.displayName.isNotEmpty ? user.displayName : 'Usuario'),
                        subtitle: Text(user.email),
                      ),
                      const Divider(height: 1, indent: 68),
                      ListTile(
                        leading: _SettingsIcon(
                          icon: Icons.logout_rounded,
                          color: theme.colorScheme.error,
                        ),
                        title: const Text('Cerrar sesión'),
                        onTap: () async {
                          try {
                            await auth.signOut();
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst(
                                    'Exception: ',
                                    'Error: ',
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          if (!context.mounted) return;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sesión cerrada'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : ListTile(
                    leading: _SettingsIcon(
                      icon: Icons.login_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Iniciar sesión con Google'),
                    subtitle: const Text('Conecta tu cuenta de Google'),
                    onTap: () async {
                      try {
                        await auth.signInWithGoogle();
                        if (!context.mounted) return;
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sesión iniciada con Google'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', 'Error: '),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildAISection(BuildContext context, ThemeData theme) {
    final config = AIConfigService();
    final provider = AIProviderManager().provider;
    final geminiActive = provider.name == 'gemini';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'IA Conversacional'),
        const SizedBox(height: BrandSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                secondary: _SettingsIcon(
                  icon: Icons.auto_awesome_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Activar IA'),
                subtitle: Text(
                  config.statusDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: config.aiEnabled,
                onChanged: (value) async {
                  HapticFeedback.lightImpact();
                  await config.setAIEnabled(value);
                  if (!mounted) return;
                  setState(() {});
                },
                activeThumbColor: theme.colorScheme.primary,
              ),
              const Divider(height: 1, indent: 68),
              ListTile(
                leading: _SettingsIcon(
                  icon: Icons.circle,
                  color: config.geminiAvailable
                      ? theme.colorScheme.tertiary
                      : config.apiStatus == APIStatus.detected
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.error,
                ),
                title: Text(config.statusLabel),
                subtitle: Text(
                  'API: ${config.hasAPIKey ? "Detectada" : "No encontrada"}\n'
                  'Proveedor: ${geminiActive ? "Google Gemini" : "Local"}\n'
                  'Modelo: ${geminiActive ? config.modelLabel : "Fallback local"}\n'
                  'Historial: ${config.historyLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const Divider(height: 1, indent: 68),
              ListTile(
                leading: _SettingsIcon(
                  icon: Icons.history_rounded,
                  color: theme.colorScheme.secondary,
                ),
                title: const Text('Vaciar historial'),
                subtitle: Text(
                  config.historyLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
                onTap: () async {
                  await AIProviderManager().clearConversationHistory();
                  if (!context.mounted) return;
                  AppFeedback.success(context, 'Historial limpiado');
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    int entries,
    int estimatedStorage,
    ThemeData theme,
    double screenWidth,
    bool isWide,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Tu información'),
        const SizedBox(height: BrandSpacing.sm),
        GlassCard(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - 24) / 3
                    : (screenWidth - 32 - 12) / 2,
                child: _Info(
                  value: '$entries',
                  label: 'entradas',
                  color: theme.colorScheme.primary,
                  icon: Icons.edit_note_rounded,
                ),
              ),
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - 24) / 3
                    : (screenWidth - 32 - 12) / 2,
                child: _Info(
                  value: '${(estimatedStorage / 1024).toStringAsFixed(1)} KB',
                  label: 'contenido local',
                  color: theme.colorScheme.tertiary,
                  icon: Icons.storage_rounded,
                ),
              ),
              SizedBox(
                width: isWide
                    ? (screenWidth - 64 - 24) / 3
                    : (screenWidth - 32 - 12) / 2,
                child: _Info(
                  value: '1.0',
                  label: 'versión demo',
                  color: theme.colorScheme.secondary,
                  icon: Icons.tag_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: AppTexts.aboutSerena),
        const SizedBox(height: BrandSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const SizedBox(height: 28),
              Image.asset(
                isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
                width: 64,
                height: 64,
                cacheWidth:
                    (64 * MediaQuery.devicePixelRatioOf(context)).round(),
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(height: 12),
              Text(
                AppTexts.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppTexts.version,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  AppTexts.aboutDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              ListTile(
                leading: _SettingsIcon(
                  icon: Icons.code_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Tecnologías'),
                subtitle: const Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _TechBadge('Flutter'),
                    _TechBadge('Hive'),
                    _TechBadge('Material 3'),
                    _TechBadge('Provider'),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 68),
              ListTile(
                leading: _SettingsIcon(
                  icon: Icons.privacy_tip_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text(AppTexts.legalInfo),
                subtitle: const Text(
                  'Política de privacidad y términos de uso',
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutScreen(),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 68),
              ListTile(
                leading: _SettingsIcon(
                  icon: Icons.workspace_premium_outlined,
                  color: theme.colorScheme.tertiary,
                ),
                title: const Text('Licencias y créditos'),
                subtitle: const Text('Dependencias de código abierto'),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Serena',
                  applicationVersion: '1.1',
                ),
              ),
              const Divider(height: 1, indent: 68),
              ListTile(
                leading: _SettingsIcon(
                  icon: Icons.favorite_outline_rounded,
                  color: theme.colorScheme.error,
                ),
                title: const Text('Creado por'),
                subtitle: const Text(AppTexts.developedBy),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSection(
    BuildContext context,
    UserProfile profile,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Tu frase personal'),
        const SizedBox(height: BrandSpacing.sm),
        GlassCard(
          onTap: () => _showEditGoalDialog(context, profile),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(BrandRadius.md),
                ),
                child: Icon(
                  Icons.format_quote_rounded,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frase personal',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.goal.isNotEmpty
                          ? profile.goal
                          : 'Toca para añadir tu frase motivacional',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: profile.goal.isNotEmpty
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        fontStyle: profile.goal.isEmpty
                            ? FontStyle.italic
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditGoalDialog(BuildContext context, UserProfile profile) {
    final controller = TextEditingController(text: profile.goal);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tu frase personal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Ej: Paso a paso, lejos llego',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              profile.setGoal(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente disponible 🚀'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(BrandRadius.md),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _TechBadge extends StatelessWidget {
  const _TechBadge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(BrandRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.5),
                color.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(BrandRadius.md),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
