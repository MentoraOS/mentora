import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/scheduling/engine/availability_engine.dart';
import 'package:mentora/core/scheduling/models/availability_rule.dart';
import 'package:mentora/core/scheduling/models/blocked_period.dart';
import 'package:mentora/core/scheduling/models/working_hours.dart';

void main() {
  group('Availability Engine', () {
    test('should generate available slots', () {
      final result = AvailabilityEngine.instance.generateSlots(
        date: DateTime(2026, 7, 6), // Monday
        workingHours: const [
          WorkingHours(
            day: WeekDay.monday,
            start: Duration(hours: 9),
            end: Duration(hours: 12),
          ),
        ],
        blockedPeriods: const [],
        rule: const AvailabilityRule(
          consultationDuration: Duration(minutes: 30),
          breakBetweenMeetings: Duration(minutes: 0),
          maximumBookingsPerDay: 10,
          minimumNotice: Duration(hours: 1),
          maximumAdvanceBooking: Duration(days: 30),
        ),
      );

      expect(result.available, isTrue);
      expect(result.slots.length, 6);
    });

    test('should exclude blocked periods', () {
      final result = AvailabilityEngine.instance.generateSlots(
        date: DateTime(2026, 7, 6), // Monday
        workingHours: const [
          WorkingHours(
            day: WeekDay.monday,
            start: Duration(hours: 9),
            end: Duration(hours: 12),
          ),
        ],
        blockedPeriods: [
          BlockedPeriod(
            start: DateTime(2026, 7, 6, 10),
            end: DateTime(2026, 7, 6, 11),
            reason: 'Internal meeting',
          ),
        ],
        rule: const AvailabilityRule(
          consultationDuration: Duration(minutes: 30),
          breakBetweenMeetings: Duration(minutes: 0),
          maximumBookingsPerDay: 10,
          minimumNotice: Duration(hours: 1),
          maximumAdvanceBooking: Duration(days: 30),
        ),
      );

      expect(result.available, isTrue);
      expect(result.slots.length, 4);
    });
  });
}
