/// Immutable domain model for a private Serena journal entry.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.mood,
    required this.note,
    this.tags = const [],
  });

  final String id;
  final DateTime createdAt;
  final String mood;
  final String note;
  final List<String> tags;

  JournalEntry copyWith({String? mood, String? note, List<String>? tags}) =>
      JournalEntry(
        id: id,
        createdAt: createdAt,
        mood: mood ?? this.mood,
        note: note ?? this.note,
        tags: tags ?? this.tags,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'mood': mood,
    'note': note,
    'tags': tags,
  };

  factory JournalEntry.fromMap(Map<dynamic, dynamic> map) => JournalEntry(
    id: map['id'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    mood: map['mood'] as String,
    note: map['note'] as String,
    tags: (map['tags'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
  );
}
