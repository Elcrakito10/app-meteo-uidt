import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/exceptions.dart';
import '../../models/city.dart';
import '../../models/city_weather_result.dart';
import '../../providers/weather_flow_provider.dart';
import '../../theme/app_background.dart';
import '../../utils/weather_icons.dart';
import '../../widgets/primary_button.dart';
import '../city_detail/city_detail_screen.dart';
import '../home/home_screen.dart';

/// Écran Résultats (cahier des charges §6) : présentation hybride
/// cartes/tableau des 5 villes, tapable pour ouvrir le détail, avec retry
/// individuel par ville et bouton Recommencer global.
class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  void _goHome(BuildContext context, WidgetRef ref) {
    ref.read(weatherFlowProvider.notifier).reset();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: const HomeScreen()),
      ),
      (route) => false,
    );
  }

  void _restart(WidgetRef ref) {
    ref.read(weatherFlowProvider.notifier).start(AppConstants.defaultCities);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(weatherFlowProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _goHome(context, ref),
                    icon: const Icon(Icons.home_rounded),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Résultats — Sénégal 🇸🇳',
                            style: textTheme.headlineMedium
                                ?.copyWith(fontSize: 20)),
                        Text(
                          'Mis à jour maintenant',
                          style: textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                itemCount: AppConstants.defaultCities.length,
                itemBuilder: (context, index) {
                  final city = AppConstants.defaultCities[index];
                  CityWeatherResult? result;
                  for (final r in flowState.results) {
                    if (r.city == city) {
                      result = r;
                      break;
                    }
                  }

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + index * 80),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset((1 - value) * 40, 0),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CityResultCard(city: city, result: result),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: PrimaryButton(
                label: 'Recommencer',
                icon: Icons.refresh_rounded,
                onPressed: () => _restart(ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityResultCard extends ConsumerWidget {
  final City city;
  final CityWeatherResult? result;

  const _CityResultCard({required this.city, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (result == null) {
      return GlassCard(
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 14),
            Text(city.name, style: textTheme.titleMedium),
          ],
        ),
      );
    }

    if (result is CityWeatherFailure) {
      final failure = result as CityWeatherFailure;
      return GlassCard(
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city.name, style: textTheme.titleMedium),
                  Text(
                    (failure.error as AppException).message,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(weatherFlowProvider.notifier).retryCity(city),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final success = result as CityWeatherSuccess;
    final weather = success.weather;

    return GlassCard(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: CityDetailScreen(city: city, weather: weather),
            ),
          ),
        );
      },
      child: Row(
        children: [
          Icon(
            WeatherIcons.fromCode(weather.primaryCondition.icon),
            size: 34,
            color: colors.secondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(city.name, style: textTheme.titleMedium),
                Text(
                  weather.primaryCondition.description,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            '${weather.main.temp.round()}°',
            style: textTheme.headlineMedium?.copyWith(fontSize: 26),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStat(
                  icon: Icons.water_drop_outlined,
                  value: '${weather.main.humidity}%'),
              const SizedBox(height: 4),
              _MiniStat(
                  icon: Icons.air_rounded,
                  value: '${weather.wind.speed.round()} m/s'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MiniStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: textTheme.labelLarge?.color),
        const SizedBox(width: 3),
        Text(value, style: textTheme.labelLarge),
      ],
    );
  }
}
