import 'package:flutter/material.dart';

/// Palettes de couleurs de l'application, telles que définies dans la
/// maquette (Étape 2). Le mode sombre n'est PAS une simple inversion du
/// mode clair : le bleu primaire change de teinte pour rester lumineux et
/// lisible sur fond sombre, conformément au cahier des charges §10.
class AppColors {
  AppColors._();

  // ---------- Mode clair ----------
  static const Color lightPrimary = Color(0xFF2F6FED);
  static const Color lightSecondary = Color(0xFFFF9F43);
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF12213D);
  static const Color lightTextSecondary = Color(0xFF5C6B85);
  static const Color lightSuccess = Color(0xFF2BB673);
  static const Color lightError = Color(0xFFE14B4B);

  /// Voile appliqué sur l'image de fond en mode clair (haut → bas),
  /// pour garantir la lisibilité du texte par-dessus.
  static const List<Color> lightBackgroundOverlay = [
    Color(0x8CF6F8FC), // ~55% opacité
    Color(0xD9F6F8FC), // ~85% opacité
  ];

  /// Fond des cartes en verre dépoli (glassmorphism), mode clair.
  static const Color lightGlassSurface = Color(0xA6FFFFFF); // ~65% opacité
  static const Color lightGlassBorder = Color(0x0F12213D); // ~6% opacité

  // ---------- Mode sombre ----------
  static const Color darkPrimary = Color(0xFF5B8CFF);
  static const Color darkSecondary = Color(0xFFFFB05C);
  static const Color darkBackground = Color(0xFF0E1526);
  static const Color darkSurface = Color(0xFF161F36);
  static const Color darkTextPrimary = Color(0xFFEAF0FF);
  static const Color darkTextSecondary = Color(0xFF8E9CC1);
  static const Color darkSuccess = Color(0xFF3ED28D);
  static const Color darkError = Color(0xFFFF6B6B);

  /// Voile appliqué sur l'image de fond en mode sombre (haut → bas).
  static const List<Color> darkBackgroundOverlay = [
    Color(0x8C0E1526), // ~55% opacité
    Color(0xD90E1526), // ~85% opacité
  ];

  /// Fond des cartes en verre dépoli (glassmorphism), mode sombre.
  static const Color darkGlassSurface = Color(0x8C161F36); // ~55% opacité
  static const Color darkGlassBorder = Color(0x14FFFFFF); // ~8% opacité
}
