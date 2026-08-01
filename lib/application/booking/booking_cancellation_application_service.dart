import '../../domain/booking/booking_cancellation_repository.dart';
import '../authentication/authentication_session.dart';
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
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final BookingCancellationRepository _repository;

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
  }
}
