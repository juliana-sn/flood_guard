import 'package:flutter/material.dart';
import 'package:lumen_orbit/controllers/maps_controller.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RiskMapScreen extends StatelessWidget {
  const RiskMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ChangeNotifierProvider<MapsController>(
        create: (context) => MapsController(),
        child: Builder(builder: (context) {
          final local = context.watch<MapsController>();

          String mensagem = local.erro == ''
              ? 'Latitude ${local.lat} | Longitude ${local.long}'
              : local.erro;

          return GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(local.lat, local.long),
          zoom: 5));
        }),
      ),
    );
  }
}
