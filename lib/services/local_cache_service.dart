import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static const String _prefix = 'lumad_cache_';

  // Singleton pattern
  static final LocalCacheService _instance = LocalCacheService._internal();
  factory LocalCacheService() => _instance;
  LocalCacheService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> cacheJson(String key, Map<String, dynamic> jsonMap) async {
    await init();
    final jsonString = jsonEncode(jsonMap);
    await _prefs?.setString('$_prefix$key', jsonString);
  }

  Map<String, dynamic>? getCachedJson(String key) {
    if (_prefs == null) return null;
    final jsonString = _prefs?.getString('$_prefix$key');
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheJsonList(String key, List<Map<String, dynamic>> jsonList) async {
    await init();
    final jsonString = jsonEncode(jsonList);
    await _prefs?.setString('$_prefix${key}_list', jsonString);
  }

  List<Map<String, dynamic>>? getCachedJsonList(String key) {
    if (_prefs == null) return null;
    final jsonString = _prefs?.getString('$_prefix${key}_list');
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> queueOfflineAction(String actionType, Map<String, dynamic> payload) async {
    await init();
    final queue = getOfflineQueue();
    queue.add({
      'type': actionType,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
    });
    final encoded = queue.map((e) => jsonEncode(e)).toList();
    await _prefs?.setStringList('${_prefix}offline_queue', encoded);
  }

  List<Map<String, dynamic>> getOfflineQueue() {
    if (_prefs == null) return [];
    final list = _prefs?.getStringList('${_prefix}offline_queue') ?? [];
    return list.map((e) {
      try {
        return jsonDecode(e) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((map) => map.isNotEmpty).toList();
  }

  Future<void> clearOfflineQueue() async {
    await init();
    await _prefs?.remove('${_prefix}offline_queue');
  }

  Future<void> clearAll() async {
    await init();
    final keys = _prefs?.getKeys() ?? {};
    for (var key in keys) {
      if (key.startsWith(_prefix)) {
        await _prefs?.remove(key);
      }
    }
  }
}
