import 'civil_date_time.dart';
import 'working_hours.dart';

/// A civil calendar date without a time of day.
///
/// AD-022 Clarification C: materialization operates on explicit civil dates.
/// The year is always explicit — never defaulted and never taken from the
/// current date. Validity is enforced here because `DateTime` silently
/// normalizes impossible dates instead of failing.
final class CivilDate implements Comparable<CivilDate> {
  final int year;
  final int month;
  final int day;

  factory CivilDate({required int year, required int month, required int day}) {
    final lastDay = CivilDateTime.daysInMonth(year: year, month: month);
    if (day < 1 || day > lastDay) {
      throw ArgumentError.value(
        day,
        'day',
        'must be between 1 and $lastDay for month $month of $year',
      );
    }

    return CivilDate._(year: year, month: month, day: day);
  }

  const CivilDate._({
    required this.year,
    required this.month,
    required this.day,
  });

  /// The weekday of this date in the proleptic Gregorian calendar.
  ///
  /// Computed from the explicit civil components only: no clock, no zone and
  /// no device state is involved.
  WeekDay get weekday {
    return WeekDay.values[DateTime.utc(year, month, day).weekday -
        DateTime.monday];
  }

  @override
  int compareTo(CivilDate other) {
    if (year != other.year) return year - other.year;
    if (month != other.month) return month - other.month;
    return day - other.day;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CivilDate &&
            other.year == year &&
            other.month == month &&
            other.day == day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'CivilDate($year-${two(month)}-${two(day)})';
  }
}
