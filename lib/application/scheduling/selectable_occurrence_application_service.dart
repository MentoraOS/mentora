import '../../domain/expert_catalog/consultation_offer.dart';
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
  }) : _expertCatalog = expertCatalog,
       _materialization = materialization;

  final ExpertCatalogApplicationService _expertCatalog;
  final CivilOccurrenceMaterialization _materialization;

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

    return _materialization.materializeMonth(
      persistedAvailability: expert.availability,
      expertTimezone: expert.expertTimezone!,
      durationMinutes: offer.durationMinutes,
      year: year,
      month: month,
    );
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

    if (!candidates.contains(selected)) {
      throw const SelectableOccurrenceNotOfferedFailure();
    }

    return selected;
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
