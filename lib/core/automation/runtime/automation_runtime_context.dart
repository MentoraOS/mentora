import '../domain/automation.dart';
import '../domain/automation_id.dart';

/// Immutable context used by the Automation Runtime.
///
/// It encapsulates all information required to execute a registered
/// automation.
final class AutomationRuntimeContext {
  AutomationRuntimeContext({
    required this.automationId,
    required this.automation,
    Map<String, Object?> input = const <String, Object?>{},
    Map<String, Object?> metadata = const <String, Object?>{},
    DateTime? requestedAt,
  }) : input = Map.unmodifiable(input),
       metadata = Map.unmodifiable(metadata),
       requestedAt = (requestedAt ?? DateTime.now()).toUtc();

  /// Identifier of the automation to execute.
  final AutomationId automationId;

  /// Resolved automation definition.
  final Automation automation;

  /// Input payload supplied by the caller.
  final Map<String, Object?> input;

  /// Runtime metadata.
  final Map<String, Object?> metadata;

  /// UTC timestamp at which execution was requested.
  final DateTime requestedAt;

  AutomationRuntimeContext copyWith({
    AutomationId? automationId,
    Automation? automation,
    Map<String, Object?>? input,
    Map<String, Object?>? metadata,
    DateTime? requestedAt,
  }) {
    return AutomationRuntimeContext(
      automationId: automationId ?? this.automationId,
      automation: automation ?? this.automation,
      input: input ?? this.input,
      metadata: metadata ?? this.metadata,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AutomationRuntimeContext &&
            automationId == other.automationId &&
            automation == other.automation &&
            requestedAt == other.requestedAt;
  }

  @override
  int get hashCode => Object.hash(automationId, automation, requestedAt);
}
