import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lumen_orbit/controllers/maps_controller.dart';
import 'package:provider/provider.dart';

// Cores para o layout da tela e do overlay informativo
class AppColors {
  static const Color surface = Color(0xFFF5F5F5);
  static const Color primaryText = Color(0xFF1E1E1E);
  static const Color overlayBackground = Colors.white;
}

class RiskMapScreen extends StatelessWidget {
  const RiskMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ChangeNotifierProvider<MapsController>(
        create: (context) => MapsController(),
        child: Builder(
          builder: (context) {
            final local = context.watch<MapsController>();

            // Mantém a lógica de string para exibir coordenadas ou mensagens de erro do GPS
            String mensagem = local.erro == ''
                ? 'Lat: ${local.lat.toStringAsFixed(4)} | Long: ${local.long.toStringAsFixed(4)}'
                : local.erro;

            return Stack(
              children: [
                FlutterMap(
                  mapController: local.mapController,
                  options: MapOptions(
                    // Inicializa nas coordenadas do controller (atualizadas via GPS)
                    initialCenter: LatLng(local.lat, local.long),
                    // Zoom em 5.0 permite ver as cidades e as manchas climáticas regionais ao mesmo tempo
                    initialZoom: 20.0,
                    maxZoom: 18.0,
                    minZoom: 5.0,
                    onTap: (tapPosition, point) {
                      debugPrint('Toque no mapa nas coordenadas: $point');
                    },
                  ),
                  children: [
                    // CAMADA 1: Google Maps Convencional Colorido (Base do Mapa)
                    TileLayer(
                      urlTemplate: local.googleRoadmapUrl,
                      userAgentPackageName: 'com.lumenorbit.app',
                      retinaMode: RetinaMode.isHighDensity(context),
                    ),

                    // CAMADA 2: Radar Climático Dinâmico (RainViewer) por cima do Google Maps
                    TileLayer(
                      urlTemplate: local.weatherTileUrl,
                      retinaMode: RetinaMode.isHighDensity(context),
                      // Transição suave ao carregar novos blocos climáticos
                      tileDisplay: const TileDisplay.fadeIn(
                        duration: Duration(milliseconds: 300),
                      ),
                      // 0.55 de opacidade permite ver as nuvens/chuva sem cobrir os nomes das ruas e cidades
                    ),

                    // CAMADA 3: Marcador (Marker) de Localização do Usuário
                    MarkerLayer(
                      markers: [
                        if (local.lat != 0.0 && local.long != 0.0)
                          Marker(
                            point: LatLng(local.lat, local.long),
                            width: 45,
                            height: 45,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red, // Vermelho destaca perfeitamente no mapa claro
                              size: 45,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                // Card Informativo Superior flutuando sobre o mapa
                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: SafeArea(
                    top: false, // Evita padding duplo se usado dentro de layouts complexos
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.overlayBackground.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            local.erro == '' ? Icons.cloud_queue : Icons.error_outline,
                            color: local.erro == '' ? Colors.blue : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mensagem,
                              style: const TextStyle(
                                color: AppColors.primaryText, 
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}