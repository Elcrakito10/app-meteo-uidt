import '../models/city.dart';

/// Constantes globales de l'application.
class AppConstants {
  AppConstants._();

  /// Nom affiché de l'application.
  static const String appName = 'Ciel Sénégal';

  /// Slogan affiché sur l'écran d'accueil.
  static const String appTagline = 'La météo du Sénégal, en un instant.';

  /// Les 5 villes imposées par le cahier des charges, avec leurs
  /// coordonnées GPS réelles (utilisées pour l'appel API + Google Maps).
  static const List<City> defaultCities = [
    City(name: 'Dakar', latitude: 14.6928, longitude: -17.4467),
    City(name: 'Thiès', latitude: 14.7910, longitude: -16.9359),
    City(name: 'Saint-Louis', latitude: 16.0326, longitude: -16.4818),
    City(name: 'Kaolack', latitude: 14.1652, longitude: -16.0726),
    City(name: 'Ziguinchor', latitude: 12.5833, longitude: -16.2719),
  ];

  /// Messages dynamiques affichés pendant le chargement (écran Chargement).
  /// Changent automatiquement toutes les ~1.6s tant que le chargement dure.
  static const List<String> loadingMessages = [
    'Nous téléchargeons les données…',
    'Analyse des conditions météorologiques…',
    'Synchronisation des données…',
    'C\'est presque fini…',
    'Plus que quelques secondes…',
  ];
}
