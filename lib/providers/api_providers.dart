import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_config.dart';
import '../repositories/weather_repository.dart';
import '../services/weather_api_service.dart';

/// Instance Dio unique et configurée (timeout, base URL), partagée dans
/// toute l'application via Riverpod plutôt que recréée à chaque appel.
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.openWeatherBaseUrl,
      connectTimeout: AppConfig.networkTimeout,
      receiveTimeout: AppConfig.networkTimeout,
    ),
  );
});

/// Client Retrofit, construit à partir du Dio configuré ci-dessus.
final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService(ref.watch(dioProvider));
});

/// Repository météo — c'est CE provider que les écrans/notifiers utilisent,
/// jamais directement dioProvider ou weatherApiServiceProvider.
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(ref.watch(weatherApiServiceProvider));
});
