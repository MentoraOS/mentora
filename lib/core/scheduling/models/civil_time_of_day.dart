/// A civil wall-clock time of day, independent of any calendar date.
///
/// AD-022 Clarification C: recurring expert availability is declared as
/// candidate start times. Such a time exists on no particular date, so it is
/// represented on its own rather than through a dated value. It carries no
/// year, no month, no day, no zone identity and no length: a time of day is a
/// point in the civil day, nothing more.
final class CivilTimeOfDay implements Comparable<CivilTimeOfDay> {
  final int hour;
  final int minute;

  factory CivilTimeOfDay({required int hour, required int minute}) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'must be between 0 and 23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(minute, 'minute', 'must be between 0 and 59');
    }

    return CivilTimeOfDay._(hour: hour, minute: minute);
  }

  const CivilTimeOfDay._({required this.hour, required this.minute});

  @override
  int compareTo(CivilTimeOfDay other) {
    return (hour * 60 + minute) - (other.hour * 60 + other.minute);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CivilTimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'CivilTimeOfDay(${two(hour)}:${two(minute)})';
  }
}
