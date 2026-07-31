/// Failures of the selectable-occurrence Application boundary.
///
/// AD-022 Clarification C: modern occurrence materialization and revalidation
/// fail closed. None of these failures may be interpreted as "the occurrence
/// is available" or silently replaced by a default.
///
/// Infrastructure unavailability is NOT represented here: the underlying
/// Catalog failure (`ExpertCatalogInfrastructureFailure`) propagates
/// unchanged, so callers can always distinguish "the expert does not offer
/// this" from "the platform could not check".
sealed class SelectableOccurrenceFailure implements Exception {
  const SelectableOccurrenceFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No authoritative Catalog entry exists for the requested expert.
final class SelectableOccurrenceExpertNotFoundFailure
    extends SelectableOccurrenceFailure {
  const SelectableOccurrenceExpertNotFoundFailure()
    : super('no authoritative Catalog entry exists for this expert');
}

/// The expert has no authoritative timezone identity, or it is malformed.
///
/// AD-022 Clarification A: no fallback to UTC, device, country, server or a
/// hardcoded launch-market zone is permitted.
final class SelectableOccurrenceTimezoneUnavailableFailure
    extends SelectableOccurrenceFailure {
  const SelectableOccurrenceTimezoneUnavailableFailure()
    : super('the expert has no authoritative timezone identity');
}

/// The selected offer does not belong to the expert being booked (AD-021
/// decision 8).
final class SelectableOccurrenceOfferMismatchFailure
    extends SelectableOccurrenceFailure {
  const SelectableOccurrenceOfferMismatchFailure()
    : super('the selected offer does not belong to this expert');
}

/// The expert's persisted availability violates the legacy compatibility
/// grammar (AD-022 Clarification C decisions 3 and 4).
final class SelectableOccurrenceMalformedAvailabilityFailure
    extends SelectableOccurrenceFailure {
  const SelectableOccurrenceMalformedAvailabilityFailure({required this.cause})
    : super('the persisted availability rule is malformed');

  final Object cause;
}

/// The submitted occurrence is not in the legitimately materialized candidate
/// set (AD-022 Clarification C decision 7).
final class SelectableOccurrenceNotOfferedFailure
    extends SelectableOccurrenceFailure {
  const SelectableOccurrenceNotOfferedFailure()
    : super('the selected occurrence is not offered by this expert');
}
