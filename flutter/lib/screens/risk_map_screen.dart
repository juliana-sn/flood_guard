import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/alert_result.dart';
import '../models/weather_forecast.dart';
import '../services/flood_alert_coordinator.dart';
import '../theme.dart';

// Timeout global para cada etapa — evita loading infinito
const _kLocationTimeout = Duration(seconds: 45);

class RiskMapScreen extends StatefulWidget {
  const RiskMapScreen({super.key});

  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends State<RiskMapScreen> {
  final _mapController  = MapController();
  final _coordinator    = FloodAlertCoordinator();

  bool _locationLoading = true;
  bool _dataLoading     = false;

  String? _locationError;
  String? _dataError;

  LatLng _mapCenter          = const LatLng(-23.5505, -46.6333);
  LatLng? _currentLocation;

  String _locationStatus     = 'Determinando localização...';
  AlertResult? _alertResult;
  WeatherForecast? _forecast;
  String _cityName           = '';

  @override
  void initState() {
    super.initState();
    _loadInPhases();
  }

  Future<void> _loadInPhases() async {
    setState(() {
      _locationLoading = true;
      _locationError   = null;
      _dataError       = null;
      _alertResult     = null;
    });

    try {
      final result = await _coordinator.run().timeout(_kLocationTimeout);
      final position = LatLng(result.location.lat, result.location.lng);

      if (!mounted) return;
      setState(() {
        _currentLocation = position;
        _mapCenter       = position;
        _cityName        = result.location.cityName;
        _locationStatus  = result.location.cityName.isNotEmpty
            ? '${result.location.cityName} — ${result.location.uf}'
            : 'Localização encontrada';
        _locationLoading = false;
        _dataLoading     = true;

        _alertResult = result.alert;
        _forecast    = result.forecast;
      });

      try { _mapController.move(_mapCenter, 13); } catch (_) {}

      if (result.alert.shouldAlert && mounted) {
        _showAlertBanner(result.alert);
      }

      setState(() => _dataLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError   = _friendlyError(e);
        _locationStatus  = 'Usando localização padrão (São Paulo)';
        _locationLoading = false;
        _dataLoading     = false;
      });
    }
  }
  // dentro do _RiskMapScreenState

Set<CircleMarker> _buildRiskCircles() {
  if (_currentLocation == null || _alertResult == null) return {};

  final color = _alertResult!.color.withOpacity(0.3);

  return {
    CircleMarker(
      point: _currentLocation!,
      radius: 5000, // 5 km
      useRadiusInMeter: true,
      color: color,
      borderStrokeWidth: 2,
      borderColor: _alertResult!.color.withOpacity(0.8),
    ),
    CircleMarker(
      point: _currentLocation!,
      radius: 10000, // 10 km
      useRadiusInMeter: true,
      color: color.withOpacity(0.2),
      borderStrokeWidth: 2,
      borderColor: _alertResult!.color.withOpacity(0.6),
    ),
  };
}


  void _showAlertBanner(AlertResult alert) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: alert.color,
        content: Text(
          alert.reason,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout') || msg.contains('timedout')) {
      return 'Tempo esgotado. Verifique sua conexão.';
    }
    if (msg.contains('permission')) {
      return 'Permissão de localização negada. Ative nas configurações.';
    }
    if (msg.contains('location service')) {
      return 'GPS desativado. Ative a localização do dispositivo.';
    }
    return 'Erro ao carregar dados. Tente novamente.';
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mapa de Risco', style: AppTextStyles.headlineMd),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _locationLoading ? null : _loadInPhases,
                        tooltip: 'Atualizar',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: _mapCenter,
    initialZoom: 12,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.floodguard.app',
    ),
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
    if (_alertResult != null)
      CircleLayer(circles: _buildRiskCircles().toList()),
  ],
),

                          if (_locationLoading)
                            Container(
                              color: Colors.black.withOpacity(0.35),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(color: Colors.white),
                                    SizedBox(height: 12),
                                    Text(
                                      'Obtendo localização...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 200),
              ],
            ),

            Positioned(
              top: 100,
              right: 24,
              child: _LegendCard(),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StatusBottomSheet( // corrigido: classe definida abaixo
                locationStatus: _locationStatus,
                locationError: _locationError,
                alertResult: _alertResult,
                forecast: _forecast,
                dataLoading: _dataLoading,
                onRetry: _loadInPhases,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Legend ──────────────────────────────────────────────────────────────────

class _LegendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
          Text('Legenda',
              style: AppTextStyles.headlineMd.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          _LegendRow(color: const Color(0xFFF44336), label: 'Muito Alto'),
          const SizedBox(height: 5),
          _LegendRow(color: const Color(0xFFFF9800), label: 'Alto'),
          const SizedBox(height: 5),
          _LegendRow(color: const Color(0xFFFFEB3B), label: 'Moderado'),
          const SizedBox(height: 5),
          _LegendRow(color: const Color(0xFF4CAF50), label: 'Baixo'),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.my_location, size: 13, color: Colors.blue),
            const SizedBox(width: 5),
            Text('Você', style: AppTextStyles.labelSm),
          ]),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 7),
      Text(label, style: AppTextStyles.labelSm),
    ]);
  }
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class StatusBottomSheet extends StatelessWidget {
  final String locationStatus;
  final String? locationError;
  final AlertResult? alertResult;
  final WeatherForecast? forecast;
  final bool dataLoading;
  final VoidCallback onRetry;

  const StatusBottomSheet({
    required this.locationStatus,
    required this.onRetry,
    this.locationError,
    this.alertResult,
    this.forecast,
    this.dataLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Risco de Alagamento', style: AppTextStyles.headlineMd),
          const SizedBox(height: 4),

          // Status da localização
          Row(children: [
            Icon(
              locationError != null ? Icons.location_off : Icons.location_on,
              size: 14,
              color: locationError != null ? AppColors.error : Colors.green,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                locationError ?? locationStatus,
                style: AppTextStyles.bodyMd.copyWith(
                  color: locationError != null ? AppColors.error : null,
                ),
              ),
            ),
          ]),

          const SizedBox(height: 14),

          if (dataLoading)
            const LinearProgressIndicator()
          else if (alertResult != null) ...[
            // Card de alerta
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: alertResult!.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: alertResult!.color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(
                      alertResult!.shouldAlert
                          ? Icons.warning_rounded
                          : Icons.check_circle,
                      color: alertResult!.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alertResult!.displayTitle,
                      style: AppTextStyles.headlineMd.copyWith(fontSize: 17),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(alertResult!.reason, style: AppTextStyles.bodyMd),
                ],
              ),
            ),

            // Linha de previsão de chuva
            if (forecast != null) ...[
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.water_drop_outlined,
                    size: 15, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  '${forecast!.accumulatedMm24h.toStringAsFixed(1)}mm previstos/24h'
                  ' · ${forecast!.source}',
                  style: AppTextStyles.bodyMd,
                ),
              ]),
            ],
          ] else if (locationError != null) ...[
            // Estado de erro com botão de retry
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(locationError!, style: AppTextStyles.bodyMd),
            ),
          ],

          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Rotas de Fuga'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Atualizar'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
