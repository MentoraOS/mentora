/// The permissions preparation state — PURE STATE, nothing else.
///
/// Immutable, const-constructible, exactly these three facts. No
/// computation, no method. Status is qualitative only.
final class PermissionsReadiness {
  final bool granted;
  final PermissionsStatus status;
  final DateTime checkedAt;

  const PermissionsReadiness({
    required this.granted,
    required this.status,
    required this.checkedAt,
  });
}

/// The only permissions statuses. Nothing else.
enum PermissionsStatus { unknown, denied, limited, granted }
