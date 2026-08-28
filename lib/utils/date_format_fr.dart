/// Formatage de dates en français, écrit à la main pour éviter d'ajouter
/// la dépendance `intl` juste pour quelques libellés simples.
class DateFormatFr {
  DateFormatFr._();

  static const _weekdays = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
  ];

  static const _weekdaysShort = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  static String weekday(DateTime date) => _weekdays[date.weekday - 1];

  static String weekdayShort(DateTime date) => _weekdaysShort[date.weekday - 1];

  static String hourMinute(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}h'
      '${date.minute > 0 ? date.minute.toString().padLeft(2, '0') : ''}';

  static String hour(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}h';
}
