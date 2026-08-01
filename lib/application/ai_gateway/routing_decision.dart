import '../../domain/ai_gateway/ai_provider.dart';

/// One routing decision — INTERNAL to the orchestrator.
///
/// Immutable and built for millions of daily decisions: each one is
/// explainable (reason), traceable (strategy + timestamp), replaceable
/// and testable. Exactly these four facts, nothing more.
final class RoutingDecision {
  /// The selected provider; null means the strategy has no opinion and
  /// the orchestrator uses its default provider.
  final AIProvider? provider;

  /// The strategy that made this decision.
  final String strategy;

  /// Why this provider was chosen — always human-readable.
  final String reason;

  final DateTime timestamp;

  const RoutingDecision({
    required this.provider,
    required this.strategy,
    required this.reason,
    required this.timestamp,
  });
}
