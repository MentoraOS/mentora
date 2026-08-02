/// The only camera readiness failures. Typed, no logic.
sealed class CameraReadinessFailure implements Exception {
  const CameraReadinessFailure();
}

/// The camera information source cannot answer.
final class CameraUnavailableFailure extends CameraReadinessFailure {
  const CameraUnavailableFailure();
}

/// The camera information source answered too late.
final class CameraTimeoutFailure extends CameraReadinessFailure {
  const CameraTimeoutFailure();
}
