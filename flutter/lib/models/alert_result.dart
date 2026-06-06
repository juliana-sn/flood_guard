import 'package:flutter/material.dart';
import 'flood_risk.dart';

enum AlertSeverity { info, safe, watch, warning, danger, emergency }

class AlertResult {
  final bool shouldAlert;
  final AlertSeverity severity;
  final String reason;

  const AlertResult({
    required this.shouldAlert,
    required this.severity,
    required this.reason,
  });

  Color get color => switch (severity) {
        AlertSeverity.info => const Color(0xFF4CAF50),
        AlertSeverity.safe => const Color(0xFF4CAF50),
        AlertSeverity.watch => const Color(0xFFFFEB3B),
        AlertSeverity.warning => const Color(0xFFFF9800),
        AlertSeverity.danger => const Color(0xFFFF7E7B),
        AlertSeverity.emergency => const Color(0xFFB71C1C),
      };

  String get displayTitle => switch (severity) {
        AlertSeverity.info => 'Sem risco identificado',
        AlertSeverity.safe => 'Seguro',
        AlertSeverity.watch => 'Atenção',
        AlertSeverity.warning => 'Alerta',
        AlertSeverity.danger => 'Perigo',
        AlertSeverity.emergency => 'Emergência',
      };
}

class AlertEngine {
  // Limiar de chuva (mm/24h) por nível de risco
  static const Map<RiskLevel, double> _rainfallThresholds = {
    RiskLevel.low: 80.0,   
    RiskLevel.medium: 50.0,
    RiskLevel.high: 30.0,
    RiskLevel.critical: 15.0,  
  };

  static AlertResult evaluate({
    required FloodRisk zoneRisk,
    required double forecastRainfallMm,
  }) {
    if (zoneRisk.level == RiskLevel.none) {
      return const AlertResult(
        shouldAlert: false,
        severity: AlertSeverity.info,
        reason: 'Nenhum risco mapeado pelo CEMADEN.',
      );
    }

    final threshold = _rainfallThresholds[zoneRisk.level] ?? 999;
    final shouldAlert = forecastRainfallMm >= threshold;

    return AlertResult(
      shouldAlert: shouldAlert,
      severity: _severityFor(zoneRisk.level, shouldAlert),
      reason: shouldAlert
          ? '${forecastRainfallMm.toStringAsFixed(1)}mm previstos em área de risco ${zoneRisk.displayTitle.toLowerCase()}.'
          : 'Chuva prevista (${forecastRainfallMm.toStringAsFixed(1)}mm) abaixo do limiar para esta área.',
    );
  }

  static AlertSeverity _severityFor(RiskLevel risk, bool alert) {
    if (!alert) return AlertSeverity.safe;
    return switch (risk) {
      RiskLevel.low => AlertSeverity.watch,
      RiskLevel.medium => AlertSeverity.warning,
      RiskLevel.high => AlertSeverity.danger,
      RiskLevel.critical => AlertSeverity.emergency,
      _ => AlertSeverity.info,
    };
  }
}
