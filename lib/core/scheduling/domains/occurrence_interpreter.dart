import '../models/civil_date_time.dart';
import '../models/reservation_occurrence.dart';
import '../ports/timezone_resolver.dart';

/// Interprets expert-local civil time into a concrete occurrence (AD-022).
///
/// Scheduling owns temporal interpretation (AD-020 decision 1). This
/// collaborator converts a proposed civil date/time plus a named timezone
/// identity plus a consultation duration into canonical UTC boundaries.
///
/// The duration is business truth originating from the selected offer under
/// AD-021. Scheduling consumes it and never defines it: there is no default
/// duration here, and none is derived from any Scheduling policy value.
///
/// The interpreter is pure. It performs no persistence, reads no catalog, no
/// occupancy and no clock, derives nothing from a country, and detects no
/// conflicts.
final class OccurrenceInterpreter {
  const OccurrenceInterpreter({required TimezoneResolver resolver})
    : _resolver = resolver;

  final TimezoneResolver _resolver;

  /// Interprets [civilDateTime] in [timezone] as an occurrence lasting
  /// [durationMinutes].
  ///
  /// Throws [ArgumentError] when the duration is not strictly positive, and
  /// [UnsupportedTimezoneException] when the resolver cannot interpret
  /// [timezone]. Both fail closed; no approximation is substituted.
  ReservationOccurrence interpret({
    required CivilDateTime civilDateTime,
    required TimezoneId timezone,
    required int durationMinutes,
  }) {
    if (durationMinutes <= 0) {
      throw ArgumentError.value(
        durationMinutes,
        'durationMinutes',
        'must be strictly positive',
      );
    }

    // Only the civil components are handed to the resolver, so no ambient
    // timezone can influence interpretation.
    final wallClock = DateTime.utc(
      civilDateTime.year,
      civilDateTime.month,
      civilDateTime.day,
      civilDateTime.hour,
      civilDateTime.minute,
    );

    final startUtc = _resolver.toUtc(localDateTime: wallClock, zone: timezone);

    return ReservationOccurrence(
      startUtc: startUtc,
      endUtc: startUtc.add(Duration(minutes: durationMinutes)),
      expertTimezone: timezone,
    );
  }
}
