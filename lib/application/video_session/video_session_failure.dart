sealed class VideoSessionFailure implements Exception {
  const VideoSessionFailure();
}

final class VideoSessionUnauthenticatedFailure extends VideoSessionFailure {
  const VideoSessionUnauthenticatedFailure();
}

/// The session user is neither the client nor the expert of this booking.
final class VideoSessionForbiddenFailure extends VideoSessionFailure {
  const VideoSessionForbiddenFailure();
}

/// The reservation is not in a joinable state (only confirmed/paid are).
final class VideoSessionInvalidStateFailure extends VideoSessionFailure {
  const VideoSessionInvalidStateFailure({required this.currentStatus});

  final String currentStatus;
}

final class VideoSessionUnavailableFailure extends VideoSessionFailure {
  const VideoSessionUnavailableFailure({required this.cause});

  final Object cause;
}
