sealed class ReviewFailure implements Exception {
  const ReviewFailure();
}

final class ReviewUnauthenticatedFailure extends ReviewFailure {
  const ReviewUnauthenticatedFailure();
}

/// The rating must be 1..5 stars.
final class ReviewInvalidRatingFailure extends ReviewFailure {
  const ReviewInvalidRatingFailure();
}

/// No reservation with this identity belongs to this client.
final class ReviewBookingNotFoundFailure extends ReviewFailure {
  const ReviewBookingNotFoundFailure();
}

/// Only a completed consultation can be reviewed.
final class ReviewInvalidStateFailure extends ReviewFailure {
  const ReviewInvalidStateFailure({required this.currentStatus});

  final String currentStatus;
}

/// A reservation carries at most one review, ever.
final class ReviewAlreadyExistsFailure extends ReviewFailure {
  const ReviewAlreadyExistsFailure();
}

final class ReviewRepositoryFailure extends ReviewFailure {
  const ReviewRepositoryFailure({required this.cause});

  final Object cause;
}
