sealed class BookingDashboardFailure implements Exception {
  const BookingDashboardFailure();
}

final class BookingDashboardUnauthenticatedFailure
    extends BookingDashboardFailure {
  const BookingDashboardUnauthenticatedFailure();
}

final class BookingDashboardRepositoryFailure extends BookingDashboardFailure {
  const BookingDashboardRepositoryFailure({required this.cause});

  final Object cause;
}
