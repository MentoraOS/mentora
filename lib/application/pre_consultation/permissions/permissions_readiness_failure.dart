/// The only permissions readiness failures. Typed, no logic.
sealed class PermissionsReadinessFailure implements Exception {
  const PermissionsReadinessFailure();
}

/// The permissions information source cannot answer.
final class PermissionsUnavailableFailure extends PermissionsReadinessFailure {
  const PermissionsUnavailableFailure();
}

/// The permissions information source answered too late.
final class PermissionsTimeoutFailure extends PermissionsReadinessFailure {
  const PermissionsTimeoutFailure();
}
