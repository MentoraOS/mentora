import '../../domain/booking/booking_confirmation_repository.dart';
import '../authentication/authentication_session.dart';
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
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final BookingConfirmationRepository _repository;

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
  }
}
