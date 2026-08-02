import 'package:flutter/foundation.dart';

import '../models/journal_entry.dart';
import '../models/wellbeing_plan.dart';
import '../services/objective_service.dart';

/// Estado observable de los objetivos personales.
///
/// Calcula el progreso de cada objetivo a partir de los días con escritura
/// desde su fecha de inicio, y lo persiste vía [ObjectiveService].
class ObjectiveProvider extends ChangeNotifier {
  ObjectiveProvider(this._service);

  final ObjectiveService _service;
  List<WellbeingObjective> _objectives = [];

  List<WellbeingObjective> get objectives => List.unmodifiable(_objectives);

  List<WellbeingObjective> get activos =>
      _objectives.where((o) => o.activo).toList(growable: false);

  int get completados => _objectives
      .where((o) => o.estado == EstadoObjetivo.completado)
      .length;

  Future<void> initialize() async {
    _objectives = await _service.getAll();
    notifyListeners();
  }

  Future<void> refresh() async {
    _objectives = await _service.getAll();
    notifyListeners();
  }

  Future<void> save(WellbeingObjective objective) async {
    await _service.save(objective);
    await refresh();
  }

  Future<void> remove(String id) async {
    await _service.delete(id);
    await refresh();
  }

  Future<void> setEstado(String id, EstadoObjetivo estado) async {
    final objective = _objectives.firstWhere((o) => o.id == id);
    await _service.update(
      objective,
      estado: estado,
      fechaFin: estado == EstadoObjetivo.completado ? DateTime.now() : null,
    );
    await refresh();
  }

  /// Actualiza el progreso de los objetivos activos según los días con
  /// escritura registrados. Devuelve los ids recién completados.
  Future<List<String>> computeProgress(List<JournalEntry> entries) async {
    if (_objectives.isEmpty) return const [];

    final today = DateTime.now();
    final days = entries
        .map(
          (entry) => DateTime(
            entry.createdAt.year,
            entry.createdAt.month,
            entry.createdAt.day,
          ),
        )
        .toSet();

    final completed = <String>[];
    var changed = false;

    for (final objective in _objectives) {
      if (!objective.activo) continue;

      final totalDays = objective.duracionEstimada.inDays.clamp(1, 365);
      final startDay = DateTime(
        objective.fechaInicio.year,
        objective.fechaInicio.month,
        objective.fechaInicio.day,
      );
      final daysWithEntries =
          days.where((day) => !day.isBefore(startDay)).length;
      final progress = (daysWithEntries / totalDays).clamp(0.0, 1.0);

      final newState = progress >= 1.0
          ? EstadoObjetivo.completado
          : daysWithEntries > 0
              ? EstadoObjetivo.enProgreso
              : objective.estado;

      if (newState == EstadoObjetivo.completado &&
          objective.estado != EstadoObjetivo.completado) {
        completed.add(objective.id);
        changed = true;
      }

      if (objective.progreso != progress || objective.estado != newState) {
        await _service.update(
          objective,
          estado: newState,
          progreso: progress.toDouble(),
          fechaFin: newState == EstadoObjetivo.completado ? today : null,
        );
        changed = true;
      }
    }

    if (changed) await refresh();
    return completed;
  }
}
