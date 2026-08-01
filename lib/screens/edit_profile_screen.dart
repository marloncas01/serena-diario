import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../services/theme_controller.dart';
import '../services/user_profile.dart';
import '../theme/brand/brand_durations.dart';
import '../utils/app_feedback.dart';
import '../widgets/glass_card.dart';

/// Pantalla "Editar perfil": nombre, avatar y color principal con
/// previsualización en tiempo real. Todos los cambios se aplican al instante.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<UserProfile>().userName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    HapticFeedback.lightImpact();
    setState(() => _isSaving = true);
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await context.read<UserProfile>().setUserName(name);
    }
    if (!mounted) return;
    AppFeedback.success(context, 'Perfil actualizado');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfile>();
    final theme = context.watch<ThemeController>();
    final appTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Guardar'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            _buildPreview(appTheme, profile, theme),
            const SizedBox(height: 24),
            _buildNameSection(appTheme),
            const SizedBox(height: 24),
            _buildAvatarSection(appTheme, profile),
            const SizedBox(height: 24),
            _buildColorSection(appTheme, theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(
    ThemeData theme,
    UserProfile profile,
    ThemeController controller,
  ) {
    final name = _nameController.text.trim();
    return AnimatedContainer(
      duration: BrandDurations.slow,
      curve: BrandDurations.standard,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            controller.themeStyle.seedColor,
            Color.lerp(
              controller.themeStyle.seedColor,
              Colors.white,
              theme.brightness == Brightness.dark ? 0.25 : 0.6,
            )!,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: controller.themeStyle.seedColor.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: BrandDurations.normal,
            curve: Curves.easeOutBack,
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: BrandDurations.normal,
                child: Text(
                  profile.avatar,
                  key: ValueKey(profile.avatar),
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: BrandDurations.normal,
                  child: Text(
                    name.isNotEmpty ? name : 'Tu nombre',
                    key: ValueKey(name.isEmpty ? 'empty' : name),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    controller.themeStyle.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(theme, icon: Icons.person_outline_rounded, title: 'Nombre'),
        const SizedBox(height: 8),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: '¿Cómo te llamas?',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(ThemeData theme, UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(theme, icon: Icons.face_rounded, title: 'Avatar'),
        const SizedBox(height: 8),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: avatarCategories.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((emoji) {
                        final selected = profile.avatar == emoji;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            profile.setAvatar(emoji);
                          },
                          child: AnimatedContainer(
                            duration: BrandDurations.fast,
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: selected
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: selected
                                  ? Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(emoji, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSection(ThemeData theme, ThemeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          theme,
          icon: Icons.palette_outlined,
          title: 'Color principal',
        ),
        const SizedBox(height: 8),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: SerenaThemeStyle.values.map((style) {
                  final selected = controller.themeStyle == style;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.setThemeStyle(style);
                    },
                    child: AnimatedContainer(
                      duration: BrandDurations.fast,
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: style.seedColor,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: style.seedColor.withValues(alpha: 0.45),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 22)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Tema actual: ${controller.themeStyle.label}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.theme, {required this.icon, required this.title});

  final ThemeData theme;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
