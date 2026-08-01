import '../../domain/booking/booking_cancellation_repository.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import 'booking_cancellation_failure.dart';

/// Cancels the client's reservation through the Booking-owned boundary.
///
/// Booking owns its lifecycle: this service verifies the session, delegates
/// the guarded transition to the repository, and translates failures. It
/// performs no refund and no slot release (separate future contracts), and
/// Payment never decides a cancellation.
final class BookingCancellationApplicationService {
  const BookingCancellationApplicationService({
    required AuthenticationSession session,
    required BookingCancellationRepository repository,
    ConsultationMemoryApplicationService? memory,
  }) : _session = session,
       _repository = repository,
       _memory = memory;

  final AuthenticationSession _session;
  final BookingCancellationRepository _repository;

  /// Optional memory producer; absent means no fact is recorded.
  final ConsultationMemoryApplicationService? _memory;

  Future<void> cancel(String bookingId) async {
    final clientId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || clientId == null || clientId.isEmpty) {
      throw const BookingCancellationUnauthenticatedFailure();
    }

    try {
      await _repository.cancel(bookingId: bookingId, clientId: clientId);
    } on BookingCancellationNotFoundException {
      throw const BookingCancellationNotFoundFailure();
    } on BookingCancellationStateException catch (error) {
      throw BookingCancellationInvalidStateFailure(
        currentStatus: error.currentStatus,
      );
    } on BookingCancellationRepositoryException catch (error) {
      throw BookingCancellationRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw BookingCancellationRepositoryFailure(cause: error);
    }

    await _recordFact(
      bookingId,
      MemoryEntryType.bookingCancelled,
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
