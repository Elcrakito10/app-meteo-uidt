import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_config.dart';

/// Couches météo proposées sur l'écran Carte météo. Seules les couches
/// réellement servies par les tuiles gratuites d'OpenWeatherMap sont
/// marquées [isAvailable] = true ; les autres (Satellite, Radar, Alertes)
/// sont volontairement désactivées plutôt que simulées — ne jamais
/// présenter une donnée indisponible comme si elle existait.
enum WeatherMapLayer {
  wind('Vent', 'wind_new', '🌬️', isAvailable: true),
  temperature('Température', 'temp_new', '🌡️', isAvailable: true),
  precipitation('Précipitations', 'precipitation_new', '🌧️',
      isAvailable: true),
  clouds('Nuages', 'clouds_new', '☁️', isAvailable: true),
  pressure('Pression', 'pressure_new', '🧭', isAvailable: true),
  satellite('Satellite', 'satellite', '🛰️', isAvailable: false),
  radar('Radar', 'radar', '📡', isAvailable: false),
  alerts('Alertes', 'alerts', '⚠️', isAvailable: false);

  final String label;
  final String tileCode;
  final String emoji;
  final bool isAvailable;

  const WeatherMapLayer(this.label, this.tileCode, this.emoji,
      {required this.isAvailable});

  /// URL de tuile pour cette couche (template {z}/{x}/{y}).
  String tileUrlTemplate() =>
      '${AppConfig.openWeatherTilesBaseUrl}/$tileCode/{z}/{x}/{y}.png'
      '?appid=${AppConfig.openWeatherApiKey}';
}

/// Couche actuellement sélectionnée sur la carte (une seule à la fois,
/// pour rester lisible).
final selectedMapLayerProvider =
    StateProvider<WeatherMapLayer>((ref) => WeatherMapLayer.temperature);

/// Index de l'échéance temporelle sélectionnée dans le curseur, c.-à-d.
/// quelle entrée de prévision (parmi celles réellement renvoyées par
/// l'API) est actuellement affichée dans le panneau d'info sous la carte.
final selectedForecastIndexProvider = StateProvider<int>((ref) => 0);

/// Vrai pendant la lecture automatique du curseur temporel.
final isTimelinePlayingProvider = StateProvider<bool>((ref) => false);
