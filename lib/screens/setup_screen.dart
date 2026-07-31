import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_preferences.dart';
import '../services/user_profile.dart';
import '../theme/brand/brand_durations.dart';
import 'app_shell.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _controller = PageController();
  var _page = 0;

  final _nameController = TextEditingController();
  var _selectedAvatar = '🙂';
  var _selectedColor = AppThemeColor.morado;
  var _goal = '';
  var _selectedPersonality = SerenaPersonality.amigable;

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final profile = context.read<UserProfile>();
    await profile.setUserName(_nameController.text.trim());
    await profile.setAvatar(_selectedAvatar);
    await profile.setThemeColor(_selectedColor);
    await profile.setGoal(_goal.trim());
    await profile.setPersonality(_selectedPersonality);
    await AppPreferences().completeSetup();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        leading: _page > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Atrás',
                onPressed: () => _controller.previousPage(
                  duration: BrandDurations.normal,
                  curve: Curves.easeOutCubic,
                ),
              )
            : null,
        title: LinearProgressIndicator(
          value: (_page + 1) / 4,
          minHeight: 4,
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _controller,
          onPageChanged: (v) => setState(() => _page = v),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildNamePage(theme, screenHeight),
            _buildAvatarColorPage(theme, screenHeight),
            _buildGoalPage(theme, screenHeight),
            _buildPersonalityPage(theme, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage(ThemeData theme, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 40,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Cómo te llamas?',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Así podré saludarte cada vez que abras tu diario.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Tu nombre',
              prefixIcon: Icon(Icons.edit_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nameController.text.trim().isEmpty
                  ? null
                  : () => _controller.nextPage(
                      duration: BrandDurations.normal,
                      curve: Curves.easeOutCubic,
                    ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('Continuar'),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildAvatarColorPage(ThemeData theme, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Elige tu avatar',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: availableAvatars.map((a) {
              final selected = _selectedAvatar == a;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = a),
                child: AnimatedContainer(
                  duration: BrandDurations.fast,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: selected
                        ? Border.all(
                            color: theme.colorScheme.primary, width: 2.5)
                        : null,
                  ),
                  child: Center(child: Text(a, style: const TextStyle(fontSize: 28))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'Color del tema',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: AppThemeColor.values.map((c) {
              final selected = _selectedColor == c;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: AnimatedContainer(
                  duration: BrandDurations.fast,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: theme.colorScheme.onSurface, width: 3)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _controller.nextPage(
                duration: BrandDurations.normal,
                curve: Curves.easeOutCubic,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('Continuar'),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildGoalPage(ThemeData theme, double screenHeight) {
    const goals = [
      'Escribir con más frecuencia',
      'Entender mis emociones',
      'Reducir el estrés',
      'Ser más agradecido',
      'Solo quiero escribir',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_outlined,
              size: 40,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Qué te gustaría lograr?',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...goals.map((g) {
                  final selected = _goal == g;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _goal = g),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected
                              ? theme.colorScheme.primaryContainer
                              : null,
                          foregroundColor: selected
                              ? theme.colorScheme.onPrimaryContainer
                              : null,
                          side: BorderSide(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(g,
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _controller.nextPage(
                duration: BrandDurations.normal,
                curve: Curves.easeOutCubic,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('Continuar'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPersonalityPage(ThemeData theme, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 40,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Personalidad de Serena',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Elige cómo prefieres que te hable.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...SerenaPersonality.values.map((p) {
                  final selected = _selectedPersonality == p;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _selectedPersonality = p),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected
                              ? theme.colorScheme.primaryContainer
                              : null,
                          foregroundColor: selected
                              ? theme.colorScheme.onPrimaryContainer
                              : null,
                          side: BorderSide(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(p.label,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(p.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: selected
                                      ? theme.colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.7)
                                      : theme.colorScheme.onSurfaceVariant,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _finish,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('¡Comenzar!'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
