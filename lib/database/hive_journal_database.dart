import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

/// Local database boundary. Future cloud backup can be added without touching UI.
class HiveJournalDatabase {
  static const _boxName = 'journal_entries';
  static const _legacyKey = 'serena_entries_v1';
  late final Box<Map> _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
    await _migrateLegacyEntries();
  }

  List<JournalEntry> readAll() {
    final entries = _box.values.map(JournalEntry.fromMap).toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<void> save(JournalEntry entry) => _box.put(entry.id, entry.toMap());
  Future<void> delete(String id) => _box.delete(id);

  Future<void> _migrateLegacyEntries() async {
    if (_box.isNotEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    final legacy = preferences.getStringList(_legacyKey) ?? const [];
    for (final source in legacy) {
      try {
        final item = jsonDecode(source) as Map<String, dynamic>;
        final entry = JournalEntry(
          id: item['id'] as String,
          createdAt: DateTime.parse(item['date'] as String),
          mood: item['mood'] as String,
          note: item['note'] as String,
        );
        await save(entry);
      } catch (_) {
        // A corrupted legacy entry must not prevent the diary from opening.
      }
    }
    if (legacy.isNotEmpty) await preferences.remove(_legacyKey);
  }
}
