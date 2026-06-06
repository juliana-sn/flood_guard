import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/alert_result.dart';
import '../models/flood_risk.dart';
import '../models/location_info.dart';
import '../models/weather_forecast.dart';
import 'cache_service.dart';
import 'ibge_service.dart';
import 'weather_service.dart';
import 'geo_risk_service.dart' hide RiskLevel;

class CoordinatorResult {
  final LocationInfo location;
  final WeatherForecast forecast;
  final FloodRisk risk;
  final AlertResult alert;

  const CoordinatorResult({
    required this.location,
    required this.forecast,
    required this.risk,
    required this.alert,
  });
}

class FloodAlertCoordinator {
  final _ibge    = IbgeService();
  final _weather = WeatherService();
  final _geoRisk = GeoRiskService();

  CacheService? _cache;

  Future<CacheService> get _cacheService async {
    _cache ??= await CacheService.create();
    return _cache!;
  }

  Future<CoordinatorResult> run() async {
    final pos = await _getPosition();
    debugPrint('[Coordinator] GPS ok: ${pos.latitude}, ${pos.longitude}');

    final location = await _resolveLocation(pos);
    debugPrint('[Coordinator] Município: ${location.cityName} / ${location.uf} / IBGE: ${location.ibgeCode} / CPTEC: ${location.cptecCityId}');

    final results = await Future.wait([
      _getForecast(location),
      _getRisk(location),
    ]);

    final forecast = results[0] as WeatherForecast;
    final risk     = results[1] as FloodRisk;

    debugPrint('[Coordinator] Forecast: ${forecast.accumulatedMm24h}mm / source: ${forecast.source}');
    debugPrint('[Coordinator] Risk: ${risk.level} / ${risk.message}');

    final alert = AlertEngine.evaluate(
      zoneRisk: risk,
      forecastRainfallMm: forecast.accumulatedMm24h,
    );

    return CoordinatorResult(
      location: location,
      forecast: forecast,
      risk: risk,
      alert: alert,
    );
  }

  Future<Position> _getPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização permanentemente negada.');
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<LocationInfo> _resolveLocation(Position pos) async {
    final cache = await _cacheService;
    final cached = cache.loadLocation();
    if (cached != null) {
      final loc = LocationInfo.fromJson(cached);
      final dist = Geolocator.distanceBetween(
          loc.lat, loc.lng, pos.latitude, pos.longitude);
      if (dist < 500) {
        debugPrint('[Coordinator] Localização do cache (dist: ${dist.toStringAsFixed(0)}m)');
        return loc;
      }
    }

    try {
      final loc = await _ibge.resolveLocation(pos.latitude, pos.longitude);
      await cache.saveLocation(loc.toJson());
      return loc;
    } catch (e) {
      debugPrint('[Coordinator] IBGE falhou: $e — usando coordenadas brutas');
      return LocationInfo(
        cityName: '',
        uf: '',
        stateName: '',
        ibgeCode: '',
        cptecCityId: null,
        lat: pos.latitude,
        lng: pos.longitude,
      );
    }
  }

  Future<WeatherForecast> _getForecast(LocationInfo loc) async {
    try {
      final forecast = await _weather.fetchForecastByCoords(loc.lat, loc.lng);
      return forecast;
    } catch (e) {
      debugPrint('[Coordinator] Forecast falhou: $e');
      return WeatherForecast.empty();
    }
  }

  Future<FloodRisk> _getRisk(LocationInfo loc) async {
    try {
      // Agora passamos UF e nome do estado
      final riskLevel = await _geoRisk.fetchFloodRiskByState(loc.uf, loc.stateName);
      return FloodRisk.fromLevel(riskLevel.index);
    } catch (e) {
      debugPrint('[Coordinator] Risk falhou: $e');
      return FloodRisk.none();
    }
  }

  Future<CoordinatorResult> simulate() async {
    final location = LocationInfo(
      cityName: 'São Paulo',
      uf: 'SP',
      stateName: 'São Paulo',
      ibgeCode: '3550308',
      cptecCityId: null,
      lat: -23.5738,
      lng: -46.6231,
    );

    final forecast = WeatherForecast(
      accumulatedMm24h: 60.0, // simula 60mm de chuva
      maxIntensityMm3h: 25.0,
      intensity: RainIntensity.extreme,
      source: 'Simulado',
      description: 'Chuvas fortes ao longo do dia',
    );

    final risk = FloodRisk.fromLevel(RiskLevel.high.index);

    final alert = AlertEngine.evaluate(
      zoneRisk: risk,
      forecastRainfallMm: forecast.accumulatedMm24h,
    );

    return CoordinatorResult(
      location: location,
      forecast: forecast,
      risk: risk,
      alert: alert,
    );
  }

  Future<void> clearCache() async {
    final cache = await _cacheService;
    await cache.clearAll();
  }
}
