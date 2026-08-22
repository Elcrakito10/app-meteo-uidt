import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/city.dart';
import '../../models/weather_response.dart';
import '../../theme/app_background.dart';
import '../../utils/weather_icons.dart';

/// Écran détail d'une ville (cahier des charges §7). La section Google Maps
/// (§8) est volontairement un emplacement réservé propre à ce stade — elle
/// sera branchée à l'étape dédiée "Google Maps" avec la vraie clé API et le
/// marqueur. En attendant, les coordonnées GPS réelles sont déjà affichées
/// en texte, donc aucune information n'est perdue pour l'utilisateur.
class CityDetailScreen extends StatelessWidget {
  final City city;
  final WeatherResponse weather;

  const CityDetailScreen({
    super.key,
    required this.city,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      city.name,
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),

              // Bloc principal.
              _FadeInUp(
                delayMs: 0,
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'weather-icon-${city.name}',
                        child: Icon(
                          WeatherIcons.fromCode(weather.primaryCondition.icon),
                          size: 64,
                          color: colors.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weather.main.temp.round()}°',
                        style: textTheme.headlineMedium?.copyWith(fontSize: 60),
                      ),
                      Text(
                        weather.primaryCondition.description,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ressenti ${weather.main.feelsLike.round()}°',
                        style: textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Grille d'indicateurs complémentaires.
              _FadeInUp(
                delayMs: 100,
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.5,
                  children: [
                    _IndicatorCard(
                      icon: Icons.water_drop_outlined,
                      label: 'Humidité',
                      value: '${weather.main.humidity}%',
                    ),
                    _IndicatorCard(
                      icon: Icons.speed_rounded,
                      label: 'Pression',
                      value: '${weather.main.pressure} hPa',
                    ),
                    _IndicatorCard(
                      icon: Icons.air_rounded,
                      label: 'Vent',
                      value: '${weather.wind.speed.round()} m/s'
                          '${weather.wind.direction != null ? ' · ${weather.wind.direction}°' : ''}',
                    ),
                    _IndicatorCard(
                      icon: Icons.visibility_outlined,
                      label: 'Visibilité',
                      value: weather.visibility != null
                          ? '${(weather.visibility! / 1000).toStringAsFixed(1)} km'
                          : 'Non fournie',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bloc GPS + emplacement Google Maps (branché à l'étape suivante).
              _FadeInUp(
                delayMs: 200,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.place_rounded, color: colors.primary),
                          const SizedBox(width: 8),
                          Text('Localisation', style: textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lat ${weather.coord.lat.toStringAsFixed(4)}, '
                            'Lon ${weather.coord.lon.toStringAsFixed(4)}',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                weather.coord.lat,
                                weather.coord.lon,
                              ),
                              zoom: 11,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(city.name),
                                position: LatLng(
                                  weather.coord.lat,
                                  weather.coord.lon,
                                ),
                                infoWindow: InfoWindow(title: city.name),
                              ),
                            },
                            // Désactivé volontairement : cette mini-carte sert
                            // à situer la ville en un coup d'œil, pas à
                            // naviguer. L'exploration complète se fait via
                            // l'écran Carte météo (voir GUIDE_BINOME.md).
                            zoomGesturesEnabled: false,
                            scrollGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                            mapToolbarEnabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _IndicatorCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colors.primary, size: 22),
          const SizedBox(height: 8),
          Text(value, style: textTheme.titleMedium),
          Text(label, style: textTheme.labelLarge),
        ],
      ),
    );
  }
}

/// Petit helper d'animation d'apparition (fade + slide up) avec délai,
/// pour la cascade de blocs de l'écran détail.
class _FadeInUp extends StatelessWidget {
  final Widget child;
  final int delayMs;
  const _FadeInUp({required this.child, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}