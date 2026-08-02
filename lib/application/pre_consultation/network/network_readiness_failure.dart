/// The only network readiness failures. Typed, no logic.
sealed class NetworkReadinessFailure implements Exception {
  const NetworkReadinessFailure();
}

/// The network information source cannot answer.
final class NetworkUnavailableFailure extends NetworkReadinessFailure {
  const NetworkUnavailableFailure();
}

/// The network information source answered too late.
final class NetworkTimeoutFailure extends NetworkReadinessFailure {
  const NetworkTimeoutFailure();
}
