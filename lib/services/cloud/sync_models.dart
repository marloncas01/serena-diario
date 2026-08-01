import 'dart:convert';

/// Represents a journal entry for cloud synchronization.
class SyncEntry {
  const SyncEntry({
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'mood': mood,
    'note': note,
    'tags': tags,
  };

  factory SyncEntry.fromMap(Map<String, dynamic> map) => SyncEntry(
    id: map['id'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    mood: map['mood'] as String,
    note: map['note'] as String,
    tags: (map['tags'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
  );

  String toJson() => jsonEncode(toMap());

  factory SyncEntry.fromJson(String source) =>
      SyncEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Represents a user memory for cloud synchronization.
class SyncMemory {
  const SyncMemory({
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
  final String category;
  final String value;
  final double confidence;
  final DateTime createdAt;
  final DateTime lastMention;
  final int timesMentioned;
  final bool active;
  final String originalText;
  final List<String> keywords;

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'value': value,
    'confidence': confidence,
    'createdAt': createdAt.toIso8601String(),
    'lastMention': lastMention.toIso8601String(),
    'timesMentioned': timesMentioned,
    'active': active,
    'originalText': originalText,
    'keywords': keywords,
  };

  factory SyncMemory.fromMap(Map<String, dynamic> map) => SyncMemory(
    id: map['id'] as String,
    category: map['category'] as String,
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

  String toJson() => jsonEncode(toMap());

  factory SyncMemory.fromJson(String source) =>
      SyncMemory.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Represents aggregated statistics for cloud synchronization.
class SyncStats {
  const SyncStats({
    required this.totalEntries,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalWords,
    required this.moodDistribution,
    this.lastCalculated,
  });

  final int totalEntries;
  final int currentStreak;
  final int longestStreak;
  final int totalWords;
  final Map<String, int> moodDistribution;
  final DateTime? lastCalculated;

  Map<String, dynamic> toMap() => {
    'totalEntries': totalEntries,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalWords': totalWords,
    'moodDistribution': moodDistribution,
    if (lastCalculated != null) 'lastCalculated': lastCalculated!.toIso8601String(),
  };

  factory SyncStats.fromMap(Map<String, dynamic> map) => SyncStats(
    totalEntries: map['totalEntries'] as int? ?? 0,
    currentStreak: map['currentStreak'] as int? ?? 0,
    longestStreak: map['longestStreak'] as int? ?? 0,
    totalWords: map['totalWords'] as int? ?? 0,
    moodDistribution: (map['moodDistribution'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v as int)),
    lastCalculated: map['lastCalculated'] != null
        ? DateTime.parse(map['lastCalculated'] as String)
        : null,
  );

  String toJson() => jsonEncode(toMap());

  factory SyncStats.fromJson(String source) =>
      SyncStats.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Represents a user goal for cloud synchronization.
class SyncGoal {
  const SyncGoal({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.targetDate,
    this.completed = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? targetDate;
  final bool completed;
  final DateTime? completedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    if (targetDate != null) 'targetDate': targetDate!.toIso8601String(),
    'completed': completed,
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
  };

  factory SyncGoal.fromMap(Map<String, dynamic> map) => SyncGoal(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String? ?? '',
    createdAt: DateTime.parse(map['createdAt'] as String),
    targetDate: map['targetDate'] != null
        ? DateTime.parse(map['targetDate'] as String)
        : null,
    completed: map['completed'] as bool? ?? false,
    completedAt: map['completedAt'] != null
        ? DateTime.parse(map['completedAt'] as String)
        : null,
  );

  String toJson() => jsonEncode(toMap());

  factory SyncGoal.fromJson(String source) =>
      SyncGoal.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Represents app configuration for cloud synchronization.
class SyncConfig {
  const SyncConfig({
    this.themeColor = 'lavanda',
    this.personality = 'amigable',
    this.avatar = '🙂',
    this.diaryName = 'Mi diario',
    this.language = 'es',
    this.lastUpdated,
  });

  final String themeColor;
  final String personality;
  final String avatar;
  final String diaryName;
  final String language;
  final DateTime? lastUpdated;

  Map<String, dynamic> toMap() => {
    'themeColor': themeColor,
    'personality': personality,
    'avatar': avatar,
    'diaryName': diaryName,
    'language': language,
    if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
  };

  factory SyncConfig.fromMap(Map<String, dynamic> map) => SyncConfig(
    themeColor: map['themeColor'] as String? ?? 'lavanda',
    personality: map['personality'] as String? ?? 'amigable',
    avatar: map['avatar'] as String? ?? '🙂',
    diaryName: map['diaryName'] as String? ?? 'Mi diario',
    language: map['language'] as String? ?? 'es',
    lastUpdated: map['lastUpdated'] != null
        ? DateTime.parse(map['lastUpdated'] as String)
        : null,
  );

  String toJson() => jsonEncode(toMap());

  factory SyncConfig.fromJson(String source) =>
      SyncConfig.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Represents a user profile for cloud synchronization.
class SyncProfile {
  const SyncProfile({
    this.userName = '',
    this.goal = '',
    this.onboardingCompleted = false,
    this.createdAt,
    this.lastSyncAt,
  });

  final String userName;
  final String goal;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? lastSyncAt;

  Map<String, dynamic> toMap() => {
    'userName': userName,
    'goal': goal,
    'onboardingCompleted': onboardingCompleted,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (lastSyncAt != null) 'lastSyncAt': lastSyncAt!.toIso8601String(),
  };

  factory SyncProfile.fromMap(Map<String, dynamic> map) => SyncProfile(
    userName: map['userName'] as String? ?? '',
    goal: map['goal'] as String? ?? '',
    onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'] as String)
        : null,
    lastSyncAt: map['lastSyncAt'] != null
        ? DateTime.parse(map['lastSyncAt'] as String)
        : null,
  );

  String toJson() => jsonEncode(toMap());

  factory SyncProfile.fromJson(String source) =>
      SyncProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
