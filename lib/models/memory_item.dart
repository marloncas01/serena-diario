import 'package:flutter/material.dart';

enum MemoryCategory {
  persona,
  evento,
  meta,
  miedo,
  problema,
  logro,
  gusto,
  rutina,
  salud,
  trabajo,
  estudio,
  mascota,
  familia,
  relacion,
  otro,
}

extension MemoryCategoryExtension on MemoryCategory {
  String get label => switch (this) {
    MemoryCategory.persona => 'Persona',
    MemoryCategory.evento => 'Evento',
    MemoryCategory.meta => 'Meta',
    MemoryCategory.miedo => 'Miedo',
    MemoryCategory.problema => 'Problema',
    MemoryCategory.logro => 'Logro',
    MemoryCategory.gusto => 'Gusto',
    MemoryCategory.rutina => 'Rutina',
    MemoryCategory.salud => 'Salud',
    MemoryCategory.trabajo => 'Trabajo',
    MemoryCategory.estudio => 'Estudio',
    MemoryCategory.mascota => 'Mascota',
    MemoryCategory.familia => 'Familia',
    MemoryCategory.relacion => 'Relación',
    MemoryCategory.otro => 'Otro',
  };

  String get emoji => switch (this) {
    MemoryCategory.persona => '👤',
    MemoryCategory.evento => '📅',
    MemoryCategory.meta => '🎯',
    MemoryCategory.miedo => '😨',
    MemoryCategory.problema => '⚠️',
    MemoryCategory.logro => '🏆',
    MemoryCategory.gusto => '💚',
    MemoryCategory.rutina => '🔄',
    MemoryCategory.salud => '🏥',
    MemoryCategory.trabajo => '💼',
    MemoryCategory.estudio => '📚',
    MemoryCategory.mascota => '🐾',
    MemoryCategory.familia => '👨‍👩‍👧',
    MemoryCategory.relacion => '💕',
    MemoryCategory.otro => '📝',
  };

  Color get color => switch (this) {
    MemoryCategory.persona => const Color(0xFF5C6BC0),
    MemoryCategory.evento => const Color(0xFF42A5F5),
    MemoryCategory.meta => const Color(0xFF66BB6A),
    MemoryCategory.miedo => const Color(0xFFEF5350),
    MemoryCategory.problema => const Color(0xFFFF7043),
    MemoryCategory.logro => const Color(0xFFFFB300),
    MemoryCategory.gusto => const Color(0xFF26A69A),
    MemoryCategory.rutina => const Color(0xFF78909C),
    MemoryCategory.salud => const Color(0xFFEC407A),
    MemoryCategory.trabajo => const Color(0xFF5C6BC0),
    MemoryCategory.estudio => const Color(0xFFAB47BC),
    MemoryCategory.mascota => const Color(0xFF8D6E63),
    MemoryCategory.familia => const Color(0xFFFF8A65),
    MemoryCategory.relacion => const Color(0xFFE91E63),
    MemoryCategory.otro => const Color(0xFF90A4AE),
  };

  static MemoryCategory fromString(String value) {
    for (final cat in MemoryCategory.values) {
      if (cat.name == value) return cat;
    }
    return MemoryCategory.otro;
  }
}

class MemoryItem {
  MemoryItem({
    required this.id,
    required this.category,
    required this.value,
    required this.confidence,
    required this.createdAt,
    required this.lastMention,
    this.timesMentioned = 1,
    this.active = true,
    this.originalText = '',
    this.keywords = const [],
  });

  final String id;
  final MemoryCategory category;
  final String value;
  final double confidence;
  final DateTime createdAt;
  DateTime lastMention;
  int timesMentioned;
  bool active;
  final String originalText;
  final List<String> keywords;

  double get importance {
    final recency = _recencyScore();
    final frequency = (timesMentioned / 10).clamp(0.0, 1.0);
    return (confidence * 0.4 + frequency * 0.35 + recency * 0.25)
        .clamp(0.0, 1.0);
  }

  double _recencyScore() {
    final diff = DateTime.now().difference(lastMention).inDays;
    if (diff <= 1) return 1.0;
    if (diff <= 3) return 0.8;
    if (diff <= 7) return 0.6;
    if (diff <= 14) return 0.4;
    if (diff <= 30) return 0.2;
    return 0.1;
  }

  MemoryItem copyWith({
    String? value,
    double? confidence,
    DateTime? lastMention,
    int? timesMentioned,
    bool? active,
    List<String>? keywords,
  }) {
    return MemoryItem(
      id: id,
      category: category,
      value: value ?? this.value,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt,
      lastMention: lastMention ?? this.lastMention,
      timesMentioned: timesMentioned ?? this.timesMentioned,
      active: active ?? this.active,
      originalText: originalText,
      keywords: keywords ?? this.keywords,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category.name,
    'value': value,
    'confidence': confidence,
    'createdAt': createdAt.toIso8601String(),
    'lastMention': lastMention.toIso8601String(),
    'timesMentioned': timesMentioned,
    'active': active,
    'originalText': originalText,
    'keywords': keywords,
  };

  factory MemoryItem.fromMap(Map<dynamic, dynamic> map) => MemoryItem(
    id: map['id'] as String,
    category: MemoryCategoryExtension.fromString(map['category'] as String),
    value: map['value'] as String,
    confidence: (map['confidence'] as num).toDouble(),
    createdAt: DateTime.parse(map['createdAt'] as String),
    lastMention: DateTime.parse(map['lastMention'] as String),
    timesMentioned: map['timesMentioned'] as int? ?? 1,
    active: map['active'] as bool? ?? true,
    originalText: map['originalText'] as String? ?? '',
    keywords: (map['keywords'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
