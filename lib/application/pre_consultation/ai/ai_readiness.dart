/// The AI platform preparation state — PURE STATE, nothing else.
///
/// Immutable, const-constructible, exactly these three facts. No
/// computation, no method. Status is qualitative only.
final class AIReadiness {
  final bool available;
  final AIReadinessStatus status;
  final DateTime checkedAt;

  const AIReadiness({
    required this.available,
    required this.status,
    required this.checkedAt,
  });
}

/// The only AI readiness statuses. Nothing else.
enum AIReadinessStatus { unknown, unavailable, available, degraded }
