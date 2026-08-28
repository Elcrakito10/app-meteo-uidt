import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Widget racine d'arrière-plan : affiche l'image thématique (orage nocturne
/// en sombre / ciel pastel en clair) avec un voile dégradé garantissant la
/// lisibilité, et anime la transition lors du changement de thème.
///
/// À utiliser UNE FOIS en dessous de tout le contenu de l'app (voir main.dart
/// à une prochaine étape), pas répété sur chaque écran.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const AppBackground({
    super.key,
    required this.child,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondu croisé animé au changement de thème : ciel dessiné en code
        // pour le clair (identité visuelle originale, aucun souci de
        // droits d'auteur), photo d'orage nocturne inchangée pour le sombre.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (widget, animation) =>
              FadeTransition(opacity: animation, child: widget),
          child: isDarkMode
              ? Image.asset(
                  'assets/backgrounds/dark_storm_bg.jpg',
                  key: const ValueKey('dark'),
                  fit: BoxFit.cover,
                )
              : const _PaintedDaySky(key: ValueKey('light')),
        ),

        // Voile dégradé garantissant la lisibilité du texte par-dessus.
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? AppColors.darkBackgroundOverlay
                  : AppColors.lightBackgroundOverlay,
            ),
          ),
        ),

        // Contenu réel de l'application.
        child,
      ],
    );
  }
}

/// Scène "coucher de soleil sénégalais" dessinée en code : ciel dégradé
/// violet → orange → rose, soleil avec rayons et halo, nuages nuancés,
/// palmiers en silhouette, oiseaux, océan avec reflet et scintillements.
/// Identité visuelle 100% originale (aucune image externe, donc aucun
/// souci de droits d'auteur) — voir _SunsetBeachPainter pour le détail,
/// facilement ajustable en couleurs si besoin.
class _PaintedDaySky extends StatelessWidget {
  const _PaintedDaySky({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SunsetBeachPainter(),
      size: Size.infinite,
    );
  }
}

class _SunsetBeachPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // --- Ciel : dégradé violet nuit → orange coucher → rose horizon.
    final skyRect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3B4A7A),
            Color(0xFF7A5C9E),
            Color(0xFFE07A62),
            Color(0xFFF5A65C),
            Color(0xFFFBD9A5),
          ],
          stops: [0.0, 0.25, 0.5, 0.72, 1.0],
        ).createShader(skyRect),
    );

    final sunCenter = Offset(w * 0.53, h * 0.31);

    // --- Halo chaud du soleil.
    canvas.drawCircle(
      sunCenter,
      w * 0.44,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFF6E0).withValues(alpha: 1.0),
          const Color(0xFFFFE9C2).withValues(alpha: 0.6),
          const Color(0xFFFF9E5E).withValues(alpha: 0.0),
        ], stops: const [
          0.0,
          0.3,
          1.0,
        ]).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.44)),
    );

    // --- Rayons de soleil.
    final rayPaint = Paint()
      ..color = const Color(0xFFFFE9C2).withValues(alpha: 0.5)
      ..strokeWidth = 1.4;
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * 3.1415926535;
      final dx = sunCenter.dx + w * 0.32 * math.cos(angle);
      final dy = sunCenter.dy + w * 0.32 * math.sin(angle);
      canvas.drawLine(sunCenter, Offset(dx, dy), rayPaint);
    }

    // --- Disque du soleil + anneau lumineux.
    canvas.drawCircle(sunCenter, w * 0.12, Paint()..color = const Color(0xFFFFCB7A));
    canvas.drawCircle(
      sunCenter,
      w * 0.12,
      Paint()..color = const Color(0xFFFFF6E0).withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      sunCenter,
      w * 0.13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFF6E0).withValues(alpha: 0.5),
    );

    // --- Nuages (3 groupes, teintés chaud) + reflet supérieur.
    void drawCloudCluster(Offset center, double scale, double opacity) {
      final cloudPaint = Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFEDD4),
          const Color(0xFFE79E8C),
        ]).createShader(Rect.fromCircle(center: center, radius: scale * 90))
        ..color = const Color(0xFFFFEDD4).withValues(alpha: opacity);
      for (final blob in [
        Offset(-0.5, 0.1), Offset(-0.15, -0.1), Offset(0.2, -0.05),
        Offset(0.5, 0.1),
      ]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: center + Offset(blob.dx, blob.dy) * scale * 130,
            width: scale * 110,
            height: scale * 65,
          ),
          cloudPaint..color = cloudPaint.color.withValues(alpha: opacity),
        );
      }
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(-0.15, -0.12) * scale * 130,
          width: scale * 65,
          height: scale * 22,
        ),
        Paint()..color = const Color(0xFFFFF9EC).withValues(alpha: opacity * 0.8),
      );
    }

    drawCloudCluster(Offset(w * 0.19, h * 0.17), 1.0, 0.92);
    drawCloudCluster(Offset(w * 0.80, h * 0.21), 0.85, 0.88);
    drawCloudCluster(Offset(w * 0.40, h * 0.085), 0.6, 0.78);
    drawCloudCluster(Offset(w * 0.87, h * 0.40), 0.7, 0.75);

    // --- Oiseaux (petits "M" doubles).
    final birdPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF3B3050).withValues(alpha: 0.8);
    void drawBird(Offset o, double s) {
      final path = Path()
        ..moveTo(o.dx - 14 * s, o.dy)
        ..quadraticBezierTo(o.dx - 7 * s, o.dy - 7 * s, o.dx, o.dy)
        ..quadraticBezierTo(o.dx + 7 * s, o.dy - 7 * s, o.dx + 14 * s, o.dy);
      canvas.drawPath(path, birdPaint);
    }

    drawBird(Offset(w * 0.16, h * 0.13), 1.0);
    drawBird(Offset(w * 0.68, h * 0.085), 0.85);
    drawBird(Offset(w * 0.26, h * 0.24), 0.85);

    // --- Océan avec dégradé + reflet du soleil + scintillements.
    final seaTop = h * 0.61;
    final seaRect = Rect.fromLTWH(0, seaTop, w, h - seaTop);
    canvas.drawRect(
      seaRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC97558), Color(0xFF8C5B72), Color(0xFF3E3E63)],
          stops: [0.0, 0.35, 1.0],
        ).createShader(seaRect),
    );

    final reflectionCenter = Offset(sunCenter.dx, seaTop + 14);
    canvas.drawOval(
      Rect.fromCenter(center: reflectionCenter, width: w * 0.52, height: 30),
      Paint()..color = const Color(0xFFFFCB7A).withValues(alpha: 0.45),
    );
    canvas.drawOval(
      Rect.fromCenter(center: reflectionCenter, width: w * 0.24, height: 14),
      Paint()..color = const Color(0xFFFFF6E0).withValues(alpha: 0.6),
    );

    final sparklePaint = Paint()..color = const Color(0xFFFFE9C2);
    final sparkles = [
      (0.40, 0.68, 10.0, 0.7), (0.65, 0.70, 8.0, 0.6),
      (0.49, 0.75, 14.0, 0.6), (0.57, 0.79, 9.0, 0.55),
      (0.44, 0.82, 7.0, 0.5), (0.61, 0.86, 12.0, 0.5),
      (0.46, 0.90, 8.0, 0.45),
    ];
    for (final (fx, fy, rw, alpha) in sparkles) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * fx, h * fy), width: rw, height: 2.4),
        sparklePaint..color = sparklePaint.color.withValues(alpha: alpha),
      );
    }

    // --- Plage de sable.
    final sandTop = h * 0.87;
    final sandPath = Path()
      ..moveTo(0, sandTop + 15)
      ..quadraticBezierTo(w * 0.25, sandTop - 15, w * 0.5, sandTop + 5)
      ..quadraticBezierTo(w * 0.75, sandTop - 20, w, sandTop - 6)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      sandPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFFE8B77E), Color(0xFFC89361)],
        ).createShader(Rect.fromLTWH(0, sandTop - 20, w, h - sandTop + 20)),
    );

    // --- Palmiers (2, en silhouette).
    void drawPalm(Offset base, double scale) {
      final trunkPaint = Paint()..color = const Color(0xFF3B2B26);
      final leafPaint = Paint()..color = const Color(0xFF4A3428);
      final trunkPath = Path()
        ..moveTo(base.dx, base.dy)
        ..lineTo(base.dx + 4 * scale, base.dy - 70 * scale)
        ..lineTo(base.dx - 2 * scale, base.dy - 70 * scale)
        ..close();
      canvas.drawPath(trunkPath, trunkPaint);

      final top = Offset(base.dx + 4 * scale, base.dy - 70 * scale);
      for (final leaf in [
        [Offset(-30, 10), Offset(-46, 26), Offset(-20, 22)],
        [Offset(34, 6), Offset(52, 20), Offset(24, 20)],
        [Offset(-16, -6), Offset(-10, -22), Offset(2, -2)],
        [Offset(22, -8), Offset(18, -24), Offset(4, -4)],
        [Offset(-2, -14), Offset(6, -30), Offset(10, -8)],
      ]) {
        final path = Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(
            top.dx + leaf[0].dx * scale,
            top.dy + leaf[0].dy * scale,
            top.dx + leaf[1].dx * scale,
            top.dy + leaf[1].dy * scale,
          )
          ..quadraticBezierTo(
            top.dx + leaf[2].dx * scale,
            top.dy + leaf[2].dy * scale,
            top.dx,
            top.dy,
          )
          ..close();
        canvas.drawPath(path, leafPaint);
      }
    }

    drawPalm(Offset(w * 0.13, h * 0.94), w / 380);
    drawPalm(Offset(w * 0.84, h * 0.955), (w / 380) * 0.9);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
/// l'image de fond reste visible en transparence sans jamais nuire à la
/// lisibilité du texte posé dessus. Remplace le Card standard partout où
/// un fond photo est visible derrière.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isDark ? 12 : 8,
          sigmaY: isDark ? 12 : 8,
        ),
        child: Material(
          color: isDark
              ? AppColors.darkGlassSurface
              : AppColors.lightGlassSurface,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkGlassBorder
                      : AppColors.lightGlassBorder,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
