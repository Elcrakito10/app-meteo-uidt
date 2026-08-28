import 'package:flutter/material.dart';
import '../../../models/weather_response.dart';
import '../../../theme/app_background.dart';
import '../../../utils/weather_icons.dart';
import 'wind_arrow_indicator.dart';

/// Fiche météo flottante, affichée lorsqu'un utilisateur touche un point
/// de la carte. [placeLabel] vient du géocodage inverse quand disponible,
/// sinon les coordonnées brutes sont affichées — jamais un nom inventé.
class PointWeatherCard extends StatelessWidget {
  final String placeLabel;
  final WeatherResponse weather;
  final VoidCallback onSeeDetails;
  final VoidCallback onClose;

  const PointWeatherCard({
    super.key,
    required this.placeLabel,
    required this.weather,
    required this.onSeeDetails,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(placeLabel,
                    style: textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                WeatherIcons.fromCode(weather.primaryCondition.icon),
                size: 32,
                color: colors.secondary,
              ),
              const SizedBox(width: 10),
              Text('${weather.main.temp.round()}°C',
                  style: textTheme.headlineSmall),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Ressenti ${weather.main.feelsLike.round()}°',
                    style: textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  size: 15, color: colors.onSurface.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text('${weather.main.humidity}%', style: textTheme.labelSmall),
              const SizedBox(width: 16),
              WindArrowIndicator(
                speedMs: weather.wind.speed,
                directionDegrees: weather.wind.direction,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text('${weather.wind.speed.round()} m/s',
                  style: textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onSeeDetails,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Voir les détails'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
