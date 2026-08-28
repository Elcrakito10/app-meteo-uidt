import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/forecast_response.dart';
import '../../../theme/app_background.dart';
import '../../../utils/date_format_fr.dart';

/// Curseur temporel. IMPORTANT — honnêteté des données : les tuiles météo
/// gratuites d'OpenWeatherMap ne sont PAS indexées dans le temps (pas
/// d'historique/prévision animée sur l'image elle-même côté gratuit). Ce
/// curseur ne fait donc PAS varier l'image de la carte — il fait varier le
/// PANNEAU D'INFO ci-dessous, qui affiche les vraies valeurs prévues à
/// chaque échéance renvoyées par l'API `/forecast`. C'est explicité à
/// l'écran pour ne jamais laisser croire à une animation de tuile qui
/// n'existe pas.
class WeatherTimeSlider extends StatefulWidget {
  final List<ForecastEntry> entries;
  final int selectedIndex;
  final bool isPlaying;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<bool> onPlayingChanged;

  const WeatherTimeSlider({
    super.key,
    required this.entries,
    required this.selectedIndex,
    required this.isPlaying,
    required this.onIndexChanged,
    required this.onPlayingChanged,
  });

  @override
  State<WeatherTimeSlider> createState() => _WeatherTimeSliderState();
}

class _WeatherTimeSliderState extends State<WeatherTimeSlider> {
  Timer? _timer;

  @override
  void didUpdateWidget(covariant WeatherTimeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && _timer == null) {
      _startAutoPlay();
    } else if (!widget.isPlaying && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final next = widget.selectedIndex + 1;
      if (next >= widget.entries.length) {
        widget.onPlayingChanged(false);
      } else {
        widget.onIndexChanged(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final safeIndex = widget.selectedIndex.clamp(0, widget.entries.length - 1);
    final selected = widget.entries[safeIndex];
    final isToday = selected.dateTime.day == DateTime.now().day;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      borderRadius: 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => widget.onPlayingChanged(!widget.isPlaying),
                icon: Icon(
                  widget.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: colors.primary,
                  size: 32,
                ),
              ),
              Expanded(
                child: Text(
                  '${isToday ? "Aujourd\'hui" : DateFormatFr.weekday(selected.dateTime)} · '
                  '${DateFormatFr.hourMinute(selected.dateTime)}',
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge,
                ),
              ),
              IconButton(
                onPressed: safeIndex > 0
                    ? () => widget.onIndexChanged(safeIndex - 1)
                    : null,
                icon: const Icon(Icons.fast_rewind_rounded),
              ),
              IconButton(
                onPressed: safeIndex < widget.entries.length - 1
                    ? () => widget.onIndexChanged(safeIndex + 1)
                    : null,
                icon: const Icon(Icons.fast_forward_rounded),
              ),
            ],
          ),
          Slider(
            value: safeIndex.toDouble(),
            min: 0,
            max: (widget.entries.length - 1).toDouble(),
            divisions:
                widget.entries.length > 1 ? widget.entries.length - 1 : 1,
            onChanged: (value) => widget.onIndexChanged(value.round()),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Panneau piloté par les prévisions réelles — l\'image de la '
              'carte reste la donnée temps réel la plus récente.',
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
