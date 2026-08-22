import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_background.dart';
import '../../widgets/primary_button.dart';
import '../loading/loading_screen.dart';

/// Écran d'accueil (cahier des charges §3) : logo, nom, slogan, courte
/// présentation, bouton Commencer, accès au thème. Animation d'entrée en
/// cascade au démarrage (logo → titre → slogan → bouton).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Chaque élément de l'écran a sa propre fenêtre d'animation, décalée
  // dans le temps, pour créer l'effet de cascade demandé par la maquette.
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoOpacity = _fadeInterval(0.0, 0.4);
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));
    _titleOpacity = _fadeInterval(0.25, 0.6);
    _taglineOpacity = _fadeInterval(0.45, 0.8);
    _buttonOpacity = _fadeInterval(0.65, 1.0);

    _controller.forward();
  }

  Animation<double> _fadeInterval(double start, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startExperience() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const LoadingScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              // Toggle thème en haut à droite.
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () =>
                      ref.read(themeModeProvider.notifier).toggle(),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      key: ValueKey(isDarkMode),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Logo météo custom (goutte + soleil stylisés).
              FadeTransition(
                opacity: _logoOpacity,
                child: SlideTransition(
                  position: _logoSlide,
                  child: _AppLogo(isDarkMode: isDarkMode),
                ),
              ),

              const SizedBox(height: 28),

              FadeTransition(
                opacity: _titleOpacity,
                child: Text(
                  AppConstants.appName,
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 10),

              FadeTransition(
                opacity: _taglineOpacity,
                child: Column(
                  children: [
                    Text(
                      AppConstants.appTagline,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Consultez en un instant la météo de Dakar, Thiès, '
                      'Saint-Louis, Kaolack et Ziguinchor — avec des '
                      'données en temps réel.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 4),

              FadeTransition(
                opacity: _buttonOpacity,
                child: PrimaryButton(
                  label: 'Commencer',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _startExperience,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo météo custom simple (goutte + soleil), en dégradé primaire→secondaire,
/// pour éviter de dépendre d'un asset image supplémentaire pour ce détail.
class _AppLogo extends StatelessWidget {
  final bool isDarkMode;
  const _AppLogo({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.wb_cloudy_rounded,
        color: Colors.white,
        size: 48,
      ),
    );
  }
}
