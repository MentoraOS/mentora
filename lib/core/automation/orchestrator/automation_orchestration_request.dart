import '../domain/automation_id.dart';

/// Immutable request describing an automation orchestration.
final class AutomationOrchestrationRequest {
  AutomationOrchestrationRequest({
    required this.automationId,
    Map<String, Object?> input = const <String, Object?>{},
    Map<String, Object?> metadata = const <String, Object?>{},
  }) : input = Map<String, Object?>.unmodifiable(input),
       metadata = Map<String, Object?>.unmodifiable(metadata);

  /// Target automation identifier.
  final AutomationId automationId;

  /// Business input forwarded to the automation runtime.
  final Map<String, Object?> input;

  /// Additional orchestration metadata.
  final Map<String, Object?> metadata;

  AutomationOrchestrationRequest copyWith({
    AutomationId? automationId,
    Map<String, Object?>? input,
    Map<String, Object?>? metadata,
  }) {
    return AutomationOrchestrationRequest(
      automationId: automationId ?? this.automationId,
      input: input ?? this.input,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AutomationOrchestrationRequest &&
            runtimeType == other.runtimeType &&
            automationId == other.automationId &&
            input.toString() == other.input.toString() &&
            metadata.toString() == other.metadata.toString();
  }

  @override
  int get hashCode =>
      Object.hash(automationId, input.toString(), metadata.toString());
}
