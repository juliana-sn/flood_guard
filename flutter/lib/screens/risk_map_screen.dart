import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../theme.dart';

class RiskMapScreen extends StatefulWidget {
  const RiskMapScreen({super.key});

  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends State<RiskMapScreen> {
  final MapController _mapController = MapController();
  bool _loading = true;
  String? _error;
  List<Polygon> _floodPolygons = [];
  LatLng _mapCenter = LatLng(-23.5505, -46.6333);
  LatLng? _currentLocation;
  String _locationStatus = 'Aguardando permissão de localização...';
  String _riskTitle = 'Carregando status de risco...';
  String _riskDescription = 'Posição atual sendo avaliada.';
  Color _riskColor = AppColors.primary;

  String get _backendBaseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadFloodGeoJson();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationStatus = 'Serviço de localização desativado';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationStatus = 'Permissão de localização negada';
          _riskTitle = 'Permissão de localização necessária';
          _riskDescription = 'Ative a permissão para ver alertas baseados na sua posição.';
          _riskColor = Colors.orange;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationStatus = 'Localização encontrada';
        if (_currentLocation != null) {
          _mapCenter = _currentLocation!;
        }
      });
      _mapController.move(_mapCenter, 13);
      await _fetchNearbyRisk();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _locationStatus = 'Erro ao obter localização';
        _error = error.toString();
        _riskTitle = 'Falha ao acessar localização';
        _riskDescription = 'Não foi possível determinar sua posição atual.';
        _riskColor = Colors.orange;
      });
    }
  }

  Future<void> _fetchNearbyRisk() async {
    if (_currentLocation == null) return;
    try {
      final response = await http
          .get(Uri.parse('$_backendBaseUrl/api/alerts/nearby?lat=${_currentLocation!.latitude}&lon=${_currentLocation!.longitude}'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Falha ao buscar alerta: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _riskTitle = data['severity'] as String? ?? 'Desconhecido';
        _riskDescription = data['description'] as String? ?? 'Nenhuma informação disponível.';
        _riskColor = Color(int.parse((data['color'] as String? ?? '#FF7E7B').replaceFirst('#', '0xFF'), radix: 16));
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _riskTitle = 'Erro ao obter alerta';
        _riskDescription = error.toString();
        _riskColor = Colors.orange;
      });
    }
  }

  Future<void> _loadFloodGeoJson() async {
    try {
      final response = await http
          .get(Uri.parse('$_backendBaseUrl/api/geojson/flood-zones'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Falha ao carregar dados: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) {
        throw Exception('GeoJSON sem features');
      }

      final polygons = <Polygon>[];
      for (final rawFeature in features) {
        final feature = rawFeature as Map<String, dynamic>;
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        if (geometry == null) continue;

        final type = geometry['type'] as String?;
        final coordinates = geometry['coordinates'];
        if (type == 'Polygon') {
          polygons.addAll(_buildPolygonsFromCoordinates(coordinates as List<dynamic>));
        } else if (type == 'MultiPolygon') {
          final multipolygons = coordinates as List<dynamic>;
          for (final polygonCoordinates in multipolygons) {
            polygons.addAll(_buildPolygonsFromCoordinates(polygonCoordinates as List<dynamic>));
          }
        }
      }

      if (polygons.isEmpty) {
        throw Exception('Nenhum polígono válido encontrado');
      }

      if (!mounted) return;
      setState(() {
        _floodPolygons = polygons;
        if (_currentLocation != null) {
          _mapCenter = _currentLocation!;
        } else {
          _mapCenter = polygons.first.points.first;
        }
        _loading = false;
      });
    } on TimeoutException catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Tempo de conexão excedido. Verifique se o backend está rodando e use o IP correto.';
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<Polygon> _buildPolygonsFromCoordinates(List<dynamic> coordinates) {
    if (coordinates.isEmpty) return [];

    final outerRing = coordinates.first as List<dynamic>;
    final points = outerRing.map<LatLng>((coord) {
      final pair = coord as List<dynamic>;
      final lon = pair[0] as double;
      final lat = pair[1] as double;
      return LatLng(lat, lon);
    }).toList();

    return [
      Polygon(
        points: points,
        color: Colors.red.withOpacity(0.25),
        borderColor: Colors.red,
        borderStrokeWidth: 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Mapa de Risco', style: AppTextStyles.headlineMd),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        color: const Color(0xFFF5F7FB),
                        child: _buildMapContent(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 140),
              ],
            ),
            Positioned(
              top: 120,
              right: 24,
              child: _LegendCard(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _StatusBottomSheet(
                error: _error,
                isLoading: _loading,
                locationStatus: _locationStatus,
                riskTitle: _riskTitle,
                riskDescription: _riskDescription,
                riskColor: _riskColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Erro ao carregar mapa:\n$_error',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'dev.gs_space_connect.lumen_orbit',
        ),
        PolygonLayer(polygons: _floodPolygons),
        if (_currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                width: 32,
                height: 32,
                point: _currentLocation!,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _LegendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Legenda', style: AppTextStyles.headlineMd.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          Row(children: [
            _Dot(color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Nível Crítico'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _Dot(color: AppColors.secondary),
            const SizedBox(width: 8),
            const Text('Risco Moderado'),
          ]),
          const SizedBox(height: 16),
          const Text('Localização atual', style: AppTextStyles.labelSm),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatusBottomSheet extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final String locationStatus;
  final String riskTitle;
  final String riskDescription;
  final Color riskColor;

  const _StatusBottomSheet({
    Key? key,
    this.isLoading = false,
    this.error,
    required this.locationStatus,
    required this.riskTitle,
    required this.riskDescription,
    required this.riskColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Risco de Alagamento', style: AppTextStyles.headlineMd),
          const SizedBox(height: 8),
          Text(
            locationStatus,
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(riskTitle, style: AppTextStyles.headlineMd.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Text(riskDescription, style: AppTextStyles.bodyMd),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Ver Rotas de Fuga'),
          ),
        ],
      ),
    );
  }
}
