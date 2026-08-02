/// The only recording readiness failures. Typed, no logic.
sealed class RecordingReadinessFailure implements Exception {
  const RecordingReadinessFailure();
}

/// The recording readiness information source cannot answer.
final class RecordingUnavailableFailure extends RecordingReadinessFailure {
  const RecordingUnavailableFailure();
}

/// The recording readiness information source answered too late.
final class RecordingTimeoutFailure extends RecordingReadinessFailure {
  const RecordingTimeoutFailure();
}
