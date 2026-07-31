/// The structured civil selection transported across the Application
/// boundary.
///
/// AD-022 Clarification C decision 5: a selected civil value carries explicit
/// `year`, `month`, `day`, `hour` and `minute` as structured components, plus
/// the authoritative offer duration. Presentation displays and transports
/// this value; it never reconstructs it from a localized string.
///
/// This is a boundary transport value, NOT a competing canonical temporal
/// model: canonical civil-occurrence truth remains the Scheduling-owned
/// model, produced behind the Application materialization port. Validation
/// here is structural only; authoritative validity (real calendar date,
/// legitimately offered start) is established by Scheduling through that
/// port.
final class CivilSelection {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int durationMinutes;

  factory CivilSelection({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required int durationMinutes,
  }) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be between 1 and 12');
    }
    if (day < 1 || day > 31) {
      throw ArgumentError.value(day, 'day', 'must be between 1 and 31');
    }
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'must be between 0 and 23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(minute, 'minute', 'must be between 0 and 59');
    }
    if (durationMinutes <= 0) {
      throw ArgumentError.value(
        durationMinutes,
        'durationMinutes',
        'must be strictly positive',
      );
    }

    return CivilSelection._(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      durationMinutes: durationMinutes,
    );
  }

  const CivilSelection._({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.durationMinutes,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CivilSelection &&
            other.year == year &&
            other.month == month &&
            other.day == day &&
            other.hour == hour &&
            other.minute == minute &&
            other.durationMinutes == durationMinutes;
  }

  @override
  int get hashCode =>
      Object.hash(year, month, day, hour, minute, durationMinutes);

  @override
  String toString() {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'CivilSelection($year-${two(month)}-${two(day)} '
        '${two(hour)}:${two(minute)}, ${durationMinutes}m)';
  }
}
