import '../models/availability_result.dart';
import '../models/availability_rule.dart';
import '../models/blocked_period.dart';
import '../models/calendar_slot.dart';
import '../models/working_hours.dart';

/// Pure generation of candidate consultation slots (AD-020).
///
/// Temporal reasoning is half-open `[start, end)`. Candidate starts advance by
/// [AvailabilityRule.slotGranularity] — never by the consultation duration and
/// never by the break buffer. A candidate whose interval would exceed its
/// availability range is not produced.
///
/// Scope limit (AD-020): [generateSlots] interprets the supplied date and
/// [WorkingHours] as civil time in the ambient calendar. Resolving
/// expert-local civil time to concrete instants requires a `TimezoneResolver`
/// implementation, which is not authorized in this wave. This function
/// therefore makes no IANA or DST correctness claim.
class AvailabilityDomain {
  const AvailabilityDomain();

  AvailabilityResult generateSlots({
    required DateTime date,
    required List<WorkingHours> workingHours,
    required List<BlockedPeriod> blockedPeriods,
    required AvailabilityRule rule,
  }) {
    final day = _weekDayFromDate(date);

    final hours = workingHours
        .where((item) => item.day == day && item.enabled)
        .toList();

    if (hours.isEmpty) {
      return const AvailabilityResult(
        available: false,
        reason: 'No working hours for this day',
        slots: [],
      );
    }

    final slots = <CalendarSlot>[];

    final startOfDay = DateTime(date.year, date.month, date.day);

    for (final period in hours) {
      final rangeEnd = startOfDay.add(period.end);

      var cursor = startOfDay.add(period.start);

      while (!cursor.add(rule.consultationDuration).isAfter(rangeEnd)) {
        final slot = CalendarSlot(
          start: cursor,
          end: cursor.add(rule.consultationDuration),
        );

        final blocked = blockedPeriods.any(
          (blockedPeriod) => blockedPeriod.overlaps(slot.start, slot.end),
        );

        if (!blocked) {
          slots.add(slot);
        }

        cursor = cursor.add(rule.slotGranularity);
      }
    }

    return AvailabilityResult(
      available: slots.isNotEmpty,
      reason: slots.isEmpty ? 'No available slots' : null,
      slots: slots,
    );
  }

  WeekDay _weekDayFromDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return WeekDay.monday;
      case DateTime.tuesday:
        return WeekDay.tuesday;
      case DateTime.wednesday:
        return WeekDay.wednesday;
      case DateTime.thursday:
        return WeekDay.thursday;
      case DateTime.friday:
        return WeekDay.friday;
      case DateTime.saturday:
        return WeekDay.saturday;
      case DateTime.sunday:
      default:
        return WeekDay.sunday;
    }
  }
}
