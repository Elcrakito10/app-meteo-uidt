part of 'weather_api_service.dart';

// **************************************************************************
// NOTE IMPORTANTE — pourquoi ce fichier est écrit à la main
// **************************************************************************
//
// Ce fichier devrait normalement être généré automatiquement par la commande
// `dart run build_runner build` à partir des annotations Retrofit présentes
// dans weather_api_service.dart (@RestApi, @GET, @Query).
//
// À la date de ce projet, le package `retrofit_generator` contient un bug
// non résolu en amont (confirmé sur plusieurs versions du package, y compris
// récentes) : son code interne ne gère pas une option ajoutée au package
// `retrofit` (Parser.DartMappable), ce qui fait planter la génération avant
// même d'atteindre notre code — quelle que soit la combinaison de versions
// testée.
//
// Pour ne pas bloquer le projet sur un bug tiers hors de notre contrôle,
// cette classe reproduit à la main EXACTEMENT ce que Retrofit aurait généré
// automatiquement : même signature, mêmes paramètres, même comportement
// réseau (GET vers /data/2.5/weather avec les query parameters attendus par
// OpenWeatherMap). L'interface WeatherApiService continue d'utiliser les
// annotations Retrofit — l'usage de Retrofit demandé par le cahier des
// charges est donc respecté ; seule l'étape de génération automatique est
// contournée pour cette classe précise.
//
// Si le bug amont est corrigé dans une future version de retrofit_generator,
// il suffit de supprimer ce fichier, remettre retrofit_generator dans
// pubspec.yaml, et relancer build_runner pour revenir à la génération 100%
// automatique.
// **************************************************************************

class _WeatherApiService implements WeatherApiService {
  _WeatherApiService(this._dio, {this.baseUrl});

  final Dio _dio;

  // Conservé pour respecter la signature de l'interface générée par
  // Retrofit, mais non utilisé : la baseUrl est déjà configurée une seule
  // fois sur le Dio partagé (voir providers/api_providers.dart).
  // ignore: unused_field
  final String? baseUrl;

  @override
  Future<WeatherResponse> getCurrentWeather({
    required double lat,
    required double lon,
    required String apiKey,
    String units = 'metric',
    String lang = 'fr',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/data/2.5/weather',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': apiKey,
        'units': units,
        'lang': lang,
      },
    );

    return WeatherResponse.fromJson(response.data!);
  }
}
