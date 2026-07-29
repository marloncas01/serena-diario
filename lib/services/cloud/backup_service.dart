/// Abstract interface for cloud backup operations.
///
/// Provides upload, download, listing, and deletion of backup files
/// in cloud storage (e.g., Firebase Storage). Concrete implementations
/// should handle the actual cloud provider.
abstract class CloudBackupService {
  /// Uploads the local file at [localPath] to cloud storage.
  /// Returns the created [CloudBackup] metadata on success.
  Future<CloudBackup> uploadBackup(String localPath);

  /// Downloads the backup identified by [backupId] to a local temp path.
  /// Returns the local file path of the downloaded backup.
  Future<String> downloadBackup(String backupId);

  /// Lists all backups available in cloud storage, most recent first.
  Future<List<CloudBackup>> listBackups();

  /// Deletes the backup identified by [backupId] from cloud storage.
  Future<void> deleteBackup(String backupId);
}

/// Metadata for a cloud backup file.
class CloudBackup {
  const CloudBackup({
    required this.id,
    required this.fileName,
    required this.uploadedAt,
    required this.sizeBytes,
  });

  final String id;
  final String fileName;
  final DateTime uploadedAt;
  final int sizeBytes;

  Map<String, dynamic> toMap() => {
    'id': id,
    'fileName': fileName,
    'uploadedAt': uploadedAt.toIso8601String(),
    'sizeBytes': sizeBytes,
  };

  factory CloudBackup.fromMap(Map<String, dynamic> map) => CloudBackup(
    id: map['id'] as String,
    fileName: map['fileName'] as String,
    uploadedAt: DateTime.parse(map['uploadedAt'] as String),
    sizeBytes: map['sizeBytes'] as int,
  );
}

/// Stub implementation of [CloudBackupService] when cloud storage is not configured.
///
/// All operations throw [UnimplementedError]. Replace with a real
/// Firebase Storage implementation when ready.
class CloudBackupServiceStub implements CloudBackupService {
  @override
  Future<CloudBackup> uploadBackup(String localPath) async {
    throw UnimplementedError('Cloud backup is not configured.');
  }

  @override
  Future<String> downloadBackup(String backupId) async {
    throw UnimplementedError('Cloud backup is not configured.');
  }

  @override
  Future<List<CloudBackup>> listBackups() async {
    throw UnimplementedError('Cloud backup is not configured.');
  }

  @override
  Future<void> deleteBackup(String backupId) async {
    throw UnimplementedError('Cloud backup is not configured.');
  }
}
