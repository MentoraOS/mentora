import 'automation_id.dart';

/// Runtime lifecycle status of one automation execution.
enum AutomationExecutionStatus {
  pending,
  running,
  succeeded,
  failed,
  cancelled,
}

/// Immutable record describing one automation execution.
final class AutomationExecution {
  AutomationExecution({
    required String executionId,
    required this.automationId,
    required this.automationVersion,
    required this.status,
    required DateTime startedAt,
    DateTime? completedAt,
    Map<String, Object?> input = const <String, Object?>{},
    Map<String, Object?> output = const <String, Object?>{},
    String? errorMessage,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) : executionId = _requireExecutionId(executionId),
       startedAt = startedAt.toUtc(),
       completedAt = completedAt?.toUtc(),
       input = Map.unmodifiable(input),
       output = Map.unmodifiable(output),
       errorMessage = _normalizeOptional(errorMessage),
       metadata = Map.unmodifiable(metadata) {
    if (automationVersion < 1) {
      throw ArgumentError.value(
        automationVersion,
        'automationVersion',
        'The automation version must be greater than or equal to 1.',
      );
    }

    if (this.completedAt != null &&
        this.completedAt!.isBefore(this.startedAt)) {
      throw ArgumentError.value(
        completedAt,
        'completedAt',
        'The completion date must not be earlier than the start date.',
      );
    }

    final isTerminal =
        status == AutomationExecutionStatus.succeeded ||
        status == AutomationExecutionStatus.failed ||
        status == AutomationExecutionStatus.cancelled;

    if (isTerminal && this.completedAt == null) {
      throw ArgumentError(
        'A terminal automation execution must have a completion date.',
      );
    }

    if (!isTerminal && this.completedAt != null) {
      throw ArgumentError(
        'A non-terminal automation execution must not have a completion date.',
      );
    }

    if (status == AutomationExecutionStatus.failed &&
        this.errorMessage == null) {
      throw ArgumentError(
        'A failed automation execution must provide an error message.',
      );
    }
  }

  final String executionId;
  final AutomationId automationId;
  final int automationVersion;
  final AutomationExecutionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, Object?> input;
  final Map<String, Object?> output;
  final String? errorMessage;
  final Map<String, Object?> metadata;

  bool get isTerminal =>
      status == AutomationExecutionStatus.succeeded ||
      status == AutomationExecutionStatus.failed ||
      status == AutomationExecutionStatus.cancelled;

  bool get isSuccessful => status == AutomationExecutionStatus.succeeded;

  bool get hasFailed => status == AutomationExecutionStatus.failed;

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

  static String? _normalizeOptional(String? value) {
    if (value == null) {
      return null;
    }

    final normalizedValue = value.trim();
    return normalizedValue.isEmpty ? null : normalizedValue;
  }
}
