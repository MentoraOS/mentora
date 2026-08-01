import 'civil_selection.dart';
import 'reservation_temporal_snapshot.dart';

/// Application-owned port to the Scheduling-owned interpretation of a
/// validated civil selection into canonical UTC boundaries (AD-022
/// decision 2).
///
/// The implementation (an Infrastructure adapter over the Scheduling module
/// and its production resolver) converts the expert-local civil value plus
/// the authoritative timezone identity into absolute instants. Booking never
/// interprets timezones itself and Presentation never manufactures UTC; both
/// sides of that boundary meet here.
///
/// Implementations fail closed with the typed selectable-occurrence failures
/// when the identity is malformed or unsupported, or when the civil value
/// cannot be interpreted. No approximation is ever substituted.
abstract interface class CivilOccurrenceInterpretation {
  ReservationTemporalSnapshot interpret({
    required CivilSelection selection,
    required String expertTimezone,
  });
}
