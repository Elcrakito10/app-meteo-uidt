import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_config.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_background.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Garantit que le binding Flutter est prêt avant tout appel asynchrone
  // (nécessaire pour charger le .env avant runApp()).
  WidgetsFlutterBinding.ensureInitialized();

  // Charge les clés API (voir core/app_config.dart) avant de lancer l'UI,
  // pour qu'aucun écran ne démarre sans configuration disponible.
  await AppConfig.load();

  runApp(
    // ProviderScope est OBLIGATOIRE avec Riverpod : c'est lui qui contient
    // l'état de tous les providers de l'application (thème, météo...).
    const ProviderScope(child: WeatherApp()),
  );
}

class WeatherApp extends ConsumerWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'Ciel Sénégal',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // AppBackground englobe TOUTE l'application (voir theme/app_background.dart) :
      // c'est ici, une seule fois, que l'image thématique + le voile de
      // lisibilité sont appliqués — jamais répétés écran par écran.
      builder: (context, child) {
        return AppBackground(
          isDarkMode: isDarkMode,
          child: child ?? const SizedBox.shrink(),
        );
      },
      // Véritable écran Accueil — plus de placeholder temporaire.
      home: const HomeScreen(),
    );
  }
}