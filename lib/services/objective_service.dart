import 'package:hive_flutter/hive_flutter.dart';

import '../models/wellbeing_plan.dart';

/// Persistencia de objetivos personales en Hive.
///
/// Cada objetivo se guarda en una caja propia (`wellbeing_objectives`), lo que
/// permite que sobrevivan a reinicios y se sincronicen con el progreso de
/// escritura sin depender de archivos locales por plataforma.
class ObjectiveService {
  ObjectiveService._();

  static final ObjectiveService _instance = ObjectiveService._();
  factory ObjectiveService() => _instance;

  static const String boxName = 'wellbeing_objectives';

  late Box<Map> _box;
  bool _isReady = false;

  Future<void> _ensureBox() async {
    if (_isReady) return;
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<Map>(boxName);
    } else {
      _box = Hive.box<Map>(boxName);
    }
    _isReady = true;
  }

  Future<List<WellbeingObjective>> getAll() async {
    await _ensureBox();
    final objectives = _box.values
        .map((value) => WellbeingObjective.fromMap(
              Map<String, dynamic>.from(value),
            ))
        .toList(growable: false);
    objectives.sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));
    return objectives;
  }

  Future<List<WellbeingObjective>> getActivos() async {
    final all = await getAll();
    return all.where((o) => o.activo).toList(growable: false);
  }

  Future<void> save(WellbeingObjective objective) async {
    await _ensureBox();
    await _box.put(objective.id, objective.toMap());
  }

  Future<void> delete(String id) async {
    await _ensureBox();
    await _box.delete(id);
  }

  Future<void> update(
    WellbeingObjective objective, {
    EstadoObjetivo? estado,
    double? progreso,
    DateTime? fechaFin,
  }) async {
    await _ensureBox();
    final stored = WellbeingObjective.fromMap(
      Map<String, dynamic>.from(_box.get(objective.id) ?? {}),
    );
    final updated = WellbeingObjective(
      id: stored.id,
      titulo: stored.titulo,
      descripcion: stored.descripcion,
      motivo: stored.motivo,
      dificultad: stored.dificultad,
      duracion: stored.duracion,
      estado: estado ?? stored.estado,
      fechaInicio: stored.fechaInicio,
      icono: stored.icono,
      fechaFin: fechaFin ?? stored.fechaFin,
      progreso: progreso ?? stored.progreso,
    );
    await _box.put(updated.id, updated.toMap());
  }
}
