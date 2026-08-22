import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Échelle typographique de l'application (définie dans la maquette,
/// Étape 2) : Poppins pour les titres/chiffres, Inter pour le texte
/// courant. Les couleurs ne sont PAS fixées ici — elles sont appliquées
/// par le ThemeData (voir app_theme.dart) selon le thème actif.
class AppTypography {
  AppTypography._();

  static TextStyle get temperatureHero => GoogleFonts.poppins(
        fontSize: 68,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  static TextStyle get screenTitle => GoogleFonts.poppins(
        fontSize: 27,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get cardTitle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}
