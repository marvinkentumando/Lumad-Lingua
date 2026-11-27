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
