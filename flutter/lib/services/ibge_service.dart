import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_info.dart';

class IbgeService {
  static const String _nominatimUrl =
      'https://nominatim.openstreetmap.org/reverse';
  static const String _ibgeUrl =
      'https://servicodados.ibge.gov.br/api/v1/localidades/municipios';
  static const String _cptecUrl =
      'http://servicos.cptec.inpe.br/XML/listaCidades';

  Future<LocationInfo> resolveLocation(double lat, double lng) async {
    final nominatim = await _reverseGeocode(lat, lng);
    final ibgeCode =
        await _fetchIbgeCode(nominatim.cityName, nominatim.uf);
    final cptecId = await _fetchCptecId(nominatim.cityName);

    return LocationInfo(
      cityName: nominatim.cityName,
      uf: nominatim.uf,
      stateName: nominatim.stateName, // agora incluímos o nome completo
      ibgeCode: ibgeCode,
      cptecCityId: cptecId,
      lat: lat,
      lng: lng,
    );
  }

  Future<({String cityName, String uf, String stateName})> _reverseGeocode(
      double lat, double lng) async {
    final uri = Uri.parse(_nominatimUrl).replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lng.toString(),
      'format': 'json',
      'addressdetails': '1',
      'accept-language': 'pt-BR',
    });

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'FloodGuardApp/1.0'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Nominatim erro ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>;

    final city = (address['city'] ??
            address['town'] ??
            address['village'] ??
            address['municipality'] ??
            '') as String;

    final stateName = address['state'] as String? ?? '';
    final uf = _ufFromState(stateName);

    if (city.isEmpty) throw Exception('Município não encontrado nas coordenadas');

    return (cityName: city, uf: uf, stateName: stateName);
  }

  Future<String> _fetchIbgeCode(String cityName, String uf) async {
    try {
      final response = await http
          .get(Uri.parse('$_ibgeUrl?orderBy=nome'))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) throw Exception();

      final list = jsonDecode(response.body) as List;
      final normalized = _normalize(cityName);

      for (final item in list) {
        final nome = item['nome'] as String? ?? '';
        final siglaUf =
            (item['microrregiao']?['mesorregiao']?['UF']?['sigla'] as String?)
                    ?.toUpperCase() ??
                '';
        if (_normalize(nome) == normalized && siglaUf == uf.toUpperCase()) {
          return item['id'].toString();
        }
      }
      throw Exception('Município não encontrado no IBGE');
    } catch (_) {
      return '';
    }
  }

  Future<int?> _fetchCptecId(String cityName) async {
    try {
      final uri = Uri.parse(
          '$_cptecUrl?city=${Uri.encodeComponent(cityName)}');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;

      final normalized = _normalize(cityName);
      final ids = RegExp(r'<id>(\d+)</id>').allMatches(response.body);
      final names = RegExp(r'<nome>([^<]+)</nome>').allMatches(response.body);

      final idList = ids.map((m) => int.tryParse(m.group(1) ?? '')).toList();
      final nameList = names.map((m) => m.group(1) ?? '').toList();

      for (int i = 0; i < nameList.length; i++) {
        if (_normalize(nameList[i]) == normalized && i < idList.length) {
          return idList[i];
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[àáâãä]'), 'a')
      .replaceAll(RegExp(r'[èéêë]'), 'e')
      .replaceAll(RegExp(r'[ìíîï]'), 'i')
      .replaceAll(RegExp(r'[òóôõö]'), 'o')
      .replaceAll(RegExp(r'[ùúûü]'), 'u')
      .replaceAll(RegExp(r'[ç]'), 'c')
      .trim();

  String _ufFromState(String stateName) {
    const map = {
      'São Paulo': 'SP', 'Rio de Janeiro': 'RJ', 'Minas Gerais': 'MG',
      'Bahia': 'BA', 'Rio Grande do Sul': 'RS', 'Paraná': 'PR',
      'Santa Catarina': 'SC', 'Goiás': 'GO', 'Pernambuco': 'PE',
      'Ceará': 'CE', 'Pará': 'PA', 'Amazonas': 'AM', 'Maranhão': 'MA',
      'Mato Grosso': 'MT', 'Mato Grosso do Sul': 'MS', 'Espírito Santo': 'ES',
      'Piauí': 'PI', 'Alagoas': 'AL', 'Rio Grande do Norte': 'RN',
      'Paraíba': 'PB', 'Sergipe': 'SE', 'Rondônia': 'RO', 'Tocantins': 'TO',
      'Acre': 'AC', 'Amapá': 'AP', 'Roraima': 'RR', 'Distrito Federal': 'DF',
    };
    return map[stateName] ??
        (stateName.length >= 2
            ? stateName.substring(0, 2).toUpperCase()
            : 'BR');
  }
}
