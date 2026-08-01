import '../../domain/booking/booking_overview.dart';
import '../authentication/authentication_session.dart';
import 'booking_dashboard_failure.dart';

/// Streams the session user's reservations for the Booking Dashboard.
///
/// Pure read projection: an expert session sees the reservations booked with
/// them, a client session sees their own. Every persisted lifecycle change
/// re-emits, so the dashboard refreshes immediately after a payment,
/// cancellation or reschedule without reopening the screen.
final class BookingDashboardApplicationService {
  const BookingDashboardApplicationService({
    required AuthenticationSession session,
    required BookingOverviewRepository repository,
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final BookingOverviewRepository _repository;

  Stream<List<BookingOverview>> watchMyBookings() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      return Stream.error(const BookingDashboardUnauthenticatedFailure());
    }

    final source = _session.isExpert
        ? _repository.watchForExpert(userId)
        : _repository.watchForClient(userId);

    return source.handleError((Object error, StackTrace stackTrace) {
      if (error is BookingDashboardFailure) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      if (error is BookingOverviewRepositoryException) {
        Error.throwWithStackTrace(
          BookingDashboardRepositoryFailure(cause: error.cause),
          stackTrace,
        );
      }
      Error.throwWithStackTrace(
        BookingDashboardRepositoryFailure(cause: error),
        stackTrace,
      );
    });
  }
}
