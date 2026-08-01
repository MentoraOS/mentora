import '../../domain/booking/consultation_completion_repository.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import 'consultation_completion_failure.dart';

/// Officially closes a consultation through the Booking-owned boundary.
///
/// The session user must be a participant of the reservation (verified
/// transactionally by the repository) and only confirmed/paid reservations
/// can complete. No payment, scheduling or video logic lives here.
final class ConsultationCompletionApplicationService {
  const ConsultationCompletionApplicationService({
    required AuthenticationSession session,
    required ConsultationCompletionRepository repository,
    ConsultationMemoryApplicationService? memory,
  }) : _session = session,
       _repository = repository,
       _memory = memory;

  final AuthenticationSession _session;
  final ConsultationCompletionRepository _repository;

  /// Optional memory producer; absent means no fact is recorded.
  final ConsultationMemoryApplicationService? _memory;

  Future<void> complete(String bookingId) async {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const ConsultationCompletionUnauthenticatedFailure();
    }

    try {
      await _repository.complete(bookingId: bookingId, userId: userId);
    } on ConsultationCompletionNotFoundException {
      throw const ConsultationCompletionNotFoundFailure();
    } on ConsultationCompletionStateException catch (error) {
      throw ConsultationCompletionInvalidStateFailure(
        currentStatus: error.currentStatus,
      );
    } on ConsultationCompletionRepositoryException catch (error) {
      throw ConsultationCompletionRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConsultationCompletionRepositoryFailure(cause: error);
    }

    await _recordFact(
      bookingId,
      MemoryEntryType.consultationCompleted,
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
