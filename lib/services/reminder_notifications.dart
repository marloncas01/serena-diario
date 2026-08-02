import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';

/// Encapsula el plugin de notificaciones locales y la programación de los
/// recordatorios diarios de Serena. Todo el trabajo de zona horaria vive aquí
/// para que el resto de la app solo trabaje con horas locales.
class ReminderNotifications {
  ReminderNotifications._();

  static final ReminderNotifications _instance = ReminderNotifications._();

  factory ReminderNotifications() => _instance;

  static const String _channelId = 'serena_reminders';
  static const String _channelName = 'Recordatorios de Serena';
  static const String _channelDescription =
      'Recordatorios diarios para escribir en tu diario.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _timezoneInitialized = false;

  Future<void> init() async {
    if (!_timezoneInitialized) {
      await _configureLocalTimezone();
      _timezoneInitialized = true;
    }
    if (_initialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  /// Configura la zona horaria local del dispositivo para que los recordatorios
  /// se disparen a la hora local correcta incluso tras reinicios.
  Future<void> _configureLocalTimezone() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(info.identifier);
      tz.setLocalLocation(location);
    } catch (_) {
      // Si no se puede resolver la zona, se mantiene la UTC por defecto y los
      // recordatorios se programan igualmente con la hora local absoluta.
    }
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return true;
      final granted = await android.requestNotificationsPermission();
      if (granted ?? false) return true;
      return await android.requestExactAlarmsPermission() ?? false;
    }
    return true;
  }

  Future<void> scheduleForReminder(Reminder reminder) async {
    for (final weekday in reminder.days) {
      await scheduleDaily(
        id: notificationIdFor(reminder, weekday),
        title: reminder.title,
        body: reminder.message,
        hour: reminder.hour,
        minute: reminder.minute,
        weekday: weekday,
      );
    }
  }

  Future<void> cancelForReminder(Reminder reminder) async {
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(id: notificationIdFor(reminder, weekday));
    }
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int weekday,
  }) async {
    final next = nextOccurrence(
      now: DateTime.now(),
      hour: hour,
      minute: minute,
      weekday: weekday,
    );
    final scheduled = tz.TZDateTime.from(next, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Calcula la próxima fecha local en que debe dispararse un recordatorio
  /// (día de la semana y hora dadas), siempre posterior al momento actual.
  static DateTime nextOccurrence({
    required DateTime now,
    required int hour,
    required int minute,
    required int weekday,
  }) {
    var candidate = DateTime(now.year, now.month, now.day, hour, minute);
    while (candidate.weekday != weekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  /// Id de notificación estable por recordatorio y día de la semana. Se deriva
  /// del id persistido para que al cancelar o reprogramar siempre apunten a la
  /// misma notificación.
  int notificationIdFor(Reminder reminder, int weekday) {
    final base = reminder.id.hashCode & 0x3ffff;
    return base * 8 + weekday;
  }
}
