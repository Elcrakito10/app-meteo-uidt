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
        // Fondu croisé animé entre les deux images de fond au changement de thème.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (widget, animation) =>
              FadeTransition(opacity: animation, child: widget),
          child: Image.asset(
            isDarkMode
                ? 'assets/backgrounds/dark_storm_bg.jpg'
                : 'assets/backgrounds/light_sky_bg.jpg',
            key: ValueKey(isDarkMode),
            fit: BoxFit.cover,
          ),
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

/// Carte "verre dépoli" réutilisable : fond translucide + flou, pour que
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
