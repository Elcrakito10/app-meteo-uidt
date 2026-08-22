import 'package:flutter/material.dart';

/// Traduit un code icône OpenWeatherMap (ex: "01d", "10n") en icône Material
/// cohérente avec l'identité visuelle de l'app. Centralisé ici pour que
/// TOUS les écrans (résultats, détail, carte météo) utilisent exactement
/// les mêmes icônes pour la même condition météo.
class WeatherIcons {
  WeatherIcons._();

  static IconData fromCode(String code) {
    // Les 2 premiers caractères identifient la condition ; le suffixe
    // d/n indique jour/nuit (utile pour distinguer ciel clair jour/nuit).
    final condition = code.length >= 2 ? code.substring(0, 2) : '01';
    final isNight = code.endsWith('n');

    switch (condition) {
      case '01': // ciel dégagé
        return isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded;
      case '02': // peu nuageux
        return isNight
            ? Icons.nights_stay_rounded
            : Icons.wb_cloudy_rounded;
      case '03': // nuages épars
      case '04': // couvert
        return Icons.cloud_rounded;
      case '09': // averses
        return Icons.grain_rounded;
      case '10': // pluie
        return Icons.water_drop_rounded;
      case '11': // orage
        return Icons.bolt_rounded;
      case '13': // neige
        return Icons.ac_unit_rounded;
      case '50': // brume/brouillard
        return Icons.foggy;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
