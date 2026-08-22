import 'package:json_annotation/json_annotation.dart';

part 'weather_response.g.dart';

/// Modèle typé correspondant à la réponse de l'endpoint
/// `/data/2.5/weather` d'OpenWeatherMap pour UNE ville.
///
/// Le fichier `weather_response.g.dart` sera généré automatiquement par
/// `build_runner` (voir commandes à l'Étape 4) — ne jamais l'écrire à la main.
///
/// Certains champs sont volontairement nullable (`visibility`, `windGust`...)
/// car l'API ne les renvoie pas toujours pour toutes les villes : le
/// cahier des charges §5 demande de gérer proprement ces différences
/// plutôt que de supposer que tout est toujours présent.
@JsonSerializable(explicitToJson: true)
class WeatherResponse {
  @JsonKey(name: 'name')
  final String cityName;

  @JsonKey(name: 'main')
  final WeatherMain main;

  @JsonKey(name: 'weather')
  final List<WeatherCondition> conditions;

  @JsonKey(name: 'wind')
  final WeatherWind wind;

  @JsonKey(name: 'visibility')
  final int? visibility; // en mètres, absent parfois selon l'API

  @JsonKey(name: 'coord')
  final WeatherCoord coord;

  @JsonKey(name: 'dt')
  final int timestamp; // horodatage Unix de la mesure

  const WeatherResponse({
    required this.cityName,
    required this.main,
    required this.conditions,
    required this.wind,
    required this.coord,
    required this.timestamp,
    this.visibility,
  });

  /// Raccourci pratique : première (et généralement seule) condition météo.
  WeatherCondition get primaryCondition =>
      conditions.isNotEmpty ? conditions.first : WeatherCondition.unknown();

  factory WeatherResponse.fromJson(Map<String, dynamic> json) =>
      _$WeatherResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherResponseToJson(this);
}

@JsonSerializable()
class WeatherMain {
  final double temp;

  @JsonKey(name: 'feels_like')
  final double feelsLike;

  final int humidity;
  final int pressure;

  const WeatherMain({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
  });

  factory WeatherMain.fromJson(Map<String, dynamic> json) =>
      _$WeatherMainFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherMainToJson(this);
}

@JsonSerializable()
class WeatherCondition {
  final String main; // ex: "Rain", "Clear"
  final String description; // ex: "légère pluie"
  final String icon; // code icône OpenWeatherMap, ex: "10d"

  const WeatherCondition({
    required this.main,
    required this.description,
    required this.icon,
  });

  /// Condition de repli si l'API ne renvoie aucune entrée (cas limite,
  /// géré proprement plutôt que de crasher — cahier des charges §5).
  factory WeatherCondition.unknown() => const WeatherCondition(
        main: 'Unknown',
        description: 'Données indisponibles',
        icon: '01d',
      );

  factory WeatherCondition.fromJson(Map<String, dynamic> json) =>
      _$WeatherConditionFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherConditionToJson(this);
}

@JsonSerializable()
class WeatherWind {
  final double speed; // m/s

  @JsonKey(name: 'deg')
  final int? direction; // degrés, absent parfois

  @JsonKey(name: 'gust')
  final double? gust;

  const WeatherWind({
    required this.speed,
    this.direction,
    this.gust,
  });

  factory WeatherWind.fromJson(Map<String, dynamic> json) =>
      _$WeatherWindFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherWindToJson(this);
}

@JsonSerializable()
class WeatherCoord {
  final double lat;
  final double lon;

  const WeatherCoord({required this.lat, required this.lon});

  factory WeatherCoord.fromJson(Map<String, dynamic> json) =>
      _$WeatherCoordFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherCoordToJson(this);
}
