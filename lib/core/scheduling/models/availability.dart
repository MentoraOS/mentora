import 'calendar_slot.dart';

class Availability {
  final String expertId;

  final List<CalendarSlot> slots;

  const Availability({required this.expertId, required this.slots});

  bool get hasAvailability => slots.isNotEmpty;

  int get totalSlots => slots.length;
}
