import '../../domain/booking/booking_confirmation_repository.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import 'booking_confirmation_failure.dart';

/// Applies a confirmed payment outcome to the client's reservation.
///
/// AD-022 decisions 11 and 12: Booking owns this transition and consumes the
/// payment outcome through an explicit boundary. Callers invoke it ONLY on a
/// confirmed outcome — payment ambiguity, timeouts and unknown states must
/// never reach it, and a failure here must never be presented as a paid,
/// confirmed reservation.
final class BookingConfirmationApplicationService {
  const BookingConfirmationApplicationService({
    required AuthenticationSession session,
    required BookingConfirmationRepository repository,
    ConsultationMemoryApplicationService? memory,
  }) : _session = session,
       _repository = repository,
       _memory = memory;

  final AuthenticationSession _session;
  final BookingConfirmationRepository _repository;

  /// Optional memory producer; absent means no fact is recorded.
  final ConsultationMemoryApplicationService? _memory;

  Future<void> confirmPaid(String bookingId) async {
    final clientId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || clientId == null || clientId.isEmpty) {
      throw const BookingConfirmationUnauthenticatedFailure();
    }

    try {
      await _repository.confirmPaid(bookingId: bookingId, clientId: clientId);
    } on BookingConfirmationNotFoundException {
      throw const BookingConfirmationNotFoundFailure();
    } on BookingConfirmationStateException catch (error) {
      throw BookingConfirmationInvalidStateFailure(
        currentStatus: error.currentStatus,
      );
    } on BookingConfirmationRepositoryException catch (error) {
      throw BookingConfirmationRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw BookingConfirmationRepositoryFailure(cause: error);
    }

    await _recordFact(
      bookingId,
      MemoryEntryType.bookingConfirmed,
      const {},
    );
  }

  /// Best-effort memory producer (ARC-MEM01): the business fact is recorded
  /// through the single memory door AFTER the operation succeeded; a memory
  /// failure never fails the business flow.
  Future<void> _recordFact(
    String bookingId,
    MemoryEntryType type,
    Map<String, Object?> payload,
  ) async {
    try {
      await _memory?.record(bookingId: bookingId, type: type, payload: payload);
    } catch (_) {
      // Best-effort by contract.
    }
  }
}
