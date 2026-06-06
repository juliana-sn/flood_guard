import 'package:flutter/material.dart';

enum RiskLevel { none, low, medium, high, critical }

class FloodRisk {
  final RiskLevel level;
  final double rainfallMm;
  final bool isAlert;
  final String message;

  const FloodRisk({
    required this.level,
    required this.rainfallMm,
    required this.isAlert,
    required this.message,
  });

  factory FloodRisk.none() => const FloodRisk(
        level: RiskLevel.none,
        rainfallMm: 0,
        isAlert: false,
        message: 'Nenhum risco identificado ou área sem mapeamento',
      );

  factory FloodRisk.fromLevel(int level) {
    final riskLevel = switch (level) {
      1 => RiskLevel.low,
      2 => RiskLevel.medium,
      3 => RiskLevel.high,
      4 => RiskLevel.critical,
      _ => RiskLevel.none,
    };
    return FloodRisk(
      level: riskLevel,
      rainfallMm: 0,
      isAlert: level >= 3,
      message: _messageFor(riskLevel),
    );
  }

  factory FloodRisk.fromJson(Map<String, dynamic> j) => FloodRisk(
        level: RiskLevel.values[j['levelIndex'] as int],
        rainfallMm: (j['rainfallMm'] as num).toDouble(),
        isAlert: j['isAlert'] as bool,
        message: j['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'levelIndex': level.index,
        'rainfallMm': rainfallMm,
        'isAlert': isAlert,
        'message': message,
      };

  static String _messageFor(RiskLevel level) => switch (level) {
        RiskLevel.none => 'Nenhum risco identificado ou área sem mapeamento',
        RiskLevel.low => 'Risco baixo de deslizamento/enchente',
        RiskLevel.medium => 'Risco moderado — fique atento',
        RiskLevel.high => 'Alto risco — evite áreas de várzea',
        RiskLevel.critical => 'Risco crítico — saia da área imediatamente',
      };

  /// Cor associada ao nível de risco (compatível com o tema do app)
  Color get color => switch (level) {
        RiskLevel.none => Colors.grey,
        RiskLevel.low => const Color(0xFF4CAF50),
        RiskLevel.medium => const Color(0xFFFFEB3B),
        RiskLevel.high => const Color(0xFFFF9800),
        RiskLevel.critical => const Color(0xFFFF7E7B),
      };

  /// Título amigável para exibição nas telas
  String get displayTitle => switch (level) {
        RiskLevel.none => 'Sem risco identificado',
        RiskLevel.low => 'Baixo',
        RiskLevel.medium => 'Moderado',
        RiskLevel.high => 'Alto',
        RiskLevel.critical => 'Crítico',
      };
}
