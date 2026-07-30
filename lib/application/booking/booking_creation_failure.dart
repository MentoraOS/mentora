sealed class BookingCreationFailure implements Exception {
  const BookingCreationFailure();
}

final class BookingCreationUnauthenticatedFailure
    extends BookingCreationFailure {
  const BookingCreationUnauthenticatedFailure();
}

final class BookingCreationInvalidRequestFailure
    extends BookingCreationFailure {
  const BookingCreationInvalidRequestFailure({required this.cause});

  final Object cause;
}

final class BookingCreationSlotConflictFailure extends BookingCreationFailure {
  const BookingCreationSlotConflictFailure();
}

final class BookingCreationMalformedDataFailure extends BookingCreationFailure {
  const BookingCreationMalformedDataFailure({required this.cause});

  final Object cause;
}

final class BookingCreationInfrastructureUnavailableFailure
    extends BookingCreationFailure {
  const BookingCreationInfrastructureUnavailableFailure({required this.cause});

  final Object cause;
}

final class BookingCreationPersistenceFailure extends BookingCreationFailure {
  const BookingCreationPersistenceFailure({required this.cause});

  final Object cause;
}
