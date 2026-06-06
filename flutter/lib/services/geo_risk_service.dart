import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:diacritic/diacritic.dart'; // para remover acentos

enum RiskLevel { none, low, moderate, high, veryHigh }

class GeoRiskService {
  static const String _mainUrl =
      'https://www.gov.br/cemaden/pt-br/assuntos/riscos-geo-hidrologicos';

  Future<String?> _getLatestBulletinUrl() async {
  final response = await http.get(Uri.parse(
    'https://www.gov.br/cemaden/pt-br/assuntos/riscos-geo-hidrologicos'
  ));
  if (response.statusCode != 200) return null;

  final document = html.parse(response.body);
  final link = document
      .querySelectorAll('a')
      .map((a) => a.attributes['href'])
      .firstWhere(
        (href) => href != null && href.contains('previsao-de-riscos-geo-hidrologicos'),
        orElse: () => null,
      );

  return link;
}

Future<RiskLevel> fetchFloodRiskByState(String uf, String stateName) async {
  try {
    final url = await _getLatestBulletinUrl();
    if (url == null) return RiskLevel.none;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return RiskLevel.none;

    var text = html.parse(response.body).body?.text ?? '';
    text = removeDiacritics(text).toLowerCase();

    // Procurar apenas o trecho que menciona o estado
    final regex = RegExp(
      r'(' + stateName.toLowerCase() + r'.*?)(alto|muito alto|moderado|baixo)',
      caseSensitive: false,
      dotAll: true,
    );

    final match = regex.firstMatch(text);
    if (match != null) {
      final trecho = match.group(0)!;
      if (trecho.contains('muito alto')) return RiskLevel.veryHigh;
      if (trecho.contains('alto')) return RiskLevel.high;
      if (trecho.contains('moderado')) return RiskLevel.moderate;
      if (trecho.contains('baixo')) return RiskLevel.low;
    }

    return RiskLevel.none;
  } catch (e) {
    debugPrint('[GeoRiskService] Erro: $e');
    return RiskLevel.none;
  }
}
}