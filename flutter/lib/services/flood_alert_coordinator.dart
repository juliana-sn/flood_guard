import 'package:flutter/material.dart' show debugPrint, Color;
import 'package:geolocator/geolocator.dart';
import 'api_client.dart';

class CoordinatorResult {
  final double lat;
  final double lng;
  final String cityName;
  final String uf;
  final String riskLevel;
  final String severityTitle;
  final String riskMessage;
  final String reason;
  final double rainfallMm;
  final String weatherSource;
  final bool shouldAlert;
  // colorValue vem direto da API — única fonte de verdade
  final int colorValue;

  CoordinatorResult({
    required this.lat,
    required this.lng,
    required this.cityName,
    required this.uf,
    required this.riskLevel,
    required this.severityTitle,
    required this.riskMessage,
    required this.reason,
    required this.rainfallMm,
    required this.weatherSource,
    required this.shouldAlert,
    required this.colorValue,
  });

  CoordinatorResult copyWith({String? reason}) => CoordinatorResult(
        lat: lat, lng: lng, cityName: cityName, uf: uf,
        riskLevel: riskLevel, severityTitle: severityTitle,
        riskMessage: riskMessage, reason: reason ?? this.reason,
        rainfallMm: rainfallMm, weatherSource: weatherSource,
        shouldAlert: shouldAlert, colorValue: colorValue,
      );

  /// Converte color_hex "#RRGGBB" → int com FF alpha
  static int _hexToColorValue(String hex) {
    final h = hex.replaceFirst('#', '');
    return int.parse('FF$h', radix: 16);
  }

  /// Constrói a partir da resposta JSON da API
  factory CoordinatorResult.fromApi({
    required double lat,
    required double lng,
    required Map<String, dynamic> data,
  }) {
    final colorHex = data['color_hex'] as String? ?? '#9E9E9E';
    return CoordinatorResult(
      lat: lat,
      lng: lng,
      cityName: data['city_name'] as String? ?? '',
      uf: data['uf'] as String? ?? '',
      riskLevel: data['risk_level'] as String? ?? 'none',
      severityTitle: data['severity_title'] as String? ?? '',
      riskMessage: data['risk_message'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      rainfallMm: (data['rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      weatherSource: data['weather_source'] as String? ?? '',
      shouldAlert: data['should_alert'] as bool? ?? false,
      colorValue: _hexToColorValue(colorHex),
    );
  }
}

// Cache singleton — compartilhado entre RiskMapScreen e AlertCenterScreen
class _ResultCache {
  static CoordinatorResult? _cached;
  static DateTime? _fetchedAt;

  static bool get isValid {
    if (_cached == null || _fetchedAt == null) return false;
    return DateTime.now().difference(_fetchedAt!) < const Duration(minutes: 10);
  }

  static void set(CoordinatorResult r) {
    _cached = r;
    _fetchedAt = DateTime.now();
  }

  static CoordinatorResult? get value => _cached;
  static void clear() { _cached = null; _fetchedAt = null; }
}

class FloodAlertCoordinator {
  /// Roda a consulta completa ou retorna do cache se recente (< 10 min)
  Future<CoordinatorResult> run({bool forceRefresh = false}) async {
    if (!forceRefresh && _ResultCache.isValid) {
      debugPrint('[Coordinator] Usando resultado do cache');
      return _ResultCache.value!;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final lat = position.latitude;
    final lng = position.longitude;

    debugPrint('[Coordinator] GPS ok: $lat, $lng');

    final data = await ApiClient.getRisk(lat, lng);

    debugPrint('[Coordinator] API respondeu: riskLevel=${data["risk_level"]} '
        'color_hex=${data["color_hex"]} severity=${data["severity"]}');

    final result = CoordinatorResult.fromApi(lat: lat, lng: lng, data: data);
    _ResultCache.set(result);
    return result;
  }

  void clearCache() => _ResultCache.clear();
}
