import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/exceptions.dart';
import '../../models/city.dart';
import '../../models/forecast_response.dart';
import '../../models/weather_response.dart';
import '../../providers/api_providers.dart';
import '../../widgets/city_search_field.dart';
import '../../widgets/daily_forecast_list.dart';
import '../../widgets/hourly_forecast_list.dart';
import '../weather_map/weather_map_screen.dart';
import 'widgets/dashboard_tab.dart';

/// Écran "Hub" additif : point d'entrée de l'expérience étendue pour une
/// ville, avec navigation par onglets en bas (Dashboard / Carte /
/// Prévisions) et recherche de ville libre. Entièrement indépendant du
/// flux principal (Accueil → Chargement → Résultats → Détail) — ce
/// dernier n'est jamais modifié ni requis pour que cet écran fonctionne.
class WeatherHubScreen extends ConsumerStatefulWidget {
  final City initialCity;
  final WeatherResponse initialWeather;

  const WeatherHubScreen({
    super.key,
    required this.initialCity,
    required this.initialWeather,
  });

  @override
  ConsumerState<WeatherHubScreen> createState() => _WeatherHubScreenState();
}

class _WeatherHubScreenState extends ConsumerState<WeatherHubScreen> {
  int _tabIndex = 0;
  bool _showSearch = false;

  late City _city;
  late WeatherResponse _weather;
  ForecastResponse? _forecast;
  bool _isLoadingCity = false;
  String? _cityError;

  @override
  void initState() {
    super.initState();
    _city = widget.initialCity;
    _weather = widget.initialWeather;
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    final repository = ref.read(weatherRepositoryProvider);
    try {
      final forecast = await repository.fetchForecast(_city);
      if (!mounted) return;
      setState(() => _forecast = forecast);
    } on AppException {
      // Les prévisions sont un complément : un échec ici ne doit jamais
      // empêcher le reste du Hub (dashboard courant, carte) de fonctionner.
      if (!mounted) return;
      setState(() => _forecast = null);
    }
  }

  Future<void> _onCitySelected(City city) async {
    setState(() {
      _isLoadingCity = true;
      _cityError = null;
      _showSearch = false;
      _forecast = null;
    });

    final repository = ref.read(weatherRepositoryProvider);
    try {
      final weather = await repository.fetchWeather(city);
      if (!mounted) return;
      setState(() {
        _city = city;
        _weather = weather;
        _isLoadingCity = false;
      });
      _loadForecast();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _cityError = e.message;
        _isLoadingCity = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _tabIndex == 1
          ? null // la carte occupe tout l'écran, sans AppBar par-dessus
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(_tabIndex == 0 ? 'Dashboard' : 'Prévisions'),
              actions: [
                IconButton(
                  onPressed: () => setState(() => _showSearch = !_showSearch),
                  icon: Icon(
                      _showSearch ? Icons.close_rounded : Icons.search_rounded),
                ),
              ],
              bottom: _showSearch
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(64),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: CitySearchField(onCityFound: _onCitySelected),
                      ),
                    )
                  : null,
            ),
      body: Stack(
        children: [
          IndexedStack(
            index: _tabIndex,
            children: [
              DashboardTab(
                city: _city,
                weather: _weather,
                forecast: _forecast,
                onOpenMap: () => setState(() => _tabIndex = 1),
              ),
              WeatherMapScreen(initialCity: _city),
              _ForecastTab(forecast: _forecast, cityName: _city.name),
            ],
          ),
          if (_isLoadingCity)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (_cityError != null)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_cityError!,
                              style: TextStyle(color: colors.onErrorContainer)),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _cityError = null),
                          icon: Icon(Icons.close_rounded,
                              color: colors.onErrorContainer),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Carte',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Prévisions',
          ),
        ],
      ),
    );
  }
}

class _ForecastTab extends StatelessWidget {
  final ForecastResponse? forecast;
  final String cityName;

  const _ForecastTab({required this.forecast, required this.cityName});

  @override
  Widget build(BuildContext context) {
    if (forecast == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cityName.isNotEmpty) ...[
            Text(cityName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
          ],
          HourlyForecastList(entries: forecast!.entries),
          const SizedBox(height: 20),
          DailyForecastList(days: forecast!.dailyForecasts),
        ],
      ),
    );
  }
}
