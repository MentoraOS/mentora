import 'calendar_slot.dart';

class AvailabilityResult {
  final bool available;

  final String? reason;

  final List<CalendarSlot> slots;

  const AvailabilityResult({
    required this.available,
    required this.slots,
    this.reason,
  });
}
