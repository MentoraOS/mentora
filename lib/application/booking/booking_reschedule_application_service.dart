import '../../domain/booking/booking_reschedule_repository.dart';
import '../../domain/expert_catalog/expert_catalog_entry.dart';
import '../authentication/authentication_session.dart';
import '../expert_catalog/expert_catalog_application_service.dart';
import '../scheduling/civil_occurrence_interpretation.dart';
import '../scheduling/civil_occurrence_materialization.dart';
import '../scheduling/civil_selection.dart';
import '../scheduling/selectable_occurrence_failure.dart';
import 'booking_reschedule_failure.dart';

/// Reschedules the client's reservation through the Booking-owned boundary,
/// reusing the full C2/C3 temporal path.
///
/// The new civil selection is revalidated against the expert's authoritative
/// recurring availability (AD-022 Clarification C decision 7) and interpreted
/// by Scheduling into canonical UTC boundaries (AD-022 decision 2) before
/// anything is written. The duration is the reservation's snapshotted
/// duration — never the current catalog offer and never a client value: the
/// repository additionally verifies it against the persisted reservation, so
/// a tampered duration fails closed.
///
/// Selection failures surface as the existing `SelectableOccurrenceFailure`
/// family; lifecycle failures as [BookingRescheduleFailure]. Conflict
/// exclusion for the new occurrence remains the future conflict contract.
final class BookingRescheduleApplicationService {
  const BookingRescheduleApplicationService({
    required AuthenticationSession session,
    required BookingRescheduleRepository repository,
    required ExpertCatalogApplicationService expertCatalog,
    required CivilOccurrenceMaterialization materialization,
    required CivilOccurrenceInterpretation interpretation,
  }) : _session = session,
       _repository = repository,
       _expertCatalog = expertCatalog,
       _materialization = materialization,
       _interpretation = interpretation;

  final AuthenticationSession _session;
  final BookingRescheduleRepository _repository;
  final ExpertCatalogApplicationService _expertCatalog;
  final CivilOccurrenceMaterialization _materialization;
  final CivilOccurrenceInterpretation _interpretation;

  /// Materializes the expert's selectable starts for the reschedule calendar,
  /// using the reservation's snapshotted duration.
  Future<List<CivilSelection>> materializeMonth({
    required String expertId,
    required int durationMinutes,
    required int year,
    required int month,
  }) async {
    final expert = await _requireExpert(expertId);

    return _materialization.materializeMonth(
      persistedAvailability: expert.availability,
      expertTimezone: expert.expertTimezone!,
      durationMinutes: durationMinutes,
      year: year,
      month: month,
    );
  }

  Future<void> reschedule({
    required String bookingId,
    required String expertId,
    required int durationMinutes,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) async {
    final clientId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || clientId == null || clientId.isEmpty) {
      throw const BookingRescheduleUnauthenticatedFailure();
    }

    final expert = await _requireExpert(expertId);
    final timezone = expert.expertTimezone!;

    // C2 revalidation: the new selection must belong to the legitimately
    // materialized candidate set for its own civil date.
    final candidates = _materialization.materializeDay(
      persistedAvailability: expert.availability,
      expertTimezone: timezone,
      durationMinutes: durationMinutes,
      year: year,
      month: month,
      day: day,
    );

    final CivilSelection selected;
    try {
      selected = CivilSelection(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        durationMinutes: durationMinutes,
      );
    } on ArgumentError {
      throw const SelectableOccurrenceNotOfferedFailure();
    }
    if (!candidates.contains(selected)) {
      throw const SelectableOccurrenceNotOfferedFailure();
    }

    // C3 interpretation: Scheduling produces the canonical UTC boundaries.
    final snapshot = _interpretation.interpret(
      selection: selected,
      expertTimezone: timezone,
    );

    final update = BookingRescheduleUpdate(
      startUtc: snapshot.startUtc,
      endUtc: snapshot.endUtc,
      expertTimezone: snapshot.expertTimezone,
      bookingDate: _legacyDate(selected),
      bookingTime: _legacyTime(selected),
    );

    try {
      await _repository.reschedule(
        bookingId: bookingId,
        clientId: clientId,
        update: update,
      );
    } on BookingRescheduleNotFoundException {
      throw const BookingRescheduleNotFoundFailure();
    } on BookingRescheduleStateException catch (error) {
      throw BookingRescheduleInvalidStateFailure(
        currentStatus: error.currentStatus,
      );
    } on BookingRescheduleConsistencyException {
      throw const BookingRescheduleInconsistentFailure();
    } on BookingRescheduleRepositoryException catch (error) {
      throw BookingRescheduleRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw BookingRescheduleRepositoryFailure(cause: error);
    }
  }

  Future<ExpertCatalogEntry> _requireExpert(String expertId) async {
    final expert = await _expertCatalog.findById(expertId);
    if (expert == null) {
      throw const SelectableOccurrenceExpertNotFoundFailure();
    }
    final timezone = expert.expertTimezone;
    if (timezone == null || timezone.trim().isEmpty) {
      throw const SelectableOccurrenceTimezoneUnavailableFailure();
    }
    return expert;
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _legacyDate(CivilSelection selection) {
    return '${selection.year}-${_two(selection.month)}-'
        '${_two(selection.day)}';
  }

  static String _legacyTime(CivilSelection selection) {
    return '${_two(selection.hour)}:${_two(selection.minute)}';
  }
}
