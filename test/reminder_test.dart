import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:serena_diario/models/reminder.dart';
import 'package:serena_diario/services/reminder_notifications.dart';
import 'package:serena_diario/services/reminder_service.dart';

void main() {
  setUpAll(() {
    Hive.init(Directory.systemTemp.createTempSync('reminders_test').path);
  });

  setUp(() async {
    if (Hive.isBoxOpen(ReminderService.boxName)) {
      await Hive.box<Map>(ReminderService.boxName).clear();
    }
  });

  Reminder reminder(String id, {List<int> days = const [1, 2, 3, 4, 5]}) =>
      Reminder(
        id: id,
        title: 'Momento para ti',
        message: 'Tómate 5 minutos.',
        hour: 20,
        minute: 30,
        days: days,
        createdAt: DateTime(2026, 8, 2, 10),
      );

  group('Reminder model', () {
    test('toMap/fromMap conservan todos los campos', () {
      final original = reminder('r1', days: const [6, 7]);
      final restored = Reminder.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.message, original.message);
      expect(restored.hour, 20);
      expect(restored.minute, 30);
      expect(restored.days, [6, 7]);
      expect(restored.enabled, isTrue);
      expect(restored.createdAt, original.createdAt);
    });

    test('timeLabel formatea la hora en 24h', () {
      final r = reminder('r2', days: const [1]);
      expect(r.timeLabel, '20:30');
      expect(r.copyWith(hour: 8, minute: 5).timeLabel, '08:05');
    });

    test('copyWith solo cambia lo indicado', () {
      final r = reminder('r3');
      final updated = r.copyWith(enabled: false, hour: 7);
      expect(updated.enabled, isFalse);
      expect(updated.hour, 7);
      expect(updated.minute, r.minute);
      expect(updated.title, r.title);
      expect(updated.id, r.id);
    });
  });

  group('ReminderService', () {
    test('guarda, lee ordenado y elimina', () async {
      final service = ReminderService();
      await service.save(reminder('a'));
      await service.save(reminder('b', days: const [1]));

      final all = await service.getAll();
      expect(all, hasLength(2));

      await service.delete('a');
      expect(await service.getAll(), hasLength(1));
      expect((await service.getAll()).first.id, 'b');
    });
  });

  group('ReminderNotifications', () {
    test('nextOccurrence resuelve hoy si la hora aún no pasó', () {
      final now = DateTime(2026, 8, 3, 10, 0);
      final next = ReminderNotifications.nextOccurrence(
        now: now,
        hour: 11,
        minute: 0,
        weekday: 1,
      );
      expect(next, DateTime(2026, 8, 3, 11, 0));
    });

    test('nextOccurrence salta al día siguiente si la hora ya pasó', () {
      final now = DateTime(2026, 8, 3, 10, 0);
      final next = ReminderNotifications.nextOccurrence(
        now: now,
        hour: 9,
        minute: 0,
        weekday: 1,
      );
      expect(next, DateTime(2026, 8, 10, 9, 0));
    });

    test('nextOccurrence avanza hasta el día de la semana pedido', () {
      final now = DateTime(2026, 8, 3, 10, 0); // lunes
      final next = ReminderNotifications.nextOccurrence(
        now: now,
        hour: 8,
        minute: 0,
        weekday: 7, // domingo
      );
      expect(next, DateTime(2026, 8, 9, 8, 0));
    });

    test('notificationIdFor es estable por recordatorio y día', () {
      final notifications = ReminderNotifications();
      final r = reminder('abc');
      final monday = notifications.notificationIdFor(r, 1);
      final sunday = notifications.notificationIdFor(r, 7);
      expect(monday, notifications.notificationIdFor(r, 1));
      expect(monday, isNot(sunday));

      final other = notifications.notificationIdFor(reminder('xyz'), 1);
      expect(monday, isNot(other));
    });
  });
}
