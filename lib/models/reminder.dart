/// Modelo inmutable de un recordatorio diario de Serena.
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.message,
    required this.hour,
    required this.minute,
    required this.days,
    this.enabled = true,
    required this.createdAt,
  });

  final String id;

  /// Texto corto que identifica el recordatorio.
  final String title;

  /// Mensaje que acompaña la notificación.
  final String message;

  /// Hora (0-23) a la que debe sonar el recordatorio.
  final int hour;

  /// Minuto (0-59) a la que debe sonar el recordatorio.
  final int minute;

  /// Días de la semana activos (1 = lunes ... 7 = domingo).
  final List<int> days;

  final bool enabled;
  final DateTime createdAt;

  Reminder copyWith({
    String? title,
    String? message,
    int? hour,
    int? minute,
    List<int>? days,
    bool? enabled,
  }) =>
      Reminder(
        id: id,
        title: title ?? this.title,
        message: message ?? this.message,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        days: days ?? this.days,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'hour': hour,
        'minute': minute,
        'days': days,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Reminder.fromMap(Map<dynamic, dynamic> map) => Reminder(
        id: map['id'] as String,
        title: map['title'] as String,
        message: map['message'] as String? ?? '',
        hour: (map['hour'] as num).toInt(),
        minute: (map['minute'] as num).toInt(),
        days: (map['days'] as List<dynamic>? ?? const [])
            .whereType<num>()
            .map((d) => d.toInt())
            .toList(growable: false),
        enabled: map['enabled'] as bool? ?? true,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  /// Etiqueta corta de la hora en formato 24h, p. ej. `08:30`.
  String get timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
