import '../../domain/ai_gateway/ai_provider.dart';

/// One AI execution trace — INTERNAL to the orchestrator.
///
/// Immutable, and carrying TECHNICAL facts only — no AI content of any
/// kind and no personal data ever enter a trace. Completion never
/// mutates: it produces a NEW trace. Exactly these seven facts.
final class AIExecutionTrace {
  final String requestId;

  /// The engine kind that served the request (its type name).
  final String provider;

  final AITask? task;

  /// The routing strategy that selected the engine.
  final String strategy;

  final DateTime startedAt;
  final DateTime? finishedAt;
  final AIExecutionStatus status;

  const AIExecutionTrace({
    required this.requestId,
    required this.provider,
    required this.task,
    required this.strategy,
    required this.startedAt,
    required this.finishedAt,
    required this.status,
  });

  /// The completed version of this trace — a new immutable instance.
  AIExecutionTrace finished({
    required AIExecutionStatus status,
    required DateTime finishedAt,
  }) {
    return AIExecutionTrace(
      requestId: requestId,
      provider: provider,
      task: task,
      strategy: strategy,
      startedAt: startedAt,
      finishedAt: finishedAt,
      status: status,
    );
  }
}

/// The only execution states. Nothing else.
enum AIExecutionStatus { started, succeeded, failed }
