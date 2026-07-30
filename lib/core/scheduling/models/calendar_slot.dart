class CalendarSlot {
  final DateTime start;

  final DateTime end;

  final bool available;

  const CalendarSlot({
    required this.start,
    required this.end,
    this.available = true,
  });

  Duration get duration => end.difference(start);

  bool contains(DateTime value) {
    return value.isAfter(start) && value.isBefore(end);
  }
}
