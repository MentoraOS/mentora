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

/// The selected Consultation Offer is not client-selectable (AD-021 decisions
/// 6 and 16). No neighbouring tier or default is substituted.
final class BookingCreationOfferUnavailableFailure
    extends BookingCreationFailure {
  const BookingCreationOfferUnavailableFailure();
}

/// The selected Consultation Offer belongs to a different expert than the one
/// being booked (AD-021 decision 8).
final class BookingCreationExpertMismatchFailure
    extends BookingCreationFailure {
  const BookingCreationExpertMismatchFailure();
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
