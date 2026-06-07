import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const Duration _defaultTtl = Duration(hours: 1);

  static const String _keyLocation = 'cache_location';
  static const String _keyWeather = 'cache_weather_';
  static const String _keyRisk = 'cache_risk_';
  static const String _keyPolygons = 'cache_polygons_';

  final SharedPreferences _prefs;
  CacheService._(this._prefs);

  static Future<CacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheService._(prefs);
  }

  Future<void> set(
    String key,
    Map<String, dynamic> data, {
    Duration ttl = _defaultTtl,
  }) async {
    final envelope = {
      'data': data,
      'expiresAt': DateTime.now().add(ttl).millisecondsSinceEpoch,
    };
    await _prefs.setString(key, jsonEncode(envelope));
  }

  Map<String, dynamic>? get(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = envelope['expiresAt'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        _prefs.remove(key);
        return null;
      }
      return envelope['data'] as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocation(Map<String, dynamic> locationJson) =>
      set(_keyLocation, locationJson, ttl: const Duration(hours: 6));

  Map<String, dynamic>? loadLocation() => get(_keyLocation);

  Future<void> saveWeather(String ibgeCode, Map<String, dynamic> data) =>
      set('$_keyWeather$ibgeCode', data);

  Map<String, dynamic>? loadWeather(String ibgeCode) =>
      get('$_keyWeather$ibgeCode');

  Future<void> saveRisk(String ibgeCode, Map<String, dynamic> data) =>
      set('$_keyRisk$ibgeCode', data, ttl: const Duration(hours: 3));

  Map<String, dynamic>? loadRisk(String ibgeCode) => get('$_keyRisk$ibgeCode');

  Future<void> savePolygons(
      String ibgeCode, List<dynamic> polygonsJson) async {
    await set('$_keyPolygons$ibgeCode', {'polygons': polygonsJson},
        ttl: const Duration(hours: 12));
  }

  List<dynamic>? loadPolygons(String ibgeCode) {
    final data = get('$_keyPolygons$ibgeCode');
    return data?['polygons'] as List<dynamic>?;
  }

  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
