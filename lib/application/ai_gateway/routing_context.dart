import '../../domain/ai_gateway/ai_provider.dart';

/// Everything a routing strategy may one day consider — INTERNAL to the
/// orchestrator (no business module ever knows it).
///
/// Immutable, and every field OPTIONAL: today only the task and the
/// request identity are filled. The prepared fields — source/target
/// language, region, country, priority, quality level, privacy level,
/// budget, maximum duration, subscription tier — carry NO logic in this
/// wave; future intelligent strategies read them without any model
/// change.
final class RoutingContext {
  final AITask? task;
  final String? requestId;
  final String? sourceLanguage;
  final String? targetLanguage;
  final String? region;
  final String? country;
  final String? priority;
  final String? qualityLevel;
  final String? privacyLevel;
  final num? budget;
  final Duration? maxDuration;
  final String? subscriptionTier;

  const RoutingContext({
    this.task,
    this.requestId,
    this.sourceLanguage,
    this.targetLanguage,
    this.region,
    this.country,
    this.priority,
    this.qualityLevel,
    this.privacyLevel,
    this.budget,
    this.maxDuration,
    this.subscriptionTier,
  });

  /// Today's whole context: the request's task and identity.
  factory RoutingContext.fromRequest(AIRequest request) {
    return RoutingContext(task: request.task, requestId: request.requestId);
  }
}
