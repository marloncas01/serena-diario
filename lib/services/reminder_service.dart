import 'package:hive_flutter/hive_flutter.dart';

import '../models/reminder.dart';

/// Persistencia de recordatorios en Hive.
///
/// Cada recordatorio se guarda en la caja `reminders`, lo que les permite
/// sobrevivir a reinicios sin depender de servicios externos.
class ReminderService {
  ReminderService._();

  static final ReminderService _instance = ReminderService._();

  factory ReminderService() => _instance;

  static const String boxName = 'reminders';

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

  Future<List<Reminder>> getAll() async {
    await _ensureBox();
    final reminders = _box.values
        .map((value) => Reminder.fromMap(Map<String, dynamic>.from(value)))
        .toList(growable: false);
    reminders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reminders;
  }

  Future<void> save(Reminder reminder) async {
    await _ensureBox();
    await _box.put(reminder.id, reminder.toMap());
  }

  Future<void> delete(String id) async {
    await _ensureBox();
    await _box.delete(id);
  }
}
