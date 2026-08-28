import 'package:flutter/material.dart';
import '../../../providers/weather_map_provider.dart';

/// Panneau de sélection des couches météo, organisé par catégorie. Les
/// couches indisponibles apparaissent grisées avec un cadenas plutôt que
/// d'être masquées — l'utilisateur comprend que la fonctionnalité existe
/// mais n'est pas branchée à une source de données réelle pour l'instant.
class LayerSelectorSheet extends StatelessWidget {
  final WeatherMapLayer selected;
  final ValueChanged<WeatherMapLayer> onSelect;

  const LayerSelectorSheet({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _categories = <String, List<WeatherMapLayer>>{
    'Atmosphère': [
      WeatherMapLayer.wind,
      WeatherMapLayer.temperature,
      WeatherMapLayer.pressure,
    ],
    'Précipitations': [WeatherMapLayer.precipitation],
    'Observation': [WeatherMapLayer.satellite, WeatherMapLayer.radar],
    'Autres': [WeatherMapLayer.clouds, WeatherMapLayer.alerts],
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Couches météo', style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Choisissez une couche à afficher sur la carte',
                style: textTheme.bodySmall),
            const SizedBox(height: 16),
            for (final category in _categories.entries) ...[
              Text(category.key, style: textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final layer in category.value)
                    _LayerChip(
                      layer: layer,
                      isSelected: layer == selected,
                      onTap: layer.isAvailable ? () => onSelect(layer) : null,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _LayerChip extends StatelessWidget {
  final WeatherMapLayer layer;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LayerChip({
    required this.layer,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDisabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(layer.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              layer.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colors.onPrimary
                    : isDisabled
                        ? colors.outline
                        : colors.onSurface,
              ),
            ),
            if (isDisabled) ...[
              const SizedBox(width: 6),
              Icon(Icons.lock_outline_rounded, size: 13, color: colors.outline),
            ],
          ],
        ),
      ),
    );
  }
}
