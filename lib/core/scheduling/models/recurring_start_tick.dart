import 'civil_time_of_day.dart';
import 'working_hours.dart';

/// A recurring weekly candidate start: a weekday plus a civil time of day.
///
/// AD-022 Clarification C: persisted expert availability denotes recurring
/// candidate START TIMES. A tick such as Monday 09:00 is a start point, not an
/// interval. It has no end, and no end may be inferred from a neighbouring
/// tick, from a default, or from any other source. Consultation length is
/// commercial truth owned elsewhere (AD-021) and is consumed only when
/// candidate occurrences are materialized in a later slice.
///
/// This is deliberately not a `WorkingHours` value: a range carries an end, a
/// tick does not. The two are distinct responsibilities under AD-020
/// decision 2 and AD-022 Clarification C decision 1.
///
/// A tick is a value. It carries no expert identity, no offer identity, no
/// zone identity, no calendar date and no occupancy state.
final class RecurringStartTick implements Comparable<RecurringStartTick> {
  final WeekDay weekday;
  final CivilTimeOfDay timeOfDay;

  const RecurringStartTick({required this.weekday, required this.timeOfDay});

  @override
  int compareTo(RecurringStartTick other) {
    final byWeekday = weekday.index - other.weekday.index;
    if (byWeekday != 0) {
      return byWeekday;
    }

    return timeOfDay.compareTo(other.timeOfDay);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RecurringStartTick &&
            other.weekday == weekday &&
            other.timeOfDay == timeOfDay;
  }

  @override
  int get hashCode => Object.hash(weekday, timeOfDay);

  @override
  String toString() => 'RecurringStartTick($weekday, $timeOfDay)';
}
