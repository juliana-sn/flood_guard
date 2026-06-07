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

  CoordinatorResult copyWith({
    String? reason,
  }) {
    return CoordinatorResult(
      lat: lat,
      lng: lng,
      cityName: cityName,
      uf: uf,
      riskLevel: riskLevel,
      severityTitle: severityTitle,
      riskMessage: riskMessage,
      reason: reason ?? this.reason,
      rainfallMm: rainfallMm,
      weatherSource: weatherSource,
      shouldAlert: shouldAlert,
      colorValue: colorValue,
    );
  }
}

CoordinatorResult buildResult({
  required double lat,
  required double lng,
  required String cityName,
  required String uf,
  required String riskLevel,
  required double rainfallMm,
  required String weatherSource,
}) {
  late int colorValue;
  late String severityTitle;
  late String riskMessage;
  late bool shouldAlert;

  switch (riskLevel) {
  case "very_high":
    colorValue = 0xFFF44336; // Vermelho
    severityTitle = "Risco Muito Alto";
    riskMessage = "Alerta máximo de alagamento";
    shouldAlert = true;
    break;
  case "high":
    colorValue = 0xFFFF9800; // Laranja
    severityTitle = "Risco Alto";
    riskMessage = "Probabilidade elevada de alagamento";
    shouldAlert = true;
    break;
  case "moderate":
    colorValue = 0xFFFFEB3B; // Amarelo
    severityTitle = "Risco Moderado";
    riskMessage = "Possibilidade moderada de alagamento";
    shouldAlert = true;
    break;
  case "low":
  case "none": // 👈 trata 'none' como 'low'
    colorValue = 0xFF4CAF50; // Verde
    severityTitle = "Risco Baixo";
    riskMessage = "Baixa probabilidade de alagamento";
    shouldAlert = false;
    break;
  default:
    colorValue = 0xFF9E9E9E; // fallback cinza
    severityTitle = "Nenhum risco";
    riskMessage = "Nenhum risco mapeado";
    shouldAlert = false;
  }


  return CoordinatorResult(
    lat: lat,
    lng: lng,
    cityName: cityName,
    uf: uf,
    riskLevel: riskLevel,
    severityTitle: severityTitle,
    riskMessage: riskMessage,
    reason: "Análise meteorológica e hidrológica",
    rainfallMm: rainfallMm,
    weatherSource: weatherSource,
    shouldAlert: shouldAlert,
    colorValue: colorValue,
  );
}

class FloodAlertCoordinator {
  Future<CoordinatorResult> run() async {
    // Obter localização atual via GPS
    final position = await Geolocator.getCurrentPosition();
    final lat = position.latitude;
    final lng = position.longitude;

    // Buscar dados reais da API
    final data = await ApiClient.getRisk(lat, lng);

    // Extrair campos da resposta
    final cityName = data["cityName"] ?? "";
    final uf = data["uf"] ?? "";
    final riskLevel = data["riskLevel"] ?? "none";
    final rainfallMm = (data["rainfallMm"] as num?)?.toDouble() ?? 0.0;
    final weatherSource = data["weatherSource"] ?? "";
    final reason = data["reason"] ?? "Análise meteorológica e hidrológica";

    // Montar resultado com buildResult
    final result = buildResult(
      lat: lat,
      lng: lng,
      cityName: cityName,
      uf: uf,
      riskLevel: riskLevel,
      rainfallMm: rainfallMm,
      weatherSource: weatherSource,
    );

    // Sobrescrever reason se vier da API
    return result.copyWith(reason: reason);
  }
}
