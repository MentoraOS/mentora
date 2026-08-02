/// The network's preparation state — PURE STATE, nothing else.
///
/// Immutable, const-constructible, exactly these three facts. No
/// computation, no method. Quality is qualitative only.
final class NetworkReadiness {
  final bool available;
  final NetworkQuality quality;
  final DateTime checkedAt;

  const NetworkReadiness({
    required this.available,
    required this.quality,
    required this.checkedAt,
  });
}

/// The only network quality levels. Nothing else.
enum NetworkQuality { unknown, poor, acceptable, excellent }
