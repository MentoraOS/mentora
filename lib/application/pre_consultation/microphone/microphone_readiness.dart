/// The microphone preparation state — PURE STATE, nothing else.
///
/// Immutable, const-constructible, exactly these three facts. No
/// computation, no method. Status is qualitative only.
final class MicrophoneReadiness {
  final bool available;
  final MicrophoneStatus status;
  final DateTime checkedAt;

  const MicrophoneReadiness({
    required this.available,
    required this.status,
    required this.checkedAt,
  });
}

/// The only microphone statuses. Nothing else.
enum MicrophoneStatus { unknown, unavailable, available, busy }
