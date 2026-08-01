import '../../domain/expert_catalog/consultation_offer.dart';
import '../../domain/expert_availability_exception/expert_availability_exception.dart';
import '../../domain/expert_catalog/expert_catalog_entry.dart';
import '../expert_catalog/expert_catalog_application_service.dart';
import 'civil_occurrence_materialization.dart';
import 'civil_selection.dart';
import 'selectable_occurrence_failure.dart';

/// Orchestrates selectable civil occurrence materialization and revalidation.
///
/// AD-022 Clarification C decision 7: Application owns authoritative
/// revalidation. That Presentation displayed a slot is never sufficient — this
/// service re-establishes the expert, the expert's timezone identity, the
/// authoritative recurring availability and the offer duration, and asks the
/// Scheduling-owned materialization (behind [CivilOccurrenceMaterialization])
/// whether the selection belongs to the legitimately offered candidate set.
///
/// This answers only "was this occurrence legitimately offered?". It does NOT
/// answer atomic reservability (decision 11), produces no UTC boundary (that
/// interpretation is the accepted-selection step toward Booking), reads no
/// clock, and never derives a timezone from a country.
final class SelectableOccurrenceApplicationService {
  const SelectableOccurrenceApplicationService({
    required ExpertCatalogApplicationService expertCatalog,
    required CivilOccurrenceMaterialization materialization,
    ExpertAvailabilityExceptionRepository? availabilityExceptions,
  }) : _expertCatalog = expertCatalog,
       _materialization = materialization,
       _availabilityExceptions = availabilityExceptions;

  final ExpertCatalogApplicationService _expertCatalog;
  final CivilOccurrenceMaterialization _materialization;

  /// Expert unavailability windows. Optional and additive: when absent, no
  /// exception filtering applies (Clarification C decision 9 kept blocked
  /// periods a first-class future input; this is that additive input,
  /// applied as a civil-date filter without touching the frozen generator).
  final ExpertAvailabilityExceptionRepository? _availabilityExceptions;

  /// Materializes the expert's selectable starts for one civil month.
  ///
  /// Fails closed with a [SelectableOccurrenceFailure] when the expert is
  /// missing, the offer belongs to another expert, the expert has no
  /// authoritative timezone identity, or the persisted availability violates
  /// the legacy grammar. Catalog infrastructure failures propagate unchanged.
  Future<List<CivilSelection>> materializeMonth({
    required String expertId,
    required ConsultationOffer offer,
    required int year,
    required int month,
  }) async {
    final expert = await _requireAuthoritativeInputs(
      expertId: expertId,
      offer: offer,
    );

    final occurrences = _materialization.materializeMonth(
      persistedAvailability: expert.availability,
      expertTimezone: expert.expertTimezone!,
      durationMinutes: offer.durationMinutes,
      year: year,
      month: month,
    );

    return _withoutBlockedDates(expertId, occurrences);
  }

  /// Revalidates a client-submitted structured selection against
  /// authoritative inputs.
  ///
  /// The materialization range is derived from the explicit selection itself:
  /// the single civil date the client selected. A well-formed but non-offered
  /// date or time fails closed with [SelectableOccurrenceNotOfferedFailure].
  Future<CivilSelection> revalidate({
    required String expertId,
    required ConsultationOffer offer,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) async {
    final intent = await revalidateForReservation(
      expertId: expertId,
      offer: offer,
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
    );

    return intent.selection;
  }

  /// [revalidate], additionally returning the authoritative expert timezone
  /// identity established during the same authoritative pass.
  ///
  /// AD-022 C3 consumes this to interpret the accepted selection into the
  /// canonical reservation snapshot without a second Catalog lookup.
  Future<({CivilSelection selection, String expertTimezone})>
  revalidateForReservation({
    required String expertId,
    required ConsultationOffer offer,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) async {
    final expert = await _requireAuthoritativeInputs(
      expertId: expertId,
      offer: offer,
    );

    final List<CivilSelection> candidates;
    try {
      candidates = _materialization.materializeDay(
        persistedAvailability: expert.availability,
        expertTimezone: expert.expertTimezone!,
        durationMinutes: offer.durationMinutes,
        year: year,
        month: month,
        day: day,
      );
    } on ArgumentError {
      // An impossible civil value (such as 30 February) was submitted; it is
      // not an offered occurrence.
      throw const SelectableOccurrenceNotOfferedFailure();
    }

    final CivilSelection selected;
    try {
      selected = CivilSelection(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        durationMinutes: offer.durationMinutes,
      );
    } on ArgumentError {
      throw const SelectableOccurrenceNotOfferedFailure();
    }

    final offered = await _withoutBlockedDates(expertId, candidates);
    if (!offered.contains(selected)) {
      throw const SelectableOccurrenceNotOfferedFailure();
    }

    return (selection: selected, expertTimezone: expert.expertTimezone!);
  }

  /// Removes occurrences whose civil date falls inside one of the expert's
  /// unavailability windows. Whole civil days only; string comparison on the
  /// strict date grammar, no clock and no timezone involved.
  Future<List<CivilSelection>> _withoutBlockedDates(
    String expertId,
    List<CivilSelection> occurrences,
  ) async {
    final repository = _availabilityExceptions;
    if (repository == null || occurrences.isEmpty) return occurrences;

    final exceptions = await repository.listByExpertId(expertId);
    if (exceptions.isEmpty) return occurrences;

    String two(int value) => value.toString().padLeft(2, '0');
    return List.unmodifiable(
      occurrences.where((occurrence) {
        final date =
            '${occurrence.year}-${two(occurrence.month)}-'
            '${two(occurrence.day)}';
        return !exceptions.any((exception) => exception.blocksDate(date));
      }),
    );
  }

  Future<ExpertCatalogEntry> _requireAuthoritativeInputs({
    required String expertId,
    required ConsultationOffer offer,
  }) async {
    final expert = await _expertCatalog.findById(expertId);
    if (expert == null) {
      throw const SelectableOccurrenceExpertNotFoundFailure();
    }
    if (offer.expertId != expertId) {
      throw const SelectableOccurrenceOfferMismatchFailure();
    }

    // AD-022 Clarification A: no fallback identity is ever substituted. The
    // full identity-shape validation happens where Scheduling interprets, in
    // the materialization adapter; absence is rejected here.
    final timezone = expert.expertTimezone;
    if (timezone == null || timezone.trim().isEmpty) {
      throw const SelectableOccurrenceTimezoneUnavailableFailure();
    }

    return expert;
  }
}
