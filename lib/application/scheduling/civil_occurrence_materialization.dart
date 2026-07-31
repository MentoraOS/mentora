import 'civil_selection.dart';

/// Application-owned port to the Scheduling-owned materialization of
/// recurring availability into selectable civil occurrences.
///
/// AD-022 Clarification C decision 9: Scheduling owns the transformation.
/// The implementation (an Infrastructure adapter over the Scheduling module)
/// applies the strict legacy availability grammar, validates the timezone
/// identity and materializes candidate starts. Application depends on this
/// port only, which keeps the frozen legacy Scheduling engine's module out of
/// the Presentation/Application dependency graph.
///
/// Implementations fail closed with the typed selectable-occurrence failures:
/// a malformed persisted availability rule or a non-authoritative timezone
/// identity never yields candidates.
abstract interface class CivilOccurrenceMaterialization {
  /// Materializes every selectable start in the civil month [year]-[month].
  ///
  /// The month is an explicit materialization range input, not a booking
  /// horizon. Results are deterministic: date ascending, then time ascending.
  List<CivilSelection> materializeMonth({
    required Map<String, List<String>> persistedAvailability,
    required String expertTimezone,
    required int durationMinutes,
    required int year,
    required int month,
  });

  /// Materializes every selectable start on the single explicit civil date
  /// [year]-[month]-[day]; the revalidation range derived from a selection.
  List<CivilSelection> materializeDay({
    required Map<String, List<String>> persistedAvailability,
    required String expertTimezone,
    required int durationMinutes,
    required int year,
    required int month,
    required int day,
  });
}
