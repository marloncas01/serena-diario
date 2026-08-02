/// Rastrea las últimas frases/respuestas entregadas por Serena para evitar
/// repeticiones inmediatas y elegir alternativas manteniendo naturalidad.
///
/// Es un mecanismo en memoria (por sesión) por diseño: no requiere I/O y es
/// totalmente seguro dentro de tests y del ciclo de vida de la app.
class ResponseVariationTracker {
  ResponseVariationTracker([this._maxRecent = 8]);

  static final ResponseVariationTracker instance = ResponseVariationTracker();

  final int _maxRecent;
  final Map<String, List<String>> _recent = {};

  List<String> _bucket(String key) => _recent.putIfAbsent(key, () => []);

  /// Elige un elemento de `pool` evitando repetir los recientes de `key`.
  /// Si todo el pool ya fue usado, cae a la lista completa.
  String pickUnique(String key, List<String> pool, int seed) {
    if (pool.isEmpty) return '';
    final recent = _bucket(key);
    final available = pool.where((m) => !recent.contains(m)).toList();
    final source = available.isNotEmpty ? available : pool;
    final index = (seed.abs()) % source.length;
    final picked = source[index];
    _record(key, picked);
    return picked;
  }

  /// Devuelve un índice dentro de `size` sin repetir el índice usado más
  /// recientemente para `key` mientras haya alternativas disponibles.
  int pickIndex(String key, int size, int seed) {
    if (size <= 1) return 0;
    final recent = _bucket(key).map(int.tryParse).whereType<int>().toList();
    final available = [
      for (var i = 0; i < size; i++)
        if (!recent.contains(i)) i,
    ];
    final source = available.isNotEmpty ? available : List.generate(size, (i) => i);
    final index = source[(seed.abs()) % source.length];
    _record(key, '$index');
    return index;
  }

  bool wasRecentlyUsed(String key, String value) =>
      _bucket(key).contains(value);

  List<String> recent(String key) => List.unmodifiable(_bucket(key));

  void record(String key, String value) => _record(key, value);

  void reset(String key) => _recent.remove(key);

  void resetAll() => _recent.clear();

  void _record(String key, String value) {
    final recent = _bucket(key);
    recent.remove(value);
    recent.insert(0, value);
    final max = _maxRecent;
    if (recent.length > max) {
      recent.removeRange(max, recent.length);
    }
  }
}
