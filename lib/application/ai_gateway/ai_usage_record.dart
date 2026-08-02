import '../../domain/ai_gateway/ai_provider.dart';

/// One AI usage record — INTERNAL to the orchestrator.
///
/// Immutable, exactly these six facts, no aggregation. An unknown value
/// stays null — never invented.
final class AIUsageRecord {
  final String requestId;
  final AITask? task;
  final String? provider;
  final String? model;
  final bool success;
  final DateTime createdAt;

  const AIUsageRecord({
    required this.requestId,
    required this.task,
    required this.provider,
    required this.model,
    required this.success,
    required this.createdAt,
  });
}
