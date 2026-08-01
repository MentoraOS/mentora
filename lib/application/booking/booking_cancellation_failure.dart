sealed class BookingCancellationFailure implements Exception {
  const BookingCancellationFailure();
}

final class BookingCancellationUnauthenticatedFailure
    extends BookingCancellationFailure {
  const BookingCancellationUnauthenticatedFailure();
}

/// No reservation with this identity exists for this client.
final class BookingCancellationNotFoundFailure
    extends BookingCancellationFailure {
  const BookingCancellationNotFoundFailure();
}

/// The reservation is not in a cancellable state; nothing is changed.
final class BookingCancellationInvalidStateFailure
    extends BookingCancellationFailure {
  const BookingCancellationInvalidStateFailure({required this.currentStatus});

  final String currentStatus;
}

final class BookingCancellationRepositoryFailure
    extends BookingCancellationFailure {
  const BookingCancellationRepositoryFailure({required this.cause});

  final Object cause;
}
