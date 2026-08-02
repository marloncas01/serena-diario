import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/wellbeing_plan.dart';
import '../providers/objective_provider.dart';
import '../theme/brand/brand_durations.dart';
import '../theme/brand/brand_radius.dart';
import '../theme/brand/brand_spacing.dart';
import 'glass_card.dart';
import 'ui/gradient_button.dart';
import 'ui/premium_chip.dart';

const List<String> kObjectiveEmojis = [
  '🎯', '🧘', '💤', '📖', '🏃', '🧠', '💪', '🌿', '🥗', '🎨', '🗣️', '💧',
];

class ObjectivesCard extends StatelessWidget {
  const ObjectivesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final objectives =
        context.select<ObjectiveProvider, List<WellbeingObjective>>(
      (provider) => provider.objectives,
    );
    final theme = Theme.of(context);
    final activos = objectives.where((o) => o.activo).toList();
    final completados =
        objectives.where((o) => o.estado == EstadoObjetivo.completado).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_circle_rounded,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mis objetivos',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (objectives.isNotEmpty)
                Text(
                  '${completados.length}/${objectives.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (objectives.isEmpty)
            _EmptyObjectives(onCreate: () => _openDialog(context))
          else ...[
            ...activos.map((o) => _ObjectiveTile(objective: o)),
            if (completados.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...completados.map((o) => _ObjectiveTile(objective: o)),
            ],
          ],
          const SizedBox(height: 12),
          GradientButton(
            icon: Icons.add_rounded,
            label: 'Nuevo objetivo',
            height: 44,
            isExpanded: true,
            onPressed: () => _openDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openDialog(
    BuildContext context, {
    WellbeingObjective? existing,
  }) async {
    final result = await showObjectiveDialog(context, existing: existing);
    if (result == null || !context.mounted) return;
    final provider = context.read<ObjectiveProvider>();
    await provider.save(result);
  }
}

class _EmptyObjectives extends StatelessWidget {
  const _EmptyObjectives({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Define metas pequeñas y realistas para tu bienestar.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Serena ajustará el progreso con cada entrada que escribas.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _ObjectiveTile extends StatelessWidget {
  const _ObjectiveTile({required this.objective});

  final WellbeingObjective objective;

  String get _estadoLabel => switch (objective.estado) {
        EstadoObjetivo.pendiente => 'Pendiente',
        EstadoObjetivo.enProgreso => 'En progreso',
        EstadoObjetivo.completado => 'Completado',
        EstadoObjetivo.abandonado => 'Abandonado',
      };

  Color _estadoColor(BuildContext context) => switch (objective.estado) {
        EstadoObjetivo.pendiente =>
          Theme.of(context).colorScheme.onSurfaceVariant,
        EstadoObjetivo.enProgreso => Theme.of(context).colorScheme.primary,
        EstadoObjetivo.completado => Colors.green,
        EstadoObjetivo.abandonado => Theme.of(context).colorScheme.error,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = objective.progresoClamp;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(BrandRadius.md),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(objective.icono,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        objective.titulo,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        objective.descripcion,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_ObjectiveAction>(
                  tooltip: 'Opciones del objetivo',
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (action) => _handleAction(context, action),
                  itemBuilder: (context) => [
                    if (objective.activo)
                      const PopupMenuItem(
                        value: _ObjectiveAction.complete,
                        child: Text('Marcar como completado'),
                      )
                    else if (objective.estado == EstadoObjetivo.completado)
                      const PopupMenuItem(
                        value: _ObjectiveAction.reopen,
                        child: Text('Reabrir'),
                      ),
                    if (objective.activo)
                      const PopupMenuItem(
                        value: _ObjectiveAction.abandon,
                        child: Text('Abandonar'),
                      ),
                    const PopupMenuItem(
                      value: _ObjectiveAction.edit,
                      child: Text('Editar'),
                    ),
                    const PopupMenuItem(
                      value: _ObjectiveAction.delete,
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(BrandRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  objective.estado == EstadoObjetivo.completado
                      ? Colors.green
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _estadoLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _estadoColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _ObjectiveAction action,
  ) async {
    final provider = context.read<ObjectiveProvider>();
    switch (action) {
      case _ObjectiveAction.complete:
        await provider.setEstado(objective.id, EstadoObjetivo.completado);
      case _ObjectiveAction.reopen:
        await provider.setEstado(objective.id, EstadoObjetivo.enProgreso);
      case _ObjectiveAction.abandon:
        await provider.setEstado(objective.id, EstadoObjetivo.abandonado);
      case _ObjectiveAction.edit:
        await showObjectiveDialog(context, existing: objective).then((result) {
          if (result != null) provider.save(result);
        });
      case _ObjectiveAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Eliminar este objetivo?'),
            content: const Text('Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await provider.remove(objective.id);
        }
    }
  }
}

enum _ObjectiveAction { complete, reopen, abandon, edit, delete }

Future<WellbeingObjective?> showObjectiveDialog(
  BuildContext context, {
  WellbeingObjective? existing,
}) {
  return showDialog<WellbeingObjective>(
    context: context,
    builder: (_) => _ObjectiveDialog(existing: existing),
  );
}

class _ObjectiveDialog extends StatefulWidget {
  const _ObjectiveDialog({this.existing});

  final WellbeingObjective? existing;

  @override
  State<_ObjectiveDialog> createState() => _ObjectiveDialogState();
}

class _ObjectiveDialogState extends State<_ObjectiveDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descripcion;
  late final TextEditingController _motivo;
  late String _icono;
  late DificultadObjetivo _dificultad;
  late DuracionObjetivo _duracion;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titulo = TextEditingController(text: existing?.titulo ?? '');
    _descripcion = TextEditingController(text: existing?.descripcion ?? '');
    _motivo = TextEditingController(text: existing?.motivo ?? '');
    _icono = existing?.icono ?? kObjectiveEmojis.first;
    _dificultad = existing?.dificultad ?? DificultadObjetivo.media;
    _duracion = existing?.duracion ?? DuracionObjetivo.unaSemana;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BrandRadius.dialog,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BrandSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Editar objetivo' : 'Nuevo objetivo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Metas pequeñas y amables contigo.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                Text('Icono', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kObjectiveEmojis
                      .map(
                        (emoji) => GestureDetector(
                          onTap: () => setState(() => _icono = emoji),
                          child: AnimatedContainer(
                            duration: BrandDurations.fast,
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _icono == emoji
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _icono == emoji
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                                width: _icono == emoji ? 1.5 : 1,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titulo,
                  autofocus: !_isEditing,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ej. Meditar 10 minutos',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Escribe un título breve'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcion,
                  maxLines: 2,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _motivo,
                  maxLines: 2,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: '¿Por qué te importa? (opcional)',
                  ),
                ),
                const SizedBox(height: 8),

                Text('Dificultad', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: DificultadObjetivo.values.map((value) {
                    return PremiumChip(
                      label: _labelForDificultad(value),
                      isSelected: _dificultad == value,
                      onTap: () => setState(() => _dificultad = value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text('Duración', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: DuracionObjetivo.values.map((value) {
                    return PremiumChip(
                      label: _labelForDuracion(value),
                      isSelected: _duracion == value,
                      onTap: () => setState(() => _duracion = value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                GradientButton(
                  label: _isEditing ? 'Guardar cambios' : 'Crear objetivo',
                  icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _labelForDificultad(DificultadObjetivo value) => switch (value) {
        DificultadObjetivo.facil => 'Fácil',
        DificultadObjetivo.media => 'Media',
        DificultadObjetivo.dificil => 'Difícil',
      };

  String _labelForDuracion(DuracionObjetivo value) => switch (value) {
        DuracionObjetivo.unDia => '1 día',
        DuracionObjetivo.unaSemana => '1 semana',
        DuracionObjetivo.dosSemanas => '2 semanas',
        DuracionObjetivo.unMes => '1 mes',
      };

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final objective = WellbeingObjective(
      id: widget.existing?.id ?? now.microsecondsSinceEpoch.toString(),
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      motivo: _motivo.text.trim(),
      dificultad: _dificultad,
      duracion: _duracion,
      estado: widget.existing?.estado ?? EstadoObjetivo.pendiente,
      fechaInicio: widget.existing?.fechaInicio ?? now,
      icono: _icono,
      fechaFin: widget.existing?.fechaFin,
      progreso: widget.existing?.progreso ?? 0.0,
    );
    Navigator.pop(context, objective);
  }
}
