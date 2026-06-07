import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  // Troque pelo IP/domínio do seu servidor em produção
  static final String _baseUrl = kIsWeb
      ? 'http://localhost:8000/api'
      : Platform.isAndroid
          ? 'http://10.0.2.2:8000/api'   // emulador Android
          : 'http://localhost:8000/api';  // iOS simulator / físico na mesma rede

  static const String _tokenKey = 'auth_token';

  // ── Token ──────────────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── HTTP helpers ───────────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Map<String, dynamic> _decode(http.Response r) {
    final body = jsonDecode(r.body);
    if (r.statusCode >= 400) {
      final detail = body is Map ? body['detail'] ?? r.body : r.body;
      throw ApiException(r.statusCode, detail.toString());
    }
    return body is Map<String, dynamic> ? body : {'data': body};
  }

  static List<dynamic> _decodeList(http.Response r) {
    if (r.statusCode >= 400) {
      final body = jsonDecode(r.body);
      final detail = body is Map ? body['detail'] ?? r.body : r.body;
      throw ApiException(r.statusCode, detail.toString());
    }
    return jsonDecode(r.body) as List;
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final r = await http
        .post(
          Uri.parse('$_baseUrl/auth/signup'),
          headers: await _headers(),
          body: jsonEncode({'name': name, 'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 20));
    final data = _decode(r);
    await saveToken(data['access_token'] as String);
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final r = await http
        .post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: await _headers(),
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 20));
    final data = _decode(r);
    await saveToken(data['access_token'] as String);
    return data;
  }

  static Future<void> logout() async => clearToken();

  // ── Risk ───────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getRisk(double lat, double lng) async {
    final r = await http
        .get(
          Uri.parse('$_baseUrl/risk?lat=$lat&lng=$lng'),
          headers: await _headers(auth: true),
        )
        .timeout(const Duration(seconds: 45));
    return _decode(r);
  }

  // ── Addresses ──────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getAddresses() async {
    final r = await http
        .get(Uri.parse('$_baseUrl/addresses'),
            headers: await _headers(auth: true))
        .timeout(const Duration(seconds: 15));
    return _decodeList(r);
  }

  static Future<Map<String, dynamic>> addAddress(Map<String, dynamic> body) async {
    final r = await http
        .post(
          Uri.parse('$_baseUrl/addresses'),
          headers: await _headers(auth: true),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _decode(r);
  }

  static Future<void> deleteAddress(int id) async {
    await http
        .delete(Uri.parse('$_baseUrl/addresses/$id'),
            headers: await _headers(auth: true))
        .timeout(const Duration(seconds: 15));
  }

  // ── Alert History ──────────────────────────────────────────────────────────

  static Future<List<dynamic>> getHistory({int limit = 50}) async {
    final r = await http
        .get(
          Uri.parse('$_baseUrl/history?limit=$limit'),
          headers: await _headers(auth: true),
        )
        .timeout(const Duration(seconds: 15));
    return _decodeList(r);
  }

  static Future<void> clearHistory() async {
    await http
        .delete(Uri.parse('$_baseUrl/history'),
            headers: await _headers(auth: true))
        .timeout(const Duration(seconds: 15));
  }
}