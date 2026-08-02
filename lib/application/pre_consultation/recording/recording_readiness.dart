/// The recording platform preparation state — PURE STATE, nothing else.
///
/// Immutable, const-constructible, exactly these three facts. No
/// computation, no method. Status is qualitative only.
final class RecordingReadiness {
  final bool available;
  final RecordingReadinessStatus status;
  final DateTime checkedAt;

  const RecordingReadiness({
    required this.available,
    required this.status,
    required this.checkedAt,
  });
}

/// The only recording readiness statuses. Nothing else.
enum RecordingReadinessStatus {
  unknown,
  unavailable,
  available,
  unavailableByConsent,
}
