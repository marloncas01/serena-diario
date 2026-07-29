import 'package:flutter/foundation.dart';
import '../database/hive_journal_database.dart';
import '../models/journal_entry.dart';

enum JournalStatus { loading, ready, error }

/// Owns journal state and isolates asynchronous persistence from presentation.
class JournalProvider extends ChangeNotifier {
  JournalProvider(this._database);
  final HiveJournalDatabase _database;
  JournalStatus _status = JournalStatus.loading;
  String? _errorMessage;
  List<JournalEntry> _entries = const [];

  JournalStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<JournalEntry> get entries => List.unmodifiable(_entries);

  Future<void> initialize() async {
    try {
      _status = JournalStatus.loading;
      notifyListeners();
      await _database.initialize();
      _entries = _database.readAll();
      _status = JournalStatus.ready;
    } catch (_) {
      _status = JournalStatus.error;
      _errorMessage = 'No pudimos abrir tus entradas. Inténtalo de nuevo.';
    }
    notifyListeners();
  }

  Future<bool> add({
    required String mood,
    required String note,
    List<String> tags = const [],
  }) async {
    final normalized = note.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty || _isDuplicate(normalized)) return false;
    try {
      final entry = JournalEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        mood: mood,
        note: normalized,
        tags: _normalizeTags(tags),
      );
      await _database.save(entry);
      _entries = [entry, ..._entries];
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'No pudimos guardar esta entrada. Inténtalo otra vez.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(JournalEntry entry) async {
    try {
      final updated = entry.copyWith(
        note: entry.note.trim().replaceAll(RegExp(r'\s+'), ' '),
        tags: _normalizeTags(entry.tags),
      );
      if (updated.note.isEmpty) return false;
      await _database.save(updated);
      _entries = _entries
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'No pudimos actualizar la entrada. Inténtalo otra vez.';
      notifyListeners();
      return false;
    }
  }

  Future<JournalEntry?> delete(String id) async {
    final matches = _entries.where((item) => item.id == id);
    if (matches.isEmpty) return null;
    final entry = matches.first;
    try {
      await _database.delete(id);
      _entries = _entries.where((item) => item.id != id).toList();
      notifyListeners();
      return entry;
    } catch (_) {
      _errorMessage = 'No pudimos borrar la entrada. Inténtalo otra vez.';
      notifyListeners();
      return null;
    }
  }

  Future<bool> restore(JournalEntry entry) async {
    try {
      await _database.save(entry);
      _entries = [..._entries, entry]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'No pudimos restaurar la entrada.';
      notifyListeners();
      return false;
    }
  }

  bool _isDuplicate(String note) => _entries.any(
    (item) =>
        item.note == note &&
        DateTime.now().difference(item.createdAt).inMinutes < 2,
  );

  List<String> _normalizeTags(List<String> tags) => tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .map((tag) => tag.length > 24 ? tag.substring(0, 24) : tag)
      .toSet()
      .take(5)
      .toList(growable: false);
}
