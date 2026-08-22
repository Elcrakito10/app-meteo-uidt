import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/exceptions.dart';
import '../models/city.dart';
import '../models/city_weather_result.dart';
import 'api_providers.dart';

/// État complet du flux météo : progression de la jauge, résultats par
/// ville, indicateur de chargement global. Un seul state partagé entre
/// l'écran Chargement et l'écran Résultats, pour qu'ils restent toujours
/// synchronisés.
class WeatherFlowState {
  final List<CityWeatherResult> results;
  final int completedCount;
  final int totalCount;
  final bool isLoading;

  const WeatherFlowState({
    this.results = const [],
    this.completedCount = 0,
    this.totalCount = 0,
    this.isLoading = false,
  });

  /// Progression réelle entre 0.0 et 1.0, pilotée par les appels API
  /// effectivement terminés — pas une animation simulée.
  double get progress => totalCount == 0 ? 0.0 : completedCount / totalCount;

  bool get isComplete => totalCount > 0 && completedCount >= totalCount;

  /// Vrai si TOUTES les villes ont échoué (cas à distinguer d'un échec
  /// partiel, pour lequel on affiche quand même les villes réussies).
  bool get isTotalFailure =>
      isComplete && results.isNotEmpty && results.every((r) => r is CityWeatherFailure);

  WeatherFlowState copyWith({
    List<CityWeatherResult>? results,
    int? completedCount,
    int? totalCount,
    bool? isLoading,
  }) {
    return WeatherFlowState(
      results: results ?? this.results,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WeatherFlowNotifier extends StateNotifier<WeatherFlowState> {
  final Ref _ref;

  WeatherFlowNotifier(this._ref) : super(const WeatherFlowState());

  /// Lance (ou relance intégralement) l'expérience météo pour la liste de
  /// villes donnée. Appelé au démarrage de l'écran Chargement ET par le
  /// bouton "Recommencer" (cahier des charges §11).
  Future<void> start(List<City> cities) async {
    state = WeatherFlowState(totalCount: cities.length, isLoading: true);

    final repository = _ref.read(weatherRepositoryProvider);

    final results = await repository.fetchAllWeather(
      cities,
      onProgress: (completed, total) {
        // Chaque ville terminée fait avancer la jauge d'un cran réel.
        state = state.copyWith(completedCount: completed);
      },
    );

    state = state.copyWith(results: results, isLoading: false);
  }

  /// Relance UNIQUEMENT la requête d'une ville en échec (bouton "Réessayer"
  /// sur une carte individuelle de l'écran Résultats), sans toucher aux
  /// 4 autres villes déjà chargées.
  Future<void> retryCity(City city) async {
    final repository = _ref.read(weatherRepositoryProvider);
    try {
      final weather = await repository.fetchWeather(city);
      _replaceResult(CityWeatherSuccess(city, weather));
    } on AppException catch (e) {
      _replaceResult(CityWeatherFailure(city, e));
    }
  }

  void _replaceResult(CityWeatherResult updated) {
    final newResults = [
      for (final r in state.results)
        if (r.city == updated.city) updated else r,
    ];
    state = state.copyWith(results: newResults);
  }

  /// Réinitialise complètement l'état (retour à l'accueil).
  void reset() {
    state = const WeatherFlowState();
  }
}

final weatherFlowProvider =
    StateNotifierProvider<WeatherFlowNotifier, WeatherFlowState>((ref) {
  return WeatherFlowNotifier(ref);
});
