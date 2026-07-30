import '../models/timezone_info.dart';

class TimezoneEngine {
  TimezoneEngine._();

  static final TimezoneEngine instance = TimezoneEngine._();

  DateTime nowUtc() {
    return DateTime.now().toUtc();
  }

  DateTime toUtc(DateTime localDateTime) {
    return localDateTime.toUtc();
  }

  DateTime fromUtc({
    required DateTime utcDateTime,
    required TimezoneInfo timezone,
  }) {
    return utcDateTime.toUtc().add(timezone.offset);
  }

  DateTime convert({
    required DateTime dateTime,
    required TimezoneInfo from,
    required TimezoneInfo to,
  }) {
    final utc = dateTime.subtract(from.offset);
    return utc.add(to.offset);
  }

  bool isSameMoment({
    required DateTime first,
    required TimezoneInfo firstTimezone,
    required DateTime second,
    required TimezoneInfo secondTimezone,
  }) {
    final firstUtc = first.subtract(firstTimezone.offset);
    final secondUtc = second.subtract(secondTimezone.offset);

    return firstUtc.isAtSameMomentAs(secondUtc);
  }
}
