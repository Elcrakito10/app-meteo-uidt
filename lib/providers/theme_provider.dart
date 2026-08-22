import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier simple pour le thème actif. Séparé du reste de l'état métier
/// pour que le changement de thème ne redéclenche jamais un rechargement
/// des données météo (les deux états sont totalement indépendants).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Raccourci pratique pour savoir si le mode sombre est actif, utilisé
/// notamment par AppBackground (voir theme/app_background.dart) pour
/// choisir entre l'image d'orage et le ciel pastel.
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeModeProvider) == ThemeMode.dark;
});
