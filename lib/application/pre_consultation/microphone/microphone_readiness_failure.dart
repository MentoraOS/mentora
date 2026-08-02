/// The only microphone readiness failures. Typed, no logic.
sealed class MicrophoneReadinessFailure implements Exception {
  const MicrophoneReadinessFailure();
}

/// The microphone information source cannot answer.
final class MicrophoneUnavailableFailure extends MicrophoneReadinessFailure {
  const MicrophoneUnavailableFailure();
}

/// The microphone information source answered too late.
final class MicrophoneTimeoutFailure extends MicrophoneReadinessFailure {
  const MicrophoneTimeoutFailure();
}
