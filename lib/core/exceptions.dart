/// Hiérarchie d'exceptions métier de l'application.
///
/// Objectif : que la couche UI (widgets ErrorStateView) puisse afficher un
/// message précis et une icône adaptée selon le TYPE d'erreur, sans jamais
/// avoir à parser du texte d'exception à la main. Couvre explicitement tous
/// les cas exigés par le cahier des charges §9.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Aucune connexion Internet disponible.
class NoConnectionException extends AppException {
  const NoConnectionException()
      : super(
          'Pas de connexion Internet. Vérifiez votre réseau et réessayez.',
        );
}

/// La requête a dépassé le délai maximum autorisé.
class TimeoutAppException extends AppException {
  const TimeoutAppException()
      : super(
          'Le serveur météo met trop de temps à répondre. Réessayez.',
        );
}

/// Erreur HTTP générique (code 4xx/5xx autre que clé API invalide).
class HttpAppException extends AppException {
  final int? statusCode;
  const HttpAppException(this.statusCode)
      : super('Le serveur météo a renvoyé une erreur. Réessayez plus tard.');
}

/// Clé API absente, invalide ou refusée par le fournisseur (code 401).
class InvalidApiKeyException extends AppException {
  const InvalidApiKeyException()
      : super(
          'Clé API météo invalide ou manquante. Vérifiez la configuration.',
        );
}

/// Les données reçues ne correspondent pas au format attendu.
class InvalidDataException extends AppException {
  const InvalidDataException()
      : super('Les données reçues sont invalides ou incomplètes.');
}

/// Problème spécifique à l'affichage de Google Maps (clé, permissions...).
class MapUnavailableException extends AppException {
  const MapUnavailableException()
      : super('La carte est momentanément indisponible.');
}

/// Erreur générique de dernier recours — ne devrait presque jamais être
/// atteinte si les autres types sont bien mappés dans la couche réseau.
class UnknownAppException extends AppException {
  const UnknownAppException([String? detail])
      : super(detail ?? 'Une erreur inattendue est survenue.');
}
