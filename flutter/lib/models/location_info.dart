class LocationInfo {
  final String cityName;
  final String uf;         
  final String stateName; 
  final String ibgeCode;
  final int? cptecCityId;
  final double lat;
  final double lng;

  const LocationInfo({
    required this.cityName,
    required this.uf,
    required this.stateName,
    required this.ibgeCode,
    required this.cptecCityId,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'uf': uf,
        'stateName': stateName,
        'ibgeCode': ibgeCode,
        'cptecCityId': cptecCityId,
        'lat': lat,
        'lng': lng,
      };

  factory LocationInfo.fromJson(Map<String, dynamic> j) => LocationInfo(
        cityName: j['cityName'] as String,
        uf: j['uf'] as String,
        stateName: j['stateName'] as String,
        ibgeCode: j['ibgeCode'] as String,
        cptecCityId: j['cptecCityId'] as int?,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
      );
}
