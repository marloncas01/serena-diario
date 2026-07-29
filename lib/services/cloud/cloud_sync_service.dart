import 'sync_models.dart';

/// Abstract interface for cloud data synchronization.
///
/// Defines methods for pushing local data to the cloud and pulling remote
/// data back. Concrete implementations should handle Firebase Firestore
/// or another backend.
abstract class CloudSyncService {
  /// Uploads local [data] to the cloud, merging or overwriting as appropriate.
  Future<SyncResult> syncData(SyncData data);

  /// Pulls the latest data from the cloud and returns it.
  Future<SyncData?> pullData();

  /// Returns the timestamp of the last successful sync, or null.
  DateTime? getLastSyncTime();

  /// Returns true if the device currently has network connectivity
  /// and the cloud service is reachable.
  Future<bool> isOnline();
}

/// The result of a sync operation.
class SyncResult {
  const SyncResult({
    required this.success,
    this.message = '',
    this.entriesSynced = 0,
    this.memoriesSynced = 0,
    this.conflictsResolved = 0,
  });

  final bool success;
  final String message;
  final int entriesSynced;
  final int memoriesSynced;
  final int conflictsResolved;
}

/// Aggregated data payload for synchronization.
///
/// Each field represents a collection that can be synced independently.
class SyncData {
  const SyncData({
    this.entries = const [],
    this.memories = const [],
    this.stats,
    this.goals = const [],
    this.config,
    this.profile,
  });

  final List<SyncEntry> entries;
  final List<SyncMemory> memories;
  final SyncStats? stats;
  final List<SyncGoal> goals;
  final SyncConfig? config;
  final SyncProfile? profile;

  Map<String, dynamic> toMap() => {
    'entries': entries.map((e) => e.toMap()).toList(),
    'memories': memories.map((m) => m.toMap()).toList(),
    if (stats != null) 'stats': stats!.toMap(),
    'goals': goals.map((g) => g.toMap()).toList(),
    if (config != null) 'config': config!.toMap(),
    if (profile != null) 'profile': profile!.toMap(),
  };

  factory SyncData.fromMap(Map<String, dynamic> map) => SyncData(
    entries: (map['entries'] as List<dynamic>? ?? [])
        .map((e) => SyncEntry.fromMap(e as Map<String, dynamic>))
        .toList(),
    memories: (map['memories'] as List<dynamic>? ?? [])
        .map((m) => SyncMemory.fromMap(m as Map<String, dynamic>))
        .toList(),
    stats: map['stats'] != null
        ? SyncStats.fromMap(map['stats'] as Map<String, dynamic>)
        : null,
    goals: (map['goals'] as List<dynamic>? ?? [])
        .map((g) => SyncGoal.fromMap(g as Map<String, dynamic>))
        .toList(),
    config: map['config'] != null
        ? SyncConfig.fromMap(map['config'] as Map<String, dynamic>)
        : null,
    profile: map['profile'] != null
        ? SyncProfile.fromMap(map['profile'] as Map<String, dynamic>)
        : null,
  );
}

/// Stub implementation of [CloudSyncService] when cloud sync is not configured.
///
/// All operations return failure results or null. Replace with a real
/// Firebase Firestore implementation when ready.
class CloudSyncServiceStub implements CloudSyncService {
  @override
  Future<SyncResult> syncData(SyncData data) async {
    return const SyncResult(success: false, message: 'Cloud sync is not configured.');
  }

  @override
  Future<SyncData?> pullData() async => null;

  @override
  DateTime? getLastSyncTime() => null;

  @override
  Future<bool> isOnline() async => false;
}
