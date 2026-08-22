/// Représente une ville à interroger (les 5 villes imposées, ou une ville
/// trouvée via la recherche de l'écran Carte météo).
///
/// Volontairement un modèle "maison" simple (pas de JSON à parser ici,
/// contrairement à WeatherResponse) : ces données viennent soit des
/// constantes internes (les 5 villes), soit du géocodage.
class City {
  final String name;
  final double latitude;
  final double longitude;

  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(name, latitude, longitude);
}
