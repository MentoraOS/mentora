/// An expert-local civil (wall-clock) date and time.
///
/// AD-022: Presentation may propose civil values, but they are not temporal
/// truth on their own. A civil value only becomes an instant once Scheduling
/// interprets it against a named timezone identity.
///
/// Components are numeric. Localized or formatted strings such as
/// `25 juillet`, `July 25` or `09:00` are Presentation concerns and are never
/// canonical values. The year is always explicit: it is never defaulted and
/// never taken from the current date.
///
/// Structural validity is enforced here rather than delegated to `DateTime`,
/// because `DateTime` silently normalizes impossible dates — 29 February in a
/// non-leap year would become 1 March instead of failing.
final class CivilDateTime {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;

  factory CivilDateTime({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be between 1 and 12');
    }

    final lastDay = daysInMonth(year: year, month: month);
    if (day < 1 || day > lastDay) {
      throw ArgumentError.value(
        day,
        'day',
        'must be between 1 and $lastDay for month $month of $year',
      );
    }
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'must be between 0 and 23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(minute, 'minute', 'must be between 0 and 59');
    }

    return CivilDateTime._(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
    );
  }

  const CivilDateTime._({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
  });

  static const List<int> _monthLengths = <int>[
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];

  /// Whether [year] is a leap year in the proleptic Gregorian calendar.
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  /// The number of days in [month] of [year].
  static int daysInMonth({required int year, required int month}) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be between 1 and 12');
    }
    if (month == 2 && isLeapYear(year)) {
      return 29;
    }

    return _monthLengths[month - 1];
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CivilDateTime &&
            other.year == year &&
            other.month == month &&
            other.day == day &&
            other.hour == hour &&
            other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(year, month, day, hour, minute);

  @override
  String toString() {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'CivilDateTime($year-${two(month)}-${two(day)} '
        '${two(hour)}:${two(minute)})';
  }
}
