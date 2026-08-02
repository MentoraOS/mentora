/// One execution's metrics — INTERNAL to the orchestrator. STRUCTURE
/// ONLY today.
///
/// Immutable, exactly these three facts. No aggregated statistics and no
/// computation live anywhere yet: the future internal dashboard, global
/// metrics, alerts, realtime monitoring, engine comparison, spend
/// tracking, technical audit and automatic optimization will CONSUME
/// this structure through their own waves, without changing it.
final class AIExecutionMetrics {
  final Duration duration;
  final bool success;
  final bool failed;

  const AIExecutionMetrics({
    required this.duration,
    required this.success,
    required this.failed,
  });
}
