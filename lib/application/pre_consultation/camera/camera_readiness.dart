/// The camera preparation state — PURE STATE, nothing else.
///
/// Immutable, const-constructible, exactly these three facts. No
/// computation, no method. Status is qualitative only.
final class CameraReadiness {
  final bool available;
  final CameraStatus status;
  final DateTime checkedAt;

  const CameraReadiness({
    required this.available,
    required this.status,
    required this.checkedAt,
  });
}

/// The only camera statuses. Nothing else.
enum CameraStatus { unknown, unavailable, available, busy }
