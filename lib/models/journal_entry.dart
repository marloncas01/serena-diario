/// Immutable domain model for a private Serena journal entry.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.mood,
    required this.note,
    this.tags = const [],
    this.dominantEmotionId,
    this.dominantEmotionName,
    this.dominantEmotionEmoji,
    this.dominantEmotionCategory,
    this.dominantEmotionIntensity,
  });

  final String id;
  final DateTime createdAt;
  final String mood;
  final String note;
  final List<String> tags;

  /// Emoción dominante detectada al guardar la entrada (puede ser null para
  /// entradas anteriores a esta funcionalidad).
  final String? dominantEmotionId;
  final String? dominantEmotionName;
  final String? dominantEmotionEmoji;

  /// Categoría de la emoción dominante: `positiva`, `negativa` o `mixta`.
  final String? dominantEmotionCategory;

  /// Intensidad normalizada de la emoción dominante entre 0.0 y 1.0.
  final double? dominantEmotionIntensity;

  JournalEntry copyWith({
    String? mood,
    String? note,
    List<String>? tags,
    String? dominantEmotionId,
    String? dominantEmotionName,
    String? dominantEmotionEmoji,
    String? dominantEmotionCategory,
    double? dominantEmotionIntensity,
    bool clearDominantEmotion = false,
  }) =>
      JournalEntry(
        id: id,
        createdAt: createdAt,
        mood: mood ?? this.mood,
        note: note ?? this.note,
        tags: tags ?? this.tags,
        dominantEmotionId: clearDominantEmotion
            ? null
            : dominantEmotionId ?? this.dominantEmotionId,
        dominantEmotionName: clearDominantEmotion
            ? null
            : dominantEmotionName ?? this.dominantEmotionName,
        dominantEmotionEmoji: clearDominantEmotion
            ? null
            : dominantEmotionEmoji ?? this.dominantEmotionEmoji,
        dominantEmotionCategory: clearDominantEmotion
            ? null
            : dominantEmotionCategory ?? this.dominantEmotionCategory,
        dominantEmotionIntensity: clearDominantEmotion
            ? null
            : dominantEmotionIntensity ?? this.dominantEmotionIntensity,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'mood': mood,
    'note': note,
    'tags': tags,
    'dominantEmotionId': dominantEmotionId,
    'dominantEmotionName': dominantEmotionName,
    'dominantEmotionEmoji': dominantEmotionEmoji,
    'dominantEmotionCategory': dominantEmotionCategory,
    'dominantEmotionIntensity': dominantEmotionIntensity,
  };

  factory JournalEntry.fromMap(Map<dynamic, dynamic> map) => JournalEntry(
    id: map['id'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    mood: map['mood'] as String,
    note: map['note'] as String,
    tags: (map['tags'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
    dominantEmotionId: map['dominantEmotionId'] as String?,
    dominantEmotionName: map['dominantEmotionName'] as String?,
    dominantEmotionEmoji: map['dominantEmotionEmoji'] as String?,
    dominantEmotionCategory: map['dominantEmotionCategory'] as String?,
    dominantEmotionIntensity:
        (map['dominantEmotionIntensity'] as num?)?.toDouble(),
  );
}
