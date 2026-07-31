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
import '../services/cloud/auth_service_firebase.dart';

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

          _buildColorSection(context, profile, themeController, theme, isDark),
          const SizedBox(height: BrandSpacing.xl),

          _buildPersonalitySection(context, profile, theme),
          const SizedBox(height: BrandSpacing.xl),

          _buildPreferencesSection(context, themeController, theme),
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
    return GlassCard(
      gradient: LinearGradient(
        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
      ),
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(BrandSpacing.xl),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showAvatarPicker(context, profile),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => _showEditNameDialog(context, profile),
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
                          style: const TextStyle(
                            color: Colors.white,
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
                        color: Colors.white.withValues(alpha: 0.6),
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
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(BrandRadius.pill),
                    ),
                    child: const Text(
                      'Toca para editar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, UserProfile profile) {
    final controller = TextEditingController(text: profile.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tu nombre'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: '¿Cómo te llamas?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                profile.setUserName(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollController) {
          final theme = Theme.of(ctx);
          return Column(
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Elige tu avatar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: avatarCategories.length,
                  itemBuilder: (_, catIdx) {
                    final cat = avatarCategories.keys.elementAt(catIdx);
                    final avatars = avatarCategories[cat]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            cat,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: avatars.map((emoji) {
                            final selected = profile.avatar == emoji;
                            return GestureDetector(
                              onTap: () {
                                profile.setAvatar(emoji);
                                Navigator.pop(ctx);
                              },
                              child: AnimatedContainer(
                                duration: BrandDurations.fast,
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(BrandRadius.lg),
                                  border: selected
                                      ? Border.all(
                                          color: theme.colorScheme.primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
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

  Widget _buildColorSection(
    BuildContext context,
    UserProfile profile,
    ThemeController themeController,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Color del tema'),
        const SizedBox(height: BrandSpacing.sm),
        GlassCard(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppThemeColor.values.map((c) {
              final selected = profile.themeColor == c;
              return GestureDetector(
                onTap: () async {
                  await profile.setThemeColor(c);
                  if (!mounted) return;
                  themeController.updateSeedColor(c.color);
                },
                child: AnimatedContainer(
                  duration: BrandDurations.fast,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                    boxShadow: selected
                        ? BrandShadows.colored(c.color, opacity: 0.4)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    ThemeController themeController,
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
              SwitchListTile(
                secondary: _SettingsIcon(
                  icon: Icons.dark_mode_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text(AppTexts.darkMode),
                subtitle: Text(
                  themeController.mode == ThemeMode.dark
                      ? 'Activado'
                      : 'Desactivado',
                ),
                value: themeController.mode == ThemeMode.dark,
                onChanged: themeController.setDarkMode,
              ),
              const Divider(height: 1, indent: 68),
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
                          await auth.signOut();
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
                  'Modelo: ${geminiActive ? "Gemini 1.5 Flash" : "Fallback local"}\n'
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
                  applicationVersion: '1.0',
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
                          : 'Toca para agregar tu frase motivacional',
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
