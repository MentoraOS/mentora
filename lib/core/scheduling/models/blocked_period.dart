class BlockedPeriod {
  final DateTime start;

  final DateTime end;

  final String reason;

  const BlockedPeriod({
    required this.start,
    required this.end,
    required this.reason,
  });

  bool contains(DateTime value) {
    return value.isAfter(start) && value.isBefore(end);
  }
}
