import 'package:flutter/material.dart';
import '../models/forecast_response.dart';
import '../theme/app_background.dart';
import '../utils/date_format_fr.dart';
import '../utils/weather_icons.dart';

/// Prévisions horaires défilables horizontalement. Les données viennent de
/// l'endpoint gratuit `/forecast` (pas de 3h) — le libellé "pas de 3h" est
/// assumé plutôt que de prétendre à une granularité horaire que l'API ne
/// fournit pas gratuitement.
class HourlyForecastList extends StatelessWidget {
  final List<ForecastEntry> entries;

  const HourlyForecastList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Prévisions', style: textTheme.titleMedium),
            const SizedBox(width: 6),
            Text('(pas de 3h)', style: textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: entries.length.clamp(0, 16),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                borderRadius: 16,
                child: SizedBox(
                  width: 62,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        index == 0 ? 'Maintenant' : DateFormatFr.hour(entry.dateTime),
                        style: textTheme.labelMedium,
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        WeatherIcons.fromCode(entry.primaryCondition.icon),
                        color: colors.secondary,
                        size: 24,
                      ),
                      Text('${entry.main.temp.round()}°',
                          style: textTheme.titleMedium),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_drop_rounded,
                              size: 11, color: colors.primary),
                          const SizedBox(width: 2),
                          Text('${(entry.pop * 100).round()}%',
                              style: textTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
