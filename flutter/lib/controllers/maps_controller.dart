import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http; // Lembrar de manter esse import

class MapsController extends ChangeNotifier {
  double lat = 37.00;
  double long = -122.4064;
  String erro = '';
  String _currentRadarPath = '';

  final MapController mapController = MapController();

  MapsController() {
    _inicializarApp();
  }

  // CAMADA 1: Google Maps Tradicional
  String get googleRoadmapUrl => 
      'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';

  // CAMADA 2: Clima Dinâmico (RainViewer Gratuito)
  String get weatherTileUrl {
    if (_currentRadarPath.isEmpty) {
      return 'https://tilecache.rainviewer.com/v2/radar/default/256/{z}/{x}/{y}/2/1_1.png';
    }
    return 'https://tilecache.rainviewer.com$_currentRadarPath/256/{z}/{x}/{y}/2/1_1.png';
  }

  Future<void> _inicializarApp() async {
    await Future.wait([
      getPosicao(),
      _buscarTimestampRadar(),
    ]);
  }

  Future<void> _buscarTimestampRadar() async {
    try {
      final response = await http.get(Uri.parse('https://api.rainviewer.com/public/weather-maps.json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['radar'] != null && data['radar']['past'] != null && data['radar']['past'].isNotEmpty) {
          _currentRadarPath = data['radar']['past'].last['path'];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar o radar do RainViewer: $e');
    }
  }

  Future<void> getPosicao() async {
    try {
      Position posicao = await _posicaoAtual();
      lat = posicao.latitude;
      long = posicao.longitude;
      mapController.move(LatLng(lat, long), 6.0); // Zoom 4.0 ajuda a ver melhor o clima ao redor
    } catch (e) {
      erro = e.toString();
    }
    notifyListeners();
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permissao;
    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) return Future.error('Por Favor, habilite a localização no smartphone');

    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) return Future.error('Por Favor, habilite a localização no smartphone');
    }
    if (permissao == LocationPermission.deniedForever) return Future.error('Por Favor, habilite a localização no smartphone');

    return await Geolocator.getCurrentPosition();
  }
}