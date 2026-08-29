import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';

/// `google_maps_flutter` ne fournit pas de UrlTileProvider prêt à l'emploi :
/// il faut implémenter [TileProvider] soi-même. Ce provider télécharge une
/// vraie tuile PNG météo auprès du serveur de tuiles OpenWeatherMap pour
/// chaque (x, y, zoom) demandé par Google Maps.
class OwmTileProvider implements TileProvider {
  final String urlTemplate; // contient {z}/{x}/{y}
  final Dio dio;

  OwmTileProvider({required this.urlTemplate, required this.dio});

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final url = urlTemplate
        .replaceAll('{z}', '$zoom')
        .replaceAll('{x}', '$x')
        .replaceAll('{y}', '$y');

    try {
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? const []);
      if (bytes.isEmpty) {
        debugPrint('=== TUILE MÉTÉO VIDE === url=$url');
        return TileProvider.noTile;
      }
      return Tile(256, 256, bytes);
    } catch (e) {
      // Affiché en debug pour diagnostiquer précisément la cause réelle
      // (clé invalide, réseau, mauvais domaine...) plutôt que d'échouer
      // silencieusement sans aucune trace exploitable.
      debugPrint('=== ERREUR TUILE MÉTÉO ===');
      debugPrint('URL: $url');
      debugPrint('Erreur: $e');
      debugPrint('===========================');
      return TileProvider.noTile;
    }
  }
}x