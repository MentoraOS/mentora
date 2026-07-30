enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class WorkingHours {
  final WeekDay day;

  final Duration start;

  final Duration end;

  final bool enabled;

  const WorkingHours({
    required this.day,
    required this.start,
    required this.end,
    this.enabled = true,
  });

  Duration get totalDuration => end - start;
}
