import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Assemble les ThemeData Material 3 clair et sombre à partir de la
/// palette (app_colors.dart) et de la typographie (app_typography.dart).
///
/// Chaque état requis par le cahier des charges §10 est explicitement
/// défini : couleurs principales, secondaires, surfaces, cartes, texte,
/// icônes, boutons, erreur, succès.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent, // l'image de fond gère le fond réel
        colorScheme: const ColorScheme.light(
          primary: AppColors.lightPrimary,
          secondary: AppColors.lightSecondary,
          surface: AppColors.lightSurface,
          error: AppColors.lightError,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.lightTextPrimary,
          onError: Colors.white,
        ),
        textTheme: TextTheme(
          headlineMedium: AppTypography.screenTitle
              .copyWith(color: AppColors.lightTextPrimary),
          titleMedium: AppTypography.cardTitle
              .copyWith(color: AppColors.lightTextPrimary),
          bodyMedium:
              AppTypography.body.copyWith(color: AppColors.lightTextSecondary),
          labelLarge:
              AppTypography.label.copyWith(color: AppColors.lightTextSecondary),
        ),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: Colors.white,
            textStyle: AppTypography.button,
            elevation: 4,
            shadowColor: AppColors.lightPrimary.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightGlassSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.lightGlassBorder),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          secondary: AppColors.darkSecondary,
          surface: AppColors.darkSurface,
          error: AppColors.darkError,
          onPrimary: Colors.white,
          onSecondary: Color(0xFF12213D),
          onSurface: AppColors.darkTextPrimary,
          onError: Colors.white,
        ),
        textTheme: TextTheme(
          headlineMedium: AppTypography.screenTitle
              .copyWith(color: AppColors.darkTextPrimary),
          titleMedium: AppTypography.cardTitle
              .copyWith(color: AppColors.darkTextPrimary),
          bodyMedium:
              AppTypography.body.copyWith(color: AppColors.darkTextSecondary),
          labelLarge:
              AppTypography.label.copyWith(color: AppColors.darkTextSecondary),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: Colors.white,
            textStyle: AppTypography.button,
            elevation: 4,
            shadowColor: AppColors.darkPrimary.withValues(alpha: 0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkGlassSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.darkGlassBorder),
          ),
        ),
      );
}
