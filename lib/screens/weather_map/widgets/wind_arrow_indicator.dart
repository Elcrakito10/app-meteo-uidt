import 'package:flutter/material.dart';

/// Indicateur de vent animé (§13). IMPORTANT — honnêteté des données :
/// OpenWeatherMap gratuit ne fournit le vent (vitesse + direction) qu'AU
/// POINT interrogé, pas un champ vectoriel sur toute la carte. On affiche
/// donc une seule flèche, positionnée sur le point réellement interrogé,
/// plutôt qu'un champ de particules qui laisserait croire à des données
/// sur toute la zone visible alors qu'elles n'existent pas.
///
/// - La flèche pointe dans la direction RÉELLE du vent ([directionDegrees],
///   convention météo : 0°/360° = vient du Nord).
/// - La vitesse d'animation (pulsation) est proportionnelle à la vitesse
///   RÉELLE du vent ([speedMs]) : plus le vent est fort, plus le pouls est
///   rapide — jamais une valeur arbitraire.
class WindArrowIndicator extends StatefulWidget {
  final double speedMs;
  final int? directionDegrees;
  final double size;

  const WindArrowIndicator({
    super.key,
    required this.speedMs,
    required this.directionDegrees,
    this.size = 40,
  });

  @override
  State<WindArrowIndicator> createState() => _WindArrowIndicatorState();
}

class _WindArrowIndicatorState extends State<WindArrowIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _pulseDuration())
      ..repeat();
  }

  /// Vent nul → pas de pulsation perceptible. Vent fort (>15 m/s, ~54 km/h)
  /// → pulsation rapide (600ms). Interpolation linéaire entre les deux,
  /// bornée pour rester lisible visuellement.
  Duration _pulseDuration() {
    final clamped = widget.speedMs.clamp(0.0, 15.0);
    final ms = 2200 - (clamped / 15.0) * 1600; // 2200ms (calme) → 600ms (fort)
    return Duration(milliseconds: ms.round());
  }

  @override
  void didUpdateWidget(covariant WindArrowIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speedMs != widget.speedMs) {
      _controller.duration = _pulseDuration();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Convention météo : la direction indique D'OÙ vient le vent. La
    // flèche doit pointer là où le vent SOUFFLE, donc rotation + 180°.
    final headingRadians =
        (((widget.directionDegrees ?? 0) + 180) % 360) * 3.1415926535 / 180;

    if (widget.speedMs <= 0.1) {
      // Vent quasi nul : donnée réelle également, pas de flèche trompeuse.
      return Icon(Icons.circle_outlined, size: widget.size * 0.4, color: colors.outline);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = 0.85 + 0.15 * (1 - (_controller.value - 0.5).abs() * 2);
        return Transform.scale(
          scale: pulse,
          child: Transform.rotate(
            angle: widget.directionDegrees != null ? headingRadians : 0,
            child: child,
          ),
        );
      },
      child: Icon(
        widget.directionDegrees != null
            ? Icons.navigation_rounded
            : Icons.air_rounded,
        size: widget.size,
        color: colors.primary,
      ),
    );
  }
}
