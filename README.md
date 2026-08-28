# Ciel Sénégal 🌦️

Application météo Flutter développée dans le cadre de l'examen de Développement Mobile — L3 Géomatique, UIDT.

Consultez en un instant la météo en temps réel de 5 villes du Sénégal (Dakar, Thiès, Saint-Louis, Kaolack, Ziguinchor), avec un design premium inspiré des meilleures applications météo actuelles.

## Équipe

- **Abdoul Aziz Dione**
- **Sokhna Awa Dione**

## Fonctionnalités

### Obligatoires (cahier des charges)
- ✅ Données météo réelles via l'API OpenWeatherMap (Retrofit + Dio)
- ✅ 5 villes sénégalaises interrogées en parallèle
- ✅ Jauge de progression animée, pilotée par l'avancement réel des requêtes
- ✅ Messages de chargement dynamiques
- ✅ Résultats présentés en cartes interactives (tableau hybride)
- ✅ Page détail par ville, avec localisation sur Google Maps
- ✅ Gestion complète des erreurs (réseau, timeout, HTTP, clé API invalide) avec retry
- ✅ Thème clair / sombre animé, avec arrière-plans photo dédiés
- ✅ Navigation complète + bouton Recommencer
- ✅ Architecture propre et modulaire

### En cours (Priorité 2 — fonctionnalité "waouh")
- 🚧 Carte météo interactive (couches, curseur temporel, recherche de ville, géolocalisation) — inspirée de meteoblue/Meteored

## Stack technique

| Domaine | Choix | Pourquoi |
|---|---|---|
| Framework | Flutter | Imposé par le cahier des charges |
| Gestion d'état | Riverpod | États asynchrones (loading/success/error) typés nativement |
| Réseau | Dio + Retrofit (annotations) | Imposé par le cahier des charges |
| Sérialisation JSON | json_serializable | Génération de code fiable |
| Cartes | google_maps_flutter | Localisation ville (détail) |
| Thème | Material 3 | Cohérence visuelle native Flutter |

## Architecture du projet

```
lib/
├── core/            # Configuration, constantes, exceptions
├── models/          # Modèles de données (météo, ville, résultats)
├── services/        # Client API (Retrofit)
├── repositories/     # Logique métier au-dessus des services
├── providers/       # Providers Riverpod (état applicatif)
├── screens/         # Écrans de l'application
│   ├── home/
│   ├── loading/
│   ├── results/
│   ├── city_detail/
│   └── weather_map/  # Écran carte météo interactive (en cours)
├── widgets/         # Composants réutilisables
├── theme/           # Couleurs, typographie, arrière-plans
├── utils/           # Fonctions utilitaires
└── main.dart
```

## Installation

### Prérequis
- Flutter SDK (3.9+)
- Un compte OpenWeatherMap (gratuit) : https://openweathermap.org/api
- Un compte Google Cloud avec l'API "Maps SDK for Android" activée

### 1. Cloner le projet
```bash
git clone https://github.com/Elcrakito10/app-meteo-uidt.git
cd app-meteo-uidt
flutter pub get
```

### 2. Configurer la clé API météo
Copiez `.env.example` en `.env` à la racine du projet, puis renseignez votre clé :
```
OPENWEATHER_API_KEY=votre_cle_ici
```

### 3. Configurer la clé API Google Maps
Dans `android/local.properties` (jamais versionné), ajoutez :
```
MAPS_API_KEY=votre_cle_google_maps_ici
```
Cette clé est automatiquement injectée dans `AndroidManifest.xml` au moment du build via `manifestPlaceholders` — elle n'apparaît jamais en clair dans le code source.

### 4. Générer les modèles JSON
```bash
dart run build_runner build --delete-conflicting-outputs
```

> **Note technique** : une version antérieure de `retrofit_generator` (^9.x) entrait en conflit de dépendances avec `json_serializable`/`json_annotation`, ce qui obligeait à écrire `weather_api_service.g.dart` à la main. Ce n'est plus le cas depuis le passage à `retrofit_generator: ^10.2.9` (voir `pubspec.yaml`) : ce fichier, ainsi que `forecast_response.g.dart` et les autres `*.g.dart`, sont désormais entièrement générés par `build_runner`.

### 5. Lancer l'application
```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```
L'APK généré se trouve dans `build/app/outputs/flutter-apk/app-release.apk`.

## Contribution (travail en équipe)

Le projet est organisé en deux branches de travail :
- Fonctionnalités obligatoires (P1), Google Maps, README, stabilité : Abdoul Aziz Dione
- Design général + Carte météo interactive (P2) : Sokhna Awa Dione

Voir `GUIDE_BINOME.md` pour le détail du workflow Git et de la répartition.

## Sources de données

| Donnée | Source | Écran |
|---|---|---|
| Météo actuelle (temp., humidité, vent, pression...) | OpenWeatherMap `/data/2.5/weather` | Résultats, Détail |
| Coordonnées GPS | OpenWeatherMap (incluses dans la réponse météo) | Détail |
| Localisation cartographique | Google Maps SDK | Détail |
| Couches météo (carte interactive) | Tuiles OpenWeatherMap | Carte météo |

Aucune donnée météo n'est simulée ou inventée : toutes les valeurs affichées proviennent d'appels API réels.

## Licence

Projet académique — UIDT, L3 Géomatique.
