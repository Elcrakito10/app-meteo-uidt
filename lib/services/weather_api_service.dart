import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/weather_response.dart';

part 'weather_api_service.g.dart';

/// Client API généré par Retrofit à partir de cette interface.
///
/// Le fichier `weather_api_service.g.dart` référencé par `part` sera généré
/// automatiquement par `build_runner` (commande donnée à la fin de cette
/// étape) — ne JAMAIS l'écrire à la main : il contiendrait sinon tout le
/// code Dio bas niveau (construction de la requête, sérialisation...) que
/// Retrofit génère pour nous, exactement ce que demande le cahier des
/// charges §14.
@RestApi()
abstract class WeatherApiService {
  factory WeatherApiService(Dio dio, {String baseUrl}) = _WeatherApiService;

  /// Météo actuelle pour un point GPS donné.
  /// Endpoint OpenWeatherMap : GET /data/2.5/weather
  @GET('/data/2.5/weather')
  Future<WeatherResponse> getCurrentWeather({
    @Query('lat') required double lat,
    @Query('lon') required double lon,
    @Query('appid') required String apiKey,
    @Query('units') String units = 'metric', // °C directement, pas Kelvin
    @Query('lang') String lang = 'fr', // descriptions météo en français
  });
}
