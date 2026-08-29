import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../../core/constants.dart';
import '../../core/exceptions.dart';
import '../../models/city.dart';
import '../../models/city_weather_result.dart';
import '../../models/weather_response.dart';
import '../../providers/api_providers.dart';
import '../../providers/forecast_provider.dart';
import '../../providers/weather_map_provider.dart';
import '../city_detail/city_detail_screen.dart';
import 'widgets/layer_selector_sheet.dart';
import 'widgets/map_legend.dart';
import 'widgets/owm_tile_provider.dart';
import 'widgets/point_weather_card.dart';
import 'widgets/weather_time_slider.dart';
import 'widgets/wind_arrow_indicator.dart';

/// Écran "Carte météo interactive". Reçoit une ville de départ (pour
/// centrer la carte et alimenter le curseur temporel), mais reste
/// explorable librement partout ailleurs sur la carte — écran additif,
/// indépendant du flux principal (Accueil → Chargement → Résultats →
/// Détail), qui n'est jamais modifié par cet écran.
class WeatherMapScreen extends ConsumerStatefulWidget {
  final City initialCity;

  const WeatherMapScreen({super.key, required this.initialCity});

  @override
  ConsumerState<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends ConsumerState<WeatherMapScreen> {
  GoogleMapController? _mapController;

  LatLng? _tappedPoint;
  String? _tappedLabel;
  WeatherResponse? _tappedWeather;
  bool _isLoadingTap = false;
  String? _tapError;

  bool _isLocating = false;
  String? _locationError;

  // Position écran (pixels logiques) de chaque ville, recalculée à chaque
  // déplacement de la caméra — nécessaire pour positionner les flèches de
  // vent (widgets Flutter classiques) par-dessus la carte native.
  final Map<String, Offset> _cityScreenPositions = {};

  Future<void> _refreshCityScreenPositions() async {
    final controller = _mapController;
    if (controller == null || !mounted) return;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final updated = <String, Offset>{};
    for (final city in AppConstants.defaultCities) {
      final screenCoord = await controller.getScreenCoordinate(
        LatLng(city.latitude, city.longitude),
      );
      updated[city.name] = Offset(
        screenCoord.x / dpr,
        screenCoord.y / dpr,
      );
    }
    if (!mounted) return;
    setState(() => _cityScreenPositions
      ..clear()
      ..addAll(updated));
  }

  @override
  Widget build(BuildContext context) {
    final selectedLayer = ref.watch(selectedMapLayerProvider);
    final forecastAsync = ref.watch(forecastProvider(widget.initialCity));
    final selectedIndex = ref.watch(selectedForecastIndexProvider);
    final isPlaying = ref.watch(isTimelinePlayingProvider);
    final dio = ref.watch(dioProvider);

    final bottomOffset = forecastAsync.maybeWhen(
      data: (f) => f.entries.isEmpty ? 100.0 : 168.0,
      orElse: () => 100.0,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.initialCity.latitude,
                widget.initialCity.longitude,
              ),
              zoom: 7,
            ),
            onMapCreated: (c) {
              _mapController = c;
              WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _refreshCityScreenPositions(),
              );
            },
            onCameraIdle: _refreshCityScreenPositions,
            markers: {
              for (final city in AppConstants.defaultCities)
                Marker(
                  markerId: MarkerId(city.name),
                  position: LatLng(city.latitude, city.longitude),
                  infoWindow: InfoWindow(title: city.name),
                ),
            },
            tileOverlays: selectedLayer.isAvailable
                ? {
              TileOverlay(
                tileOverlayId: TileOverlayId(selectedLayer.tileCode),
                tileProvider: OwmTileProvider(
                  urlTemplate: selectedLayer.tileUrlTemplate(),
                  dio: dio,
                ),
              ),
            }
                : {},
            onTap: _onMapTap,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // Flèches de vent réelles, uniquement quand la couche Vent est
          // active, positionnées sur les 5 villes dont on connaît les vraies
          // vitesse/direction — jamais un champ de particules inventé.
          if (selectedLayer == WeatherMapLayer.wind)
            ref.watch(mapCitiesWindDataProvider).maybeWhen(
              data: (results) => Stack(
                children: [
                  for (final result in results)
                    if (result is CityWeatherSuccess &&
                        _cityScreenPositions
                            .containsKey(result.city.name))
                      Positioned(
                        left: _cityScreenPositions[result.city.name]!.dx -
                            18,
                        top: _cityScreenPositions[result.city.name]!.dy -
                            42,
                        child: IgnorePointer(
                          child: WindArrowIndicator(
                            speedMs: result.weather.wind.speed,
                            directionDegrees:
                            result.weather.wind.direction,
                            size: 36,
                          ),
                        ),
                      ),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),

          Positioned(
            top: 8,
            left: 8,
            child: SafeArea(
              child: _RoundIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: _RoundIconButton(
                icon: Icons.layers_rounded,
                onTap: () => _openLayerSelector(context),
              ),
            ),
          ),

          Positioned(
            left: 12,
            bottom: bottomOffset,
            child: MapLegend(layer: selectedLayer),
          ),

          Positioned(
            right: 12,
            bottom: bottomOffset,
            child: _RoundIconButton(
              icon: _isLocating
                  ? Icons.hourglass_top_rounded
                  : Icons.my_location_rounded,
              onTap: _isLocating ? null : _goToMyLocation,
            ),
          ),

          if (_tappedPoint != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomOffset - 10,
              child: _buildTapCard(),
            ),

          if (_locationError != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _locationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: forecastAsync.when(
                data: (forecast) => WeatherTimeSlider(
                  entries: forecast.entries,
                  selectedIndex: selectedIndex,
                  isPlaying: isPlaying,
                  onIndexChanged: (i) =>
                  ref.read(selectedForecastIndexProvider.notifier).state = i,
                  onPlayingChanged: (v) =>
                  ref.read(isTimelinePlayingProvider.notifier).state = v,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapCard() {
    if (_isLoadingTap) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_tapError != null) {
      return Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(child: Text(_tapError!)),
              IconButton(
                onPressed: () => setState(() {
                  _tappedPoint = null;
                  _tapError = null;
                }),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      );
    }
    if (_tappedWeather == null) return const SizedBox.shrink();
    return PointWeatherCard(
      placeLabel: _tappedLabel ?? 'Position sélectionnée',
      weather: _tappedWeather!,
      onClose: () => setState(() {
        _tappedPoint = null;
        _tappedWeather = null;
      }),
      onSeeDetails: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CityDetailScreen(
              city: City(
                name: _tappedLabel ?? 'Position sélectionnée',
                latitude: _tappedPoint!.latitude,
                longitude: _tappedPoint!.longitude,
              ),
              weather: _tappedWeather!,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _tappedPoint = point;
      _tappedWeather = null;
      _tapError = null;
      _isLoadingTap = true;
      _tappedLabel = null;
    });

    try {
      final repository = ref.read(weatherRepositoryProvider);
      final weather = await repository.fetchWeather(
        City(name: '', latitude: point.latitude, longitude: point.longitude),
      );

      String? label;
      try {
        final placemarks = await geocoding.Geocoding().placemarkFromCoordinates(
          point.latitude,
          point.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          label = (p.locality != null && p.locality!.isNotEmpty)
              ? p.locality
              : ((p.subAdministrativeArea != null &&
              p.subAdministrativeArea!.isNotEmpty)
              ? p.subAdministrativeArea
              : p.administrativeArea);
        }
      } catch (_) {
        // Géocodage inverse indisponible : on retombe sur les coordonnées,
        // jamais sur un nom de ville inventé.
      }

      if (!mounted) return;
      setState(() {
        _tappedWeather = weather;
        _tappedLabel = label ??
            '${point.latitude.toStringAsFixed(2)}, '
                '${point.longitude.toStringAsFixed(2)}';
        _isLoadingTap = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _tapError = e.message;
        _isLoadingTap = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tapError = 'Une erreur inattendue est survenue.';
        _isLoadingTap = false;
      });
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Le service de localisation est désactivé sur cet appareil.';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw 'Permission de localisation refusée. Activez-la dans les '
            'paramètres de l\'application pour utiliser cette fonction.';
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Permission de localisation bloquée définitivement. '
            'Activez-la manuellement dans les paramètres du téléphone.';
      }

      final position = await Geolocator.getCurrentPosition();
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          10,
        ),
      );
      await _onMapTap(LatLng(position.latitude, position.longitude));
    } catch (e) {
      if (!mounted) return;
      setState(() => _locationError = e.toString());
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _openLayerSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(selectedMapLayerProvider);
            return LayerSelectorSheet(
              selected: selected,
              onSelect: (layer) {
                ref.read(selectedMapLayerProvider.notifier).state = layer;
                Navigator.of(sheetContext).pop();
              },
            );
          },
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: colors.onSurface, size: 22),
        ),
      ),
    );
  }
}