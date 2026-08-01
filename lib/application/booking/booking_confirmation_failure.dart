sealed class BookingConfirmationFailure implements Exception {
  const BookingConfirmationFailure();
}

final class BookingConfirmationUnauthenticatedFailure
    extends BookingConfirmationFailure {
  const BookingConfirmationUnauthenticatedFailure();
}

/// No reservation with this identity awaits confirmation for this client.
final class BookingConfirmationNotFoundFailure
    extends BookingConfirmationFailure {
  const BookingConfirmationNotFoundFailure();
}

/// The reservation is not in the payment-awaiting state; nothing is changed.
final class BookingConfirmationInvalidStateFailure
    extends BookingConfirmationFailure {
  const BookingConfirmationInvalidStateFailure({required this.currentStatus});

  final String currentStatus;
}

final class BookingConfirmationRepositoryFailure
    extends BookingConfirmationFailure {
  const BookingConfirmationRepositoryFailure({required this.cause});

  final Object cause;
}
