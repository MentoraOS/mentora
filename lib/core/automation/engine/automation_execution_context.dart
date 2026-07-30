import '../domain/automation.dart';

/// Immutable context supplied to the automation engine for one execution.
final class AutomationExecutionContext {
  AutomationExecutionContext({
    required String executionId,
    required this.automation,
    required DateTime startedAt,
    this.attempt = 1,
    Map<String, Object?> input = const <String, Object?>{},
    Map<String, Object?> metadata = const <String, Object?>{},
  }) : executionId = _requireExecutionId(executionId),
       startedAt = startedAt.toUtc(),
       input = Map.unmodifiable(input),
       metadata = Map.unmodifiable(metadata) {
    if (attempt < 1) {
      throw ArgumentError.value(
        attempt,
        'attempt',
        'The execution attempt must be greater than or equal to 1.',
      );
    }
  }

  final String executionId;
  final Automation automation;
  final DateTime startedAt;
  final int attempt;
  final Map<String, Object?> input;
  final Map<String, Object?> metadata;

  AutomationExecutionContext copyWith({
    int? attempt,
    Map<String, Object?>? input,
    Map<String, Object?>? metadata,
  }) {
    return AutomationExecutionContext(
      executionId: executionId,
      automation: automation,
      startedAt: startedAt,
      attempt: attempt ?? this.attempt,
      input: input ?? this.input,
      metadata: metadata ?? this.metadata,
    );
  }

  static String _requireExecutionId(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'executionId',
        'The automation execution identifier must not be empty.',
      );
    }

    return normalizedValue;
  }
}
