import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'exceptions.dart';

/// Point d'accès unique à la configuration de l'application.
///
/// Toute la lecture de clés API / variables d'environnement passe par cette
/// classe : aucun autre fichier ne doit lire `dotenv.env[...]` directement.
/// Cela évite de disperser la logique de configuration dans tout le projet
/// et facilite un changement de source de config plus tard si besoin.
class AppConfig {
  AppConfig._(); // classe statique, non instanciable

  /// Charge le fichier .env — à appeler une seule fois, avant runApp().
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get openWeatherApiKey {
    final key = dotenv.env['OPENWEATHER_API_KEY'];
    if (key == null || key.isEmpty || key == 'votre_cle_openweather_ici') {
      // Utilise la même hiérarchie d'exceptions que le reste de l'app
      // (voir core/exceptions.dart) : le repository et l'UI n'ont ainsi
      // qu'UN SEUL type d'erreur à gérer, quelle que soit son origine.
      throw const InvalidApiKeyException();
    }
    return key;
  }

  static String get googleMapsApiKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    return key ?? '';
  }

  /// URL de base de l'API météo (OpenWeatherMap).
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org';

  /// URL de base pour les tuiles météo (couches carte — écran Carte météo).
  static const String openWeatherTilesBaseUrl =
      'https://tile.openweathermap.org/map';

  /// Délai maximum avant timeout d'une requête réseau.
  static const Duration networkTimeout = Duration(seconds: 12);
}
