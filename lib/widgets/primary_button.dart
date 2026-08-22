import 'package:flutter/material.dart';

/// Bouton principal réutilisable dans toute l'app, avec une animation de
/// compression légère au toucher (cahier des charges §3 : "Le bouton
/// Commencer doit avoir une animation au toucher").
///
/// Utilisé pour "Commencer" (Accueil), "Recommencer" (Résultats),
/// "Réessayer" (états d'erreur), etc.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  double _scale = 1.0;

  void _setScale(double value) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _scale = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setScale(0.97),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.label),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
