enum RainIntensity { trace, light, moderate, heavy, extreme }

class WeatherForecast {
  final double accumulatedMm24h;
  final double maxIntensityMm3h;
  final String description;
  final String source;

  const WeatherForecast({
    required this.accumulatedMm24h,
    required this.maxIntensityMm3h,
    required this.description, required intensity, required this.source
  });

  RainIntensity get intensity => switch (accumulatedMm24h) {
        < 5 => RainIntensity.trace,
        < 25 => RainIntensity.light,
        < 50 => RainIntensity.moderate,
        < 100 => RainIntensity.heavy,
        _ => RainIntensity.extreme,
      };

  factory WeatherForecast.fromJson(Map<String, dynamic> j) => WeatherForecast(
        accumulatedMm24h: (j['accumulatedMm24h'] as num).toDouble(),
        maxIntensityMm3h: (j['maxIntensityMm3h'] as num).toDouble(),
        description: j['description'] as String,
        source: j['source'] as String, intensity: null,
      );

  Map<String, dynamic> toJson() => {
        'accumulatedMm24h': accumulatedMm24h,
        'maxIntensityMm3h': maxIntensityMm3h,
        'description': description,
        'source': source,
      };

  /// Fallback vazio quando nenhuma API responde
  factory WeatherForecast.empty() => const WeatherForecast(
        accumulatedMm24h: 0,
        maxIntensityMm3h: 0,
        description: 'Dados indisponíveis',
        source: 'N/A', intensity: null,
      );

  static intensityFromValue(double max3h) {}
}
