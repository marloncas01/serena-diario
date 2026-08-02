import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../models/reminder.dart';
import '../providers/reminder_provider.dart';
import '../theme/brand/brand_durations.dart';

import '../theme/brand/brand_radius.dart';
import '../theme/brand/brand_spacing.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';

/// Pantalla de gestión de recordatorios diarios.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  Future<void> _addReminder() async {
    final result = await _showReminderForm(context);
    if (result == null || !mounted) return;
    final provider = context.read<ReminderProvider>();
    await provider.add(
      title: result.title,
      message: result.message,
      hour: result.hour,
      minute: result.minute,
      days: result.days,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Recordatorio programado. 🌿'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _editReminder(Reminder reminder) async {
    final result = await _showReminderForm(context, existing: reminder);
    if (result == null || !mounted) return;
    final updated = reminder.copyWith(
      title: result.title,
      message: result.message,
      hour: result.hour,
      minute: result.minute,
      days: result.days,
    );
    await context.read<ReminderProvider>().update(updated);
  }

  @override
  Widget build(BuildContext context) {
    final reminders = context.select<ReminderProvider, List<Reminder>>(
      (provider) => provider.reminders,
    );
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > AppBreakpoints.compact;
    final padding = isWide ? 32.0 : 16.0;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(padding, 8, padding, 110),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Volver',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Recordatorios',
                    style: theme.textTheme.displaySmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pequeños avisos para escribir y cuidarte.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: BrandSpacing.lg),

          FilledButton.icon(
            onPressed: _addReminder,
            icon: const Icon(Icons.add_alarm_rounded),
            label: const Text('Nuevo recordatorio'),
          ),
          const SizedBox(height: BrandSpacing.lg),

          if (reminders.isEmpty)
            const EmptyState(
              icon: Icons.alarm_add_outlined,
              title: 'Aún no tienes recordatorios',
              message:
                  'Crea uno para que Serena te avise a la hora que elijas.',
            )
          else
            ...reminders.map(
              (reminder) => Padding(
                padding: const EdgeInsets.only(bottom: BrandSpacing.md),
                child: _ReminderCard(
                  reminder: reminder,
                  onToggle: (value) => context
                      .read<ReminderProvider>()
                      .toggle(reminder, value),
                  onEdit: () => _editReminder(reminder),
                  onDelete: () =>
                      context.read<ReminderProvider>().remove(reminder.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Devuelve los datos del recordatorio creado/editado o null si se cancela.
Future<_ReminderFormResult?> _showReminderForm(
  BuildContext context, {
  Reminder? existing,
}) {
  return showModalBottomSheet<_ReminderFormResult>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _ReminderFormSheet(
      existing: existing,
      initialTime: existing != null
          ? TimeOfDay(hour: existing.hour, minute: existing.minute)
          : const TimeOfDay(hour: 20, minute: 30),
      initialDays: existing?.days ?? const [1, 2, 3, 4, 5],
      initialTitle: existing?.title ?? '',
      initialMessage: existing?.message ?? '',
    ),
  );
}

class _ReminderFormResult {
  const _ReminderFormResult({
    required this.title,
    required this.message,
    required this.hour,
    required this.minute,
    required this.days,
  });

  final String title;
  final String message;
  final int hour;
  final int minute;
  final List<int> days;
}

class _ReminderFormSheet extends StatefulWidget {
  const _ReminderFormSheet({
    this.existing,
    required this.initialTime,
    required this.initialDays,
    required this.initialTitle,
    required this.initialMessage,
  });

  final Reminder? existing;
  final TimeOfDay initialTime;
  final List<int> initialDays;
  final String initialTitle;
  final String initialMessage;

  @override
  State<_ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<_ReminderFormSheet> {
  static const List<String> _dayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  late TimeOfDay _time;
  late final Set<int> _days;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _messageController = TextEditingController(text: widget.initialMessage);
    _time = widget.initialTime;
    _days = Set<int>.of(widget.initialDays);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _confirm() {
    final title = _titleController.text.trim();
    if (title.isEmpty || _days.isEmpty) return;
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(
      _ReminderFormResult(
        title: title,
        message: _messageController.text.trim(),
        hour: _time.hour,
        minute: _time.minute,
        days: _days.toList()..sort(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        BrandSpacing.base,
        BrandSpacing.base,
        BrandSpacing.base,
        MediaQuery.viewInsetsOf(context).bottom + BrandSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: BrandSpacing.lg),
            Text(
              isEditing ? 'Editar recordatorio' : 'Nuevo recordatorio',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: BrandSpacing.md),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.edit_note_rounded),
                labelText: 'Título',
                hintText: 'Ej: Momento para ti',
              ),
            ),
            const SizedBox(height: BrandSpacing.md),
            TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.message_outlined),
                labelText: 'Mensaje',
                hintText: 'Ej: Tómate 5 minutos para escribir.',
              ),
            ),
            const SizedBox(height: BrandSpacing.md),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(BrandRadius.md),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.access_time_rounded),
                  labelText: 'Hora',
                ),
                child: Text(
                  _time.format(context),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: BrandSpacing.md),
            Text(
              'Días de la semana',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: BrandSpacing.sm),
            Row(
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final selected = _days.contains(weekday);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: FilterChip(
                      label: Center(
                        child: Text(_dayLetters[index]),
                      ),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                        color: selected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _days.add(weekday);
                          } else {
                            _days.remove(weekday);
                          }
                        });
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: BrandSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check_rounded),
                label: Text(isEditing ? 'Guardar cambios' : 'Programar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  static const List<String> _dayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.4,
    );

    return GlassCard(
      padding: EdgeInsets.zero,
      child: AnimatedOpacity(
        duration: BrandDurations.normal,
        opacity: reminder.enabled ? 1 : 0.6,
        child: Padding(
          padding: const EdgeInsets.all(BrandSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          activeColor.withValues(alpha: 0.7),
                          activeColor.withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(BrandRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      reminder.timeLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: BrandSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (reminder.message.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            reminder.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Switch(
                    value: reminder.enabled,
                    onChanged: onToggle,
                    activeThumbColor: activeColor,
                  ),
                ],
              ),
              const SizedBox(height: BrandSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(7, (index) {
                        final active = reminder.days.contains(index + 1);
                        return Expanded(
                          child: Center(
                            child: Text(
                              _dayLetters[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: active ? activeColor : inactiveColor,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: BrandSpacing.sm),
                  IconButton(
                    tooltip: 'Editar',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: theme.colorScheme.error.withValues(alpha: 0.8),
                    ),
                    onPressed: () async {
                      final ok = await confirmReminderDelete(context, reminder);
                      if (ok) onDelete();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmReminderDelete(BuildContext context, Reminder reminder) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar recordatorio'),
      content: Text(
        '¿Eliminar "${reminder.title}"? Ya no recibirás este aviso.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
