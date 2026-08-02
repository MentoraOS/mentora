/// The only AI readiness failures. Typed, no logic.
sealed class AIReadinessFailure implements Exception {
  const AIReadinessFailure();
}

/// The AI readiness information source cannot answer.
final class AIUnavailableFailure extends AIReadinessFailure {
  const AIUnavailableFailure();
}

/// The AI readiness information source answered too late.
final class AITimeoutFailure extends AIReadinessFailure {
  const AITimeoutFailure();
}
