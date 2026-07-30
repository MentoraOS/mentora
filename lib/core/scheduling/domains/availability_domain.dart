import '../models/availability_result.dart';
import '../models/availability_rule.dart';
import '../models/blocked_period.dart';
import '../models/calendar_slot.dart';
import '../models/working_hours.dart';

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

    for (final period in hours) {
      var cursor = DateTime(date.year, date.month, date.day).add(period.start);

      final end = DateTime(date.year, date.month, date.day).add(period.end);

      while (cursor.add(rule.consultationDuration).isBefore(end) ||
          cursor.add(rule.consultationDuration).isAtSameMomentAs(end)) {
        final slot = CalendarSlot(
          start: cursor,
          end: cursor.add(rule.consultationDuration),
        );

        final blocked = blockedPeriods.any(
          (blockedPeriod) =>
              slot.start.isBefore(blockedPeriod.end) &&
              slot.end.isAfter(blockedPeriod.start),
        );

        if (!blocked) {
          slots.add(slot);
        }

        cursor = cursor
            .add(rule.consultationDuration)
            .add(rule.breakBetweenMeetings);
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
