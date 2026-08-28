import 'package:flutter/material.dart';
import '../models/forecast_response.dart';
import '../theme/app_background.dart';
import '../utils/date_format_fr.dart';
import '../utils/weather_icons.dart';

/// Prévisions sur plusieurs jours, dérivées des vraies entrées 3h de
/// l'API (voir ForecastResponse.dailyForecasts) — jamais de valeur
/// inventée. L'endpoint gratuit ne couvrant que 5 jours, la section peut
/// afficher moins de 7 jours : c'est assumé plutôt que complété par des
/// données fictives.
class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> days;

  const DailyForecastList({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (days.isEmpty) return const SizedBox.shrink();

    final globalMin = days.map((d) => d.minTemp).reduce((a, b) => a < b ? a : b);
    final globalMax = days.map((d) => d.maxTemp).reduce((a, b) => a > b ? a : b);
    final range = (globalMax - globalMin) < 1 ? 1.0 : (globalMax - globalMin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prévisions sur ${days.length} jours', style: textTheme.titleMedium),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < days.length; i++) ...[
                _DayRow(
                  day: days[i],
                  isToday: i == 0,
                  globalMin: globalMin,
                  range: range,
                ),
                if (i != days.length - 1)
                  Divider(
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final DailyForecast day;
  final bool isToday;
  final double globalMin;
  final double range;

  const _DayRow({
    required this.day,
    required this.isToday,
    required this.globalMin,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final startFraction = ((day.minTemp - globalMin) / range).clamp(0.0, 1.0);
    final widthFraction = ((day.maxTemp - day.minTemp) / range).clamp(0.08, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              isToday ? 'Aujourd\'hui' : DateFormatFr.weekdayShort(day.date),
              style: textTheme.labelLarge,
            ),
          ),
          Icon(WeatherIcons.fromCode(day.condition.icon),
              size: 20, color: colors.secondary),
          const SizedBox(width: 8),
          if (day.maxPop > 0.1)
            Row(
              children: [
                Icon(Icons.water_drop_rounded, size: 12, color: colors.primary),
                Text('${(day.maxPop * 100).round()}%', style: textTheme.labelSmall),
                const SizedBox(width: 8),
              ],
            ),
          const Spacer(),
          SizedBox(
            width: 40,
            child: Text('${day.minTemp.round()}°',
                textAlign: TextAlign.right,
                style: textTheme.bodySmall
                    ?.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Positioned(
                      left: constraints.maxWidth * startFraction,
                      width: constraints.maxWidth * widthFraction,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.secondary, colors.primary],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text('${day.maxTemp.round()}°', style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
