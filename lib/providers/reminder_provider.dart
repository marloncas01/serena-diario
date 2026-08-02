import 'package:flutter/foundation.dart';

import '../models/reminder.dart';
import '../services/reminder_notifications.dart';
import '../services/reminder_service.dart';

/// Estado observable de los recordatorios.
///
/// Mantiene la lista persistida sincronizada con las notificaciones locales:
/// cada cambio de horario, días o estado reprograma (o cancela) las alarmas.
class ReminderProvider extends ChangeNotifier {
  ReminderProvider(this._service);

  final ReminderService _service;
  final ReminderNotifications _notifications = ReminderNotifications();
  List<Reminder> _reminders = [];

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  Future<void> initialize() async {
    await _notifications.init();
    _reminders = await _service.getAll();
    notifyListeners();
  }

  Future<void> add({
    required String title,
    required String message,
    required int hour,
    required int minute,
    required List<int> days,
  }) async {
    final reminder = Reminder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      hour: hour,
      minute: minute,
      days: List<int>.of(days),
      enabled: true,
      createdAt: DateTime.now(),
    );
    final granted = await _notifications.requestPermission();
    if (!granted) return;
    await _service.save(reminder);
    await _notifications.scheduleForReminder(reminder);
    _reminders = await _service.getAll();
    notifyListeners();
  }

  Future<void> update(Reminder reminder) async {
    await _service.save(reminder);
    await _notifications.cancelForReminder(reminder);
    if (reminder.enabled && reminder.days.isNotEmpty) {
      await _notifications.scheduleForReminder(reminder);
    }
    _reminders = await _service.getAll();
    notifyListeners();
  }

  Future<void> toggle(Reminder reminder, bool enabled) async {
    final updated = reminder.copyWith(enabled: enabled);
    if (enabled) {
      final granted = await _notifications.requestPermission();
      if (!granted) return;
    }
    await update(updated);
  }

  Future<void> remove(String id) async {
    final target = _reminders.where((r) => r.id == id).firstOrNull;
    await _service.delete(id);
    if (target != null) {
      await _notifications.cancelForReminder(target);
    }
    _reminders = await _service.getAll();
    notifyListeners();
  }
}
