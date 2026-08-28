import 'package:json_annotation/json_annotation.dart';
import 'weather_response.dart';

part 'forecast_response.g.dart';

/// Modèle pour l'endpoint GRATUIT `/data/2.5/forecast` d'OpenWeatherMap
/// (prévisions par pas de 3h sur 5 jours). C'est délibérément CET endpoint
/// qui alimente les prévisions horaires/quotidiennes et le curseur
/// temporel de la carte météo, et non le "One Call API 3.0" qui nécessite
/// un abonnement payant depuis 2024 — on ne prétend jamais qu'une donnée
/// est disponible si elle ne l'est pas gratuitement.
///
/// Le fichier `forecast_response.g.dart` est généré automatiquement par
/// `build_runner` (même commande que pour les autres modèles) — ne jamais
/// l'écrire à la main.
@JsonSerializable(explicitToJson: true)
class ForecastResponse {
  @JsonKey(name: 'list')
  final List<ForecastEntry> entries;

  const ForecastResponse({required this.entries});

  factory ForecastResponse.fromJson(Map<String, dynamic> json) =>
      _$ForecastResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastResponseToJson(this);

  /// Regroupe les entrées 3h par jour calendaire et calcule min/max RÉELS
  /// — aucune valeur n'est inventée, uniquement dérivée des données reçues.
  List<DailyForecast> get dailyForecasts {
    final Map<String, List<ForecastEntry>> byDay = {};
    for (final entry in entries) {
      final key =
          '${entry.dateTime.year}-${entry.dateTime.month}-${entry.dateTime.day}';
      byDay.putIfAbsent(key, () => []).add(entry);
    }

    final result = byDay.entries.map((e) {
      final dayEntries = e.value;
      final temps = dayEntries.map((x) => x.main.temp).toList();
      // Condition représentative : celle de l'entrée la plus proche de
      // midi, plus parlante qu'une moyenne pour résumer "la journée".
      final noonEntry = dayEntries.reduce((a, b) =>
          (a.dateTime.hour - 12).abs() < (b.dateTime.hour - 12).abs()
              ? a
              : b);
      return DailyForecast(
        date: dayEntries.first.dateTime,
        minTemp: temps.reduce((a, b) => a < b ? a : b),
        maxTemp: temps.reduce((a, b) => a > b ? a : b),
        condition: noonEntry.primaryCondition,
        maxPop: dayEntries.map((x) => x.pop).reduce((a, b) => a > b ? a : b),
      );
    }).toList();

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }
}

@JsonSerializable(explicitToJson: true)
class ForecastEntry {
  @JsonKey(name: 'dt')
  final int timestamp;

  @JsonKey(name: 'main')
  final WeatherMain main;

  @JsonKey(name: 'weather')
  final List<WeatherCondition> conditions;

  @JsonKey(name: 'wind')
  final WeatherWind wind;

  /// Probabilité de précipitation (0.0–1.0), champ réel renvoyé par CET
  /// endpoint précis (contrairement à /weather qui ne l'inclut pas).
  @JsonKey(name: 'pop', defaultValue: 0.0)
  final double pop;

  const ForecastEntry({
    required this.timestamp,
    required this.main,
    required this.conditions,
    required this.wind,
    required this.pop,
  });

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  WeatherCondition get primaryCondition =>
      conditions.isNotEmpty ? conditions.first : WeatherCondition.unknown();

  factory ForecastEntry.fromJson(Map<String, dynamic> json) =>
      _$ForecastEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastEntryToJson(this);
}

/// Type "vue" (pas de JSON en propre) : résultat calculé par
/// [ForecastResponse.dailyForecasts], jamais désérialisé directement.
class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final WeatherCondition condition;
  final double maxPop;

  const DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.maxPop,
  });
}
