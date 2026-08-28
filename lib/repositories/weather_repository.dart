import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_config.dart';
import '../core/exceptions.dart';
import '../models/city.dart';
import '../models/city_weather_result.dart';
import '../models/weather_response.dart';
import '../models/forecast_response.dart';
import '../services/weather_api_service.dart';

/// Couche métier au-dessus du service API : c'est ICI, et nulle part
/// ailleurs, que les erreurs réseau brutes (DioException) sont converties
/// en exceptions métier typées (core/exceptions.dart). Les écrans et
/// providers ne manipulent jamais Dio directement.
class WeatherRepository {
  final WeatherApiService _apiService;

  WeatherRepository(this._apiService);

  /// Récupère la météo d'UNE ville. Lève une [AppException] typée en cas
  /// d'échec — jamais une exception brute non gérée.
  Future<WeatherResponse> fetchWeather(City city) async {
    try {
      return await _apiService.getCurrentWeather(
        lat: city.latitude,
        lon: city.longitude,
        apiKey: AppConfig.openWeatherApiKey, // peut lever InvalidApiKeyException
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on AppException {
      rethrow; // ex: InvalidApiKeyException venant de AppConfig
    } catch (_) {
      throw const InvalidDataException();
    }
  }

  /// Récupère les prévisions 5 jours / pas de 3h pour UNE ville. Alimente
  /// le dashboard, les prévisions horaires/quotidiennes et le curseur
  /// temporel de la carte météo.
  Future<ForecastResponse> fetchForecast(City city) async {
    try {
      return await _apiService.getForecast(
        lat: city.latitude,
        lon: city.longitude,
        apiKey: AppConfig.openWeatherApiKey,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const InvalidDataException();
    }
  }

  /// Récupère la météo des [cities] EN PARALLÈLE, ville par ville, sans
  /// jamais laisser l'échec d'une ville empêcher les autres de s'afficher.
  ///
  /// [onProgress] est appelé à chaque ville terminée (succès OU échec),
  /// ce qui permet à l'écran Chargement de faire progresser la jauge en
  /// suivant l'avancement RÉEL des requêtes (cahier des charges §4),
  /// plutôt qu'un minuteur déconnecté du réseau.
  Future<List<CityWeatherResult>> fetchAllWeather(
      List<City> cities, {
        void Function(int completed, int total)? onProgress,
      }) async {
    int completed = 0;

    final futures = cities.map((city) async {
      try {
        final weather = await fetchWeather(city);
        completed++;
        onProgress?.call(completed, cities.length);
        return CityWeatherSuccess(city, weather) as CityWeatherResult;
      } on AppException catch (e) {
        completed++;
        onProgress?.call(completed, cities.length);
        return CityWeatherFailure(city, e) as CityWeatherResult;
      }
    });

    return Future.wait(futures);
  }

  /// Traduit une DioException (erreur bas niveau réseau/HTTP) en exception
  /// métier typée, couvrant tous les cas exigés par le cahier des charges §9.
  AppException _mapDioException(DioException e) {
    // Affichage de debug UNIQUEMENT en mode développement (jamais visible
    // par l'utilisateur final), pour diagnostiquer précisément la cause
    // réelle d'un échec réseau plutôt que de deviner.
    debugPrint('=== ERREUR RÉSEAU RÉELLE ===');
    debugPrint('Type: ${e.type}');
    debugPrint('Message: ${e.message}');
    debugPrint('Status code: ${e.response?.statusCode}');
    debugPrint('Response data: ${e.response?.data}');
    debugPrint('============================');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutAppException();

      case DioExceptionType.connectionError:
        return const NoConnectionException();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const InvalidApiKeyException();
        }
        return HttpAppException(statusCode);

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnknownAppException();
    }
  }
}