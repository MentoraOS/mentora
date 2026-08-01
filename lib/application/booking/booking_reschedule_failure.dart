sealed class BookingRescheduleFailure implements Exception {
  const BookingRescheduleFailure();
}

final class BookingRescheduleUnauthenticatedFailure
    extends BookingRescheduleFailure {
  const BookingRescheduleUnauthenticatedFailure();
}

/// No reservation with this identity exists for this client.
final class BookingRescheduleNotFoundFailure extends BookingRescheduleFailure {
  const BookingRescheduleNotFoundFailure();
}

/// The reservation is not in a reschedulable state; nothing is changed.
final class BookingRescheduleInvalidStateFailure
    extends BookingRescheduleFailure {
  const BookingRescheduleInvalidStateFailure({required this.currentStatus});

  final String currentStatus;
}

/// The new occurrence contradicts the reservation's snapshotted duration
/// (AD-022 decision 3); nothing is changed.
final class BookingRescheduleInconsistentFailure
    extends BookingRescheduleFailure {
  const BookingRescheduleInconsistentFailure();
}

final class BookingRescheduleRepositoryFailure
    extends BookingRescheduleFailure {
  const BookingRescheduleRepositoryFailure({required this.cause});

  final Object cause;
}
