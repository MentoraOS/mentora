import '../../application/scheduling/civil_occurrence_interpretation.dart';
import '../../application/scheduling/civil_selection.dart';
import '../../application/scheduling/reservation_temporal_snapshot.dart';
import '../../application/scheduling/selectable_occurrence_failure.dart';
import '../../core/scheduling/scheduling.dart';

/// Infrastructure adapter implementing the Application interpretation port
/// over the Scheduling module (AD-022 decision 2).
///
/// Scheduling owns temporal interpretation: this adapter only bridges. It
/// validates the timezone identity through the Scheduling-owned [TimezoneId],
/// rebuilds the Wave B [CivilDateTime] from the structured selection, and
/// delegates to the Wave B [OccurrenceInterpreter] with the injected
/// production [TimezoneResolver]. The resulting occurrence is converted to
/// the Application snapshot value with the timezone identity preserved
/// verbatim.
///
/// The adapter reads no clock, no persistence and no country, and fails
/// closed: an unsupported or malformed identity, or an uninterpretable civil
/// value, never yields a snapshot.
final class CivilOccurrenceInterpretationAdapter
    implements CivilOccurrenceInterpretation {
  const CivilOccurrenceInterpretationAdapter({
    required TimezoneResolver resolver,
  }) : _resolver = resolver;

  final TimezoneResolver _resolver;

  @override
  ReservationTemporalSnapshot interpret({
    required CivilSelection selection,
    required String expertTimezone,
  }) {
    final TimezoneId zone;
    try {
      zone = TimezoneId(expertTimezone);
    } on ArgumentError {
      throw const SelectableOccurrenceTimezoneUnavailableFailure();
    }

    final ReservationOccurrence occurrence;
    try {
      occurrence = OccurrenceInterpreter(resolver: _resolver).interpret(
        civilDateTime: CivilDateTime(
          year: selection.year,
          month: selection.month,
          day: selection.day,
          hour: selection.hour,
          minute: selection.minute,
        ),
        timezone: zone,
        durationMinutes: selection.durationMinutes,
      );
    } on UnsupportedTimezoneException {
      throw const SelectableOccurrenceTimezoneUnavailableFailure();
    } on ArgumentError catch (error) {
      throw SelectableOccurrenceInterpretationFailure(cause: error);
    }

    return ReservationTemporalSnapshot(
      startUtc: occurrence.startUtc,
      endUtc: occurrence.endUtc,
      expertTimezone: occurrence.expertTimezone.value,
    );
  }
}
