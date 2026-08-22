import '../core/exceptions.dart';
import 'city.dart';
import 'weather_response.dart';

/// Résultat de l'appel météo pour UNE ville : soit un succès avec les
/// données, soit un échec avec l'exception typée. Ce design permet de
/// charger les 5 villes en parallèle SANS qu'une seule ville en échec ne
/// fasse tomber les 4 autres (cahier des charges §9 : gestion d'erreurs
/// professionnelle + §6 : afficher les résultats malgré des erreurs
/// partielles).
sealed class CityWeatherResult {
  final City city;
  const CityWeatherResult(this.city);
}

class CityWeatherSuccess extends CityWeatherResult {
  final WeatherResponse weather;
  const CityWeatherSuccess(super.city, this.weather);
}

class CityWeatherFailure extends CityWeatherResult {
  final AppException error;
  const CityWeatherFailure(super.city, this.error);
}
