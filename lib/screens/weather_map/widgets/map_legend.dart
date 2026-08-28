import 'package:flutter/material.dart';
import '../../../providers/weather_map_provider.dart';
import '../../../theme/app_background.dart';

/// Légende dynamique : change automatiquement d'échelle et d'unité selon
/// la couche active. Les paliers affichés correspondent aux plages
/// usuelles de chaque grandeur météo, à titre indicatif visuel.
class MapLegend extends StatelessWidget {
  final WeatherMapLayer layer;

  const MapLegend({super.key, required this.layer});

  ({String unit, List<String> steps, List<Color> colors}) _config() {
    switch (layer) {
      case WeatherMapLayer.temperature:
        return (
          unit: '°C',
          steps: const ['-10', '10', '20', '30', '40+'],
          colors: const [
            Color(0xFF4D7CFE), Color(0xFF63D2A6), Color(0xFFF5D452),
            Color(0xFFF59452), Color(0xFFE14B4B),
          ],
        );
      case WeatherMapLayer.wind:
        return (
          unit: 'km/h',
          steps: const ['5', '20', '40', '60+'],
          colors: const [
            Color(0xFFB9D6FF), Color(0xFF6FA8FF), Color(0xFF3E6FE0),
            Color(0xFF1E3D8F),
          ],
        );
      case WeatherMapLayer.precipitation:
        return (
          unit: 'mm',
          steps: const ['0', '5', '20', '50+'],
          colors: const [
            Color(0xFFDCEEFF), Color(0xFF7FC4FF), Color(0xFF3E8FE0),
            Color(0xFF1B4E9C),
          ],
        );
      case WeatherMapLayer.pressure:
        return (
          unit: 'hPa',
          steps: const ['980', '1000', '1020', '1040'],
          colors: const [
            Color(0xFFB985E8), Color(0xFF8FA6F0), Color(0xFF63D2A6),
            Color(0xFFF5D452),
          ],
        );
      case WeatherMapLayer.clouds:
        return (
          unit: '%',
          steps: const ['0', '25', '50', '75', '100'],
          colors: const [
            Color(0xFFEAF0FF), Color(0xFFC7D3EA), Color(0xFF9FB0D0),
            Color(0xFF6B7BA3), Color(0xFF3E4A6B),
          ],
        );
      case WeatherMapLayer.satellite:
      case WeatherMapLayer.radar:
      case WeatherMapLayer.alerts:
        return (unit: '', steps: const [], colors: const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!layer.isAvailable) return const SizedBox.shrink();
    final c = _config();
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(c.unit, style: textTheme.labelMedium),
          const SizedBox(height: 6),
          Container(
            height: 8,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(colors: c.colors),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final step in c.steps) ...[
                Text(step, style: textTheme.labelSmall),
                if (step != c.steps.last) const SizedBox(width: 18),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
