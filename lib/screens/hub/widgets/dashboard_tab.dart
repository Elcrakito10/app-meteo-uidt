import 'package:flutter/material.dart';
import '../../../models/city.dart';
import '../../../models/forecast_response.dart';
import '../../../models/weather_response.dart';
import '../../../theme/app_background.dart';
import '../../../utils/weather_icons.dart';
import '../../../utils/wind_direction.dart';
import '../../../widgets/daily_forecast_list.dart';
import '../../../widgets/hourly_forecast_list.dart';
import '../../weather_map/widgets/wind_arrow_indicator.dart';

/// Dashboard enrichi : synthèse pour la ville actuellement explorée dans
/// le Hub, avec indicateurs, prévisions horaires et quotidiennes. Réutilise
/// volontairement le même style GlassCard que le reste de l'app.
class DashboardTab extends StatelessWidget {
  final City city;
  final WeatherResponse weather;
  final ForecastResponse? forecast;
  final VoidCallback onOpenMap;

  const DashboardTab({
    super.key,
    required this.city,
    required this.weather,
    required this.forecast,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Text(city.name.isNotEmpty ? city.name : weather.cityName,
                    style: textTheme.headlineSmall),
                const SizedBox(height: 6),
                Icon(
                  WeatherIcons.fromCode(weather.primaryCondition.icon),
                  size: 56,
                  color: colors.secondary,
                ),
                Text('${weather.main.temp.round()}°',
                    style: textTheme.headlineMedium?.copyWith(fontSize: 52)),
                Text(weather.primaryCondition.description,
                    style: textTheme.bodyMedium),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Grille 2x2 (plutôt qu'une ligne de 4) pour rester robuste sur
          // petits écrans et éviter tout overflow horizontal (§23).
          Row(
            children: [
              Expanded(
                child: _MiniIndicator(
                  leading: WindArrowIndicator(
                    speedMs: weather.wind.speed,
                    directionDegrees: weather.wind.direction,
                    size: 20,
                  ),
                  label: 'Vent',
                  value: '${weather.wind.speed.round()} m/s',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniIndicator(
                  icon: Icons.explore_outlined,
                  label: 'Direction',
                  value: WindDirection.label(weather.wind.direction),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniIndicator(
                  icon: Icons.water_drop_outlined,
                  label: 'Humidité',
                  value: '${weather.main.humidity}%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniIndicator(
                  icon: Icons.speed_rounded,
                  label: 'Pression',
                  value: '${weather.main.pressure} hPa',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (forecast != null)
            HourlyForecastList(entries: forecast!.entries)
          else
            const Center(child: CircularProgressIndicator()),

          const SizedBox(height: 20),

          if (forecast != null) DailyForecastList(days: forecast!.dailyForecasts),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: onOpenMap,
            child: GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.map_rounded, color: colors.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Carte météo interactive',
                            style: textTheme.titleMedium),
                        Text('Vent, température, précipitations…',
                            style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: colors.onSurface.withValues(alpha: 0.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniIndicator extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String label;
  final String value;

  const _MiniIndicator({
    this.icon,
    this.leading,
    required this.label,
    required this.value,
  }) : assert(icon != null || leading != null,
            'Fournir soit icon, soit leading');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          leading ?? Icon(icon, color: colors.primary, size: 20),
          const SizedBox(height: 6),
          Text(value, style: textTheme.titleSmall),
          Text(label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
