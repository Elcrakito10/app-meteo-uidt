import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../models/city.dart';

/// Recherche de ville libre, au-delà des 5 villes imposées par le cahier
/// des charges. Utilise `geocoding` (déjà une dépendance du projet) pour
/// convertir un nom saisi en coordonnées réelles — jamais de ville
/// inventée : si le géocodage ne trouve rien, on l'indique clairement.
class CitySearchField extends StatefulWidget {
  final ValueChanged<City> onCityFound;

  const CitySearchField({super.key, required this.onCityFound});

  @override
  State<CitySearchField> createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends State<CitySearchField> {
  final _controller = TextEditingController();
  bool _isSearching = false;
  String? _error;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _error = null;
    });
    try {
      final locations =
          await geocoding.Geocoding().locationFromAddress(query);
      if (locations.isEmpty) {
        setState(() => _error = 'Aucun lieu trouvé pour "$query".');
        return;
      }
      final loc = locations.first;
      widget.onCityFound(
        City(name: query.trim(), latitude: loc.latitude, longitude: loc.longitude),
      );
      _controller.clear();
    } catch (_) {
      setState(() => _error = 'Recherche indisponible pour le moment.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          decoration: InputDecoration(
            hintText: 'Rechercher une ville, un lieu…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: () => _search(_controller.text),
                  ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
