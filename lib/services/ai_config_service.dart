import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationMessage {
  const ConversationMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ConversationMessage.fromMap(Map<String, dynamic> map) =>
      ConversationMessage(
        text: map['text'] as String,
        isUser: map['isUser'] as bool,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

enum APIStatus { detected, notDetected }

enum ProviderStatus { available, unavailable }

class AIConfigService {
  AIConfigService._();
  static final AIConfigService _instance = AIConfigService._();
  factory AIConfigService() => _instance;

  static const _aiEnabledKey = 'ai_conversational_enabled_v1';
  static const _historyKey = 'ai_conversation_history_v1';
  static const _maxHistory = 20;

  bool _aiEnabled = false;
  bool get aiEnabled => _aiEnabled;

  APIStatus _apiStatus = APIStatus.notDetected;
  APIStatus get apiStatus => _apiStatus;

  ProviderStatus _providerStatus = ProviderStatus.unavailable;
  ProviderStatus get providerStatus => _providerStatus;

  List<ConversationMessage> _history = [];
  List<ConversationMessage> get history => List.unmodifiable(_history);

  bool get hasAPIKey {
    try {
      const key = String.fromEnvironment('GEMINI_API_KEY');
      return key.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool get geminiAvailable => hasAPIKey && _providerStatus == ProviderStatus.available;

  String get statusLabel {
    if (_aiEnabled && geminiAvailable) return 'Activa';
    if (_aiEnabled && !geminiAvailable) return 'Modo Local';
    return 'Desactivada';
  }

  String get statusIcon {
    if (_aiEnabled && geminiAvailable) return '🟢';
    if (_aiEnabled) return '🟡';
    return '🔴';
  }

  String get statusDescription {
    if (_aiEnabled && geminiAvailable) return 'IA activa con Gemini';
    if (_aiEnabled && !geminiAvailable) return 'IA activa, modo local';
    return 'IA desactivada';
  }

  String get historyLabel => '${_history.length} conversaciones';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _aiEnabled = prefs.getBool(_aiEnabledKey) ?? false;

    _apiStatus = hasAPIKey ? APIStatus.detected : APIStatus.notDetected;

    final raw = prefs.getStringList(_historyKey);
    if (raw != null) {
      _history = raw.map((s) {
        final parts = s.split('|||');
        return ConversationMessage(
          text: parts.length > 2 ? parts[0] : s,
          isUser: parts.length > 2 ? parts[1] == '1' : false,
          timestamp: parts.length > 2
              ? DateTime.tryParse(parts[2]) ?? DateTime.now()
              : DateTime.now(),
        );
      }).toList();
    }
    debugPrint('[AIConfig] API: ${_apiStatus.name}, AI: $_aiEnabled');
  }

  void setProviderAvailable(bool available) {
    _providerStatus =
        available ? ProviderStatus.available : ProviderStatus.unavailable;
  }

  Future<void> setAIEnabled(bool enabled) async {
    _aiEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiEnabledKey, enabled);
  }

  Future<void> addMessage(String text, {required bool isUser}) async {
    _history.add(ConversationMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));

    if (_history.length > _maxHistory) {
      _history = _history.sublist(_history.length - _maxHistory);
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = _history
        .map((m) =>
            '${m.text}|||${m.isUser ? "1" : "0"}|||${m.timestamp.toIso8601String()}')
        .toList();
    await prefs.setStringList(_historyKey, raw);
  }

  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
