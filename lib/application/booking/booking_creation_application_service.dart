import '../../domain/booking/booking_creation.dart';
import '../../domain/booking/booking_creation_repository.dart';
import '../../domain/expert_catalog/consultation_offer.dart';
import '../authentication/authentication_session.dart';
import '../scheduling/civil_occurrence_interpretation.dart';
import '../scheduling/civil_selection.dart';
import '../scheduling/selectable_occurrence_application_service.dart';
import 'booking_creation_failure.dart';

typedef BookingChannelFactory = String Function();

final class BookingCreationApplicationService {
  BookingCreationApplicationService({
    required AuthenticationSession session,
    required BookingCreationRepository repository,
    required SelectableOccurrenceApplicationService selectableOccurrences,
    required CivilOccurrenceInterpretation interpretation,
    BookingChannelFactory? channelFactory,
  }) : _session = session,
       _repository = repository,
       _selectableOccurrences = selectableOccurrences,
       _interpretation = interpretation,
       _channelFactory = channelFactory ?? _defaultChannel;

  final AuthenticationSession _session;
  final BookingCreationRepository _repository;
  final SelectableOccurrenceApplicationService _selectableOccurrences;
  final CivilOccurrenceInterpretation _interpretation;
  final BookingChannelFactory _channelFactory;

  /// Creates the initial Booking from the authoritative selected offer and
  /// the structured civil selection.
  ///
  /// [offer] is the single commercial source (AD-021). [occurrence] is
  /// reservation intent only: it is revalidated against authoritative
  /// availability (AD-022 Clarification C decision 7), then interpreted by
  /// Scheduling into the canonical UTC occurrence that Booking snapshots
  /// (AD-022 decisions 1 and 2). Client-supplied UTC boundaries are never
  /// accepted; the duration is the offer's, never the client's.
  ///
  /// Revalidation and interpretation failures
  /// (`SelectableOccurrenceFailure`, `ExpertCatalogFailure`) propagate
  /// unchanged so callers can distinguish them from Booking persistence
  /// failures.
  Future<String> create({
    required String expertId,
    required String expertName,
    required CivilSelection occurrence,
    required String clientNeed,
    required String aiSummary,
    required ConsultationOffer offer,
  }) async {
    final clientId = _session.currentUserId;
    if (!_session.isAuthenticated ||
        clientId == null ||
        clientId.trim().isEmpty) {
      throw const BookingCreationUnauthenticatedFailure();
    }

    if (!offer.clientSelectable) {
      throw const BookingCreationOfferUnavailableFailure();
    }
    // ARCH-008 semantics preserved: a blank expert identity is an invalid
    // request, never a mismatch and never a lookup.
    if (expertId.trim().isEmpty) {
      throw BookingCreationInvalidRequestFailure(
        cause: ArgumentError.value(expertId, 'expertId', 'must not be empty'),
      );
    }
    if (offer.expertId != expertId) {
      throw const BookingCreationExpertMismatchFailure();
    }

    // AD-022 Clarification C decision 7 + C3: the displayed slot is not
    // sufficient. The selection is revalidated against authoritative inputs,
    // then Scheduling interprets it into canonical UTC boundaries.
    final intent = await _selectableOccurrences.revalidateForReservation(
      expertId: expertId,
      offer: offer,
      year: occurrence.year,
      month: occurrence.month,
      day: occurrence.day,
      hour: occurrence.hour,
      minute: occurrence.minute,
    );
    final snapshot = _interpretation.interpret(
      selection: intent.selection,
      expertTimezone: intent.expertTimezone,
    );

    late final BookingCreation booking;
    try {
      booking = BookingCreation(
        clientId: clientId,
        expertId: expertId,
        expertName: expertName,
        bookingDate: _legacyDate(intent.selection),
        bookingTime: _legacyTime(intent.selection),
        agoraChannel: _channelFactory(),
        clientNeed: clientNeed,
        aiSummary: aiSummary,
        offerId: offer.offerId,
        durationMinutes: offer.durationMinutes,
        amountMinor: offer.amountMinor,
        currency: offer.currency,
        startUtc: snapshot.startUtc,
        endUtc: snapshot.endUtc,
        expertTimezone: snapshot.expertTimezone,
      );
    } on ArgumentError catch (error) {
      throw BookingCreationInvalidRequestFailure(cause: error);
    }

    try {
      return await _repository.create(booking);
    } on BookingCreationConflictException {
      throw const BookingCreationSlotConflictFailure();
    } on BookingCreationRepositoryException catch (error) {
      if (error.malformedData) {
        throw BookingCreationMalformedDataFailure(cause: error.cause);
      }
      if (error.infrastructureUnavailable) {
        throw BookingCreationInfrastructureUnavailableFailure(
          cause: error.cause,
        );
      }
      throw BookingCreationPersistenceFailure(cause: error.cause);
    } catch (error) {
      throw BookingCreationPersistenceFailure(cause: error);
    }
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// Legacy compatibility/display transport (AD-022 Clarification C decision
  /// 12): deterministic strings derived from the validated selection. After
  /// C3 these are NOT the canonical temporal authority; the snapshot is.
  static String _legacyDate(CivilSelection selection) {
    return '${selection.year}-${_two(selection.month)}-'
        '${_two(selection.day)}';
  }

  static String _legacyTime(CivilSelection selection) {
    return '${_two(selection.hour)}:${_two(selection.minute)}';
  }

  static String _defaultChannel() =>
      'mentora_${DateTime.now().millisecondsSinceEpoch}';
}
