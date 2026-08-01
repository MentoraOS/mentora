import '../../domain/booking/consultation_completion_repository.dart';
import '../authentication/authentication_session.dart';
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
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final ConsultationCompletionRepository _repository;

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
  }
}
