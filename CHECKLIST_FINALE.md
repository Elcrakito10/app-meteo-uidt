# Étape 6 — Checklist finale avant remise
## Ciel Sénégal — Abdoul Aziz Dione & Sokhna Awa Dione

---

## 1. Structure finale du projet

```
app_meteo/
├── lib/
│   ├── core/                  # config, constantes (5 villes), exceptions typées
│   ├── models/                # WeatherResponse, ForecastResponse, City, CityWeatherResult
│   ├── services/               # weather_api_service.dart (Retrofit) + .g.dart (manuel, voir §5)
│   ├── repositories/           # weather_repository.dart (mapping erreurs, orchestration)
│   ├── providers/              # Riverpod : api, theme, weather_flow, forecast, weather_map
│   ├── screens/
│   │   ├── home/                # Accueil
│   │   ├── loading/              # Chargement (jauge réelle)
│   │   ├── results/              # Résultats (cartes 5 villes)
│   │   ├── city_detail/          # Détail + Google Maps
│   │   ├── hub/                  # Dashboard + prévisions (binôme)
│   │   └── weather_map/          # Carte météo interactive (binôme)
│   ├── widgets/                # PrimaryButton, GlassCard, listes prévisions, recherche ville
│   ├── theme/                  # Couleurs, typographie, arrière-plans photo
│   ├── utils/                  # Icônes météo, formatage date, direction vent
│   └── main.dart
├── assets/backgrounds/         # dark_storm_bg.jpg, light_sky_bg.jpg
├── android/                    # config native (compileSdk 36, clé Maps injectée)
├── .env.example                 # modèle des clés (le vrai .env n'est jamais versionné)
├── .gitignore
├── README.md
└── GUIDE_BINOME.md
```

## 2. Dépendances principales (pubspec.yaml)

| Package | Rôle |
|---|---|
| `flutter_riverpod` | Gestion d'état |
| `dio` + `retrofit` | Appels API (annotations Retrofit + client Dio) |
| `json_annotation` / `json_serializable` | Sérialisation des modèles |
| `google_maps_flutter` | Carte détail ville + carte interactive |
| `flutter_dotenv` | Chargement de la clé API météo depuis `.env` |
| `geolocator` / `geocoding` | Localisation utilisateur, recherche de ville |
| `google_fonts` | Poppins / Inter |
| `connectivity_plus` | Détection de connexion réseau |

## 3. Configurations nécessaires avant de lancer le projet

- [ ] `.env` créé à la racine (copie de `.env.example`) avec une vraie clé OpenWeatherMap
- [ ] `android/local.properties` contient `MAPS_API_KEY=...` (clé Google Maps, API "Maps SDK for Android" activée sur Google Cloud)
- [ ] `android/app/build.gradle.kts` : `compileSdk = 36`, `targetSdk = 36`, lecture de `local.properties` pour `manifestPlaceholders["MAPS_API_KEY"]`
- [ ] `AndroidManifest.xml` : balise `<meta-data android:name="com.google.android.geo.API_KEY" android:value="${MAPS_API_KEY}" />`

## 4. Commandes de lancement

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # génère les modèles JSON
flutter run
```

> **Rappel important** : `lib/services/weather_api_service.g.dart` est écrit à la main (bug non résolu de `retrofit_generator` au moment du projet, documenté en tête du fichier) — ne pas essayer de le régénérer, il n'y a plus de builder Retrofit dans `pubspec.yaml`.

## 5. Commande de build APK

```bash
flutter build apk --release
```
APK généré dans : `build/app/outputs/flutter-apk/app-release.apk`

## 6. Checklist de vérification fonctionnelle (à faire tous les deux, ensemble)

### Flux principal (P1)
- [x] Accueil : animation d'entrée en cascade visible, toggle thème fonctionne
- [x] Chargement : jauge progresse par paliers réels (pas un minuteur fixe), messages changent
- [x] Les 5 villes se chargent avec de vraies données
- [x] Résultats : cartes tapables, tri, retry individuel sur une ville en échec
- [x] Détail ville : toutes les infos + mini-carte Google Maps avec marqueur correct
- [x] Bouton "Recommencer" relance tout le flux depuis zéro
- [x] Bouton retour accueil fonctionne à tout moment

### Gestion d'erreurs
- [x] Couper le réseau → message "Pas de connexion" propre, pas de crash
- [x] Réessayer après reconnexion → recharge correctement
- [x] Clé API invalide (test ponctuel) → message clair, pas de crash

### Thème
- [x] Mode clair : ciel pastel + cartes en verre clair, tout lisible
- [x] Mode sombre : orage + cartes en verre sombre, tout lisible
- [x] Transition entre les deux animée (fondu), pas de flash brutal

### Carte météo interactive (P2)
- [x] Les 4 couches (température, vent, précipitations, pression) affichent une vraie tuile colorée
- [x] Flèches de vent visibles sur les 5 villes en couche "Vent", avec vraies valeurs
- [x] Légende change selon la couche sélectionnée
- [x] Curseur temporel : le panneau d'info change avec de vraies données de prévision (l'image de la carte reste volontairement figée sur "maintenant" — comportement documenté, pas un bug)
- [x] Recherche de ville fonctionne
- [x] Bouton localisation demande la permission proprement

### Dashboard / Prévisions
- [x] Prévisions horaires et sur 6 jours affichent de vraies données
- [x] Aucun débordement visuel (RenderFlex overflow) sur aucun écran

## 7. Étapes GitHub avant remise

- [x] Tous les commits des deux membres sont bien poussés sur `main`
- [x] `git log --oneline` montre une contribution claire des deux personnes
- [x] `.env` et `android/local.properties` sont absents du repository (vérifié sur github.com)
- [x] README.md à jour, avec les deux noms
- [x] Le dépôt est accessible (Private + collaborateurs, ou Public selon consigne du professeur)

## 8. Derniers réglages de qualité (optionnels mais recommandés)

- [x] Supprimer tout fichier parasite (ex. `desktop.ini` s'il réapparaît)
- [x] Vérifier qu'aucun `debugPrint` de diagnostic ne pollue excessivement la console en usage normal (les logs actuels sont utiles pour la démo/débogage, à garder ou retirer selon préférence — ils n'affectent pas le fonctionnement)
- [x] Relire une dernière fois `README.md` pour l'orthographe et la clarté

---

