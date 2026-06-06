import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_forecast.dart';

class WeatherService {
  final _apiKey = dotenv.env['OPENWEATHER_API_KEY'];

  Future<WeatherForecast> fetchForecastByCoords(double lat, double lng) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lng&appid=$_apiKey&units=metric&lang=pt_br&cnt=8';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      return WeatherForecast.empty();
    }

    final jsonData = json.decode(response.body);
    double accumulated = 0.0;
    double max3h = 0.0;

    for (var item in jsonData['list']) {
      if (item['rain'] != null && item['rain']['3h'] != null) {
        final val = (item['rain']['3h'] as num).toDouble();
        accumulated += val;
        if (val > max3h) max3h = val;
      }
    }

    return WeatherForecast(
      accumulatedMm24h: accumulated,
      maxIntensityMm3h: max3h,
      intensity: WeatherForecast.intensityFromValue(max3h),
      source: 'OpenWeather',
      description: jsonData['list'][0]['weather'][0]['description'] ?? '',
    );
  }
}
