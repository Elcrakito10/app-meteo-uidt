import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../models/forecast_response.dart';
import 'api_providers.dart';

/// Prévisions (5 jours / pas de 3h) pour une ville donnée, mises en cache
/// automatiquement par Riverpod tant que la [City] ne change pas.
final forecastProvider =
    FutureProvider.family<ForecastResponse, City>((ref, city) async {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.fetchForecast(city);
});
