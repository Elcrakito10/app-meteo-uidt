/// Convertit un angle météo (0–360°, convention "d'où vient le vent") en
/// point cardinal lisible. Donnée dérivée directement de la valeur réelle
/// de l'API — aucune direction n'est jamais inventée si `degrees` est nul.
class WindDirection {
  WindDirection._();

  static const _points = [
    'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
    'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
  ];

  static String label(int? degrees) {
    if (degrees == null) return '—';
    final index = (((degrees % 360) / 22.5) + 0.5).floor() % 16;
    return _points[index];
  }
}
