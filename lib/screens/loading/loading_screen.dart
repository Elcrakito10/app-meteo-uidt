import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/city_weather_result.dart';
import '../../providers/weather_flow_provider.dart';
import '../../theme/app_background.dart';
import '../../widgets/primary_button.dart';
import '../results/results_screen.dart';

/// Écran de chargement (cahier des charges §4) : jauge animée pilotée par
/// la progression RÉELLE des 5 appels API (via weatherFlowProvider), messages
/// dynamiques qui changent automatiquement, transformation en bouton
/// "Recommencer" une fois terminé.
class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  int _messageIndex = 0;
  Timer? _messageTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Lance le chargement réel des 5 villes dès l'arrivée sur l'écran.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherFlowProvider.notifier).start(AppConstants.defaultCities);
    });

    // Fait défiler les messages dynamiques toutes les 1.6s tant que ça charge.
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (!mounted) return;
      setState(() {
        _messageIndex =
            (_messageIndex + 1) % AppConstants.loadingMessages.length;
      });
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _goToResults() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const ResultsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(weatherFlowProvider);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    // Dès que le chargement est terminé, on arrête de faire tourner les
    // messages — la jauge devient le bouton Recommencer/Continuer.
    if (flowState.isComplete) {
      _messageTimer?.cancel();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Jauge circulaire animée, pilotée par la progression réelle.
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: flowState.progress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 12,
                          backgroundColor: colors.onSurface.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(colors.primary),
                          strokeCap: StrokeCap.round,
                        );
                      },
                    ),
                    // Contenu central : pourcentage OU bouton Recommencer/Continuer.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: flowState.isComplete
                          ? _CenterActionButton(
                              key: const ValueKey('done'),
                              isTotalFailure: flowState.isTotalFailure,
                              onContinue: _goToResults,
                              onRetryAll: () => ref
                                  .read(weatherFlowProvider.notifier)
                                  .start(AppConstants.defaultCities),
                            )
                          : Text(
                              '${(flowState.progress * 100).round()}%',
                              key: const ValueKey('percent'),
                              style: textTheme.headlineMedium,
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Message dynamique (ou message de fin).
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  flowState.isComplete
                      ? (flowState.isTotalFailure
                          ? 'Le chargement a échoué. Réessayez.'
                          : 'Terminé !')
                      : AppConstants.loadingMessages[_messageIndex],
                  key: ValueKey(flowState.isComplete
                      ? 'done-msg'
                      : _messageIndex),
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 28),

              // Liste discrète des 5 villes avec coche dès que chacune est
              // effectivement terminée (succès ou échec) — couplée à l'état réel.
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: AppConstants.defaultCities.map((city) {
                  CityWeatherResult? result;
                  for (final r in flowState.results) {
                    if (r.city == city) {
                      result = r;
                      break;
                    }
                  }
                  final isDone = result != null;
                  final isSuccess = result is CityWeatherSuccess;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDone
                          ? (isSuccess
                              ? colors.primary.withValues(alpha: 0.12)
                              : colors.error.withValues(alpha: 0.12))
                          : colors.onSurface.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDone
                              ? (isSuccess
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded)
                              : Icons.hourglass_empty_rounded,
                          size: 14,
                          color: isDone
                              ? (isSuccess ? colors.primary : colors.error)
                              : colors.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(city.name, style: textTheme.labelLarge),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  final bool isTotalFailure;
  final VoidCallback onContinue;
  final VoidCallback onRetryAll;

  const _CenterActionButton({
    super.key,
    required this.isTotalFailure,
    required this.onContinue,
    required this.onRetryAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isTotalFailure ? onRetryAll : onContinue,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary,
        ),
        child: Icon(
          isTotalFailure ? Icons.refresh_rounded : Icons.check_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}
