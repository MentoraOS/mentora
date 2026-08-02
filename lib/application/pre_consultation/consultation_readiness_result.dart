/// One checker's verdict — PURE STATE, nothing else.
///
/// Immutable, const-constructible, exactly these three facts. No logic,
/// no computation, no method.
final class ConsultationReadinessResult {
  final String checkerId;
  final bool ready;
  final DateTime checkedAt;

  const ConsultationReadinessResult({
    required this.checkerId,
    required this.ready,
    required this.checkedAt,
  });
}
