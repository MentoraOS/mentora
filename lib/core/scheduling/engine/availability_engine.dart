import '../domains/availability_domain.dart';
import '../models/availability_result.dart';
import '../models/availability_rule.dart';
import '../models/blocked_period.dart';
import '../models/working_hours.dart';

class AvailabilityEngine {
  AvailabilityEngine._();

  static final AvailabilityEngine instance = AvailabilityEngine._();

  final AvailabilityDomain _domain = const AvailabilityDomain();

  AvailabilityResult generateSlots({
    required DateTime date,
    required List<WorkingHours> workingHours,
    required List<BlockedPeriod> blockedPeriods,
    required AvailabilityRule rule,
  }) {
    return _domain.generateSlots(
      date: date,
      workingHours: workingHours,
      blockedPeriods: blockedPeriods,
      rule: rule,
    );
  }
}
