import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:serena_diario/models/journal_entry.dart';
import 'package:serena_diario/models/wellbeing_plan.dart';
import 'package:serena_diario/providers/objective_provider.dart';
import 'package:serena_diario/services/objective_service.dart';

void main() {
  setUpAll(() {
    Hive.init(Directory.systemTemp.createTempSync('objectives_test').path);
  });

  setUp(() async {
    if (Hive.isBoxOpen(ObjectiveService.boxName)) {
      await Hive.box<Map>(ObjectiveService.boxName).clear();
    }
  });

  WellbeingObjective objective(String id, {DateTime? inicio}) =>
      WellbeingObjective(
        id: id,
        titulo: 'Escribir cada día',
        descripcion: 'Un reflejo diario',
        motivo: 'Constancia',
        dificultad: DificultadObjetivo.facil,
        duracion: DuracionObjetivo.unaSemana,
        estado: EstadoObjetivo.pendiente,
        fechaInicio: inicio ?? DateTime.now(),
      );

  JournalEntry entry(String id, DateTime date) =>
      JournalEntry(id: id, createdAt: date, mood: 'Calma', note: 'nota');

  test('ObjectiveService guarda, lee, actualiza y elimina', () async {
    final service = ObjectiveService();
    final target = objective('obj1');

    await service.save(target);
    final all = await service.getAll();
    expect(all, hasLength(1));
    expect(all.first.titulo, 'Escribir cada día');
    expect(all.first.icono, '🎯');
    expect(all.first.progreso, 0.0);

    await service.update(
      target,
      estado: EstadoObjetivo.enProgreso,
      progreso: 0.5,
    );
    final updated = (await service.getAll()).first;
    expect(updated.estado, EstadoObjetivo.enProgreso);
    expect(updated.progreso, closeTo(0.5, 0.0001));

    await service.delete('obj1');
    expect(await service.getAll(), isEmpty);
  });

  test('getActivos solo devuelve objetivos activos', () async {
    final service = ObjectiveService();
    final done = objective('done');
    await service.save(done);
    await service.update(done, estado: EstadoObjetivo.completado);
    await service.save(objective('active'));

    final activos = await service.getActivos();
    expect(activos.map((o) => o.id), contains('active'));
    expect(activos.map((o) => o.id), isNot(contains('done')));
  });

  test('computeProgress avanza por días de escritura y completa', () async {
    final today = DateTime.now();
    final provider = ObjectiveProvider(ObjectiveService());
    await provider.initialize();
    await provider.save(objective('obj2', inicio: today.subtract(const Duration(days: 6))));

    final partial = await provider.computeProgress([
      entry('a', today),
      entry('b', today.subtract(const Duration(days: 1))),
      entry('c', today.subtract(const Duration(days: 2))),
    ]);
    expect(partial, isEmpty);

    var current = provider.objectives.first;
    expect(current.progreso, closeTo(3 / 7, 0.001));
    expect(current.estado, EstadoObjetivo.enProgreso);

    final allDays = List.generate(7, (i) {
      return entry('d$i', today.subtract(Duration(days: i)));
    });
    final completed = await provider.computeProgress(allDays);
    expect(completed, contains('obj2'));

    current = provider.objectives.first;
    expect(current.progreso, 1.0);
    expect(current.estado, EstadoObjetivo.completado);
    expect(provider.completados, 1);
    expect(provider.activos, isEmpty);
  });

  test('los objetivos completados no vuelven a computarse', () async {
    final provider = ObjectiveProvider(ObjectiveService());
    await provider.initialize();
    await provider.save(objective('obj3'));
    await provider.setEstado('obj3', EstadoObjetivo.completado);

    final today = DateTime.now();
    final result = await provider.computeProgress([
      entry('x', today),
      entry('y', today.subtract(const Duration(days: 1))),
    ]);
    expect(result, isEmpty);
    expect(provider.objectives.first.estado, EstadoObjetivo.completado);
  });
}
