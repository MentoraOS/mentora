/// Result produced by one automation execution.
sealed class AutomationExecutionResult {
  const AutomationExecutionResult({
    required this.executionId,
    required this.startedAt,
    required this.completedAt,
  });

  final String executionId;
  final DateTime startedAt;
  final DateTime completedAt;

  Duration get duration => completedAt.difference(startedAt);
}

/// Successful automation execution.
final class AutomationExecutionSuccess extends AutomationExecutionResult {
  AutomationExecutionSuccess({
    required super.executionId,
    required DateTime startedAt,
    required DateTime completedAt,
    Map<String, Object?> output = const <String, Object?>{},
  }) : output = Map.unmodifiable(output),
       super(startedAt: startedAt.toUtc(), completedAt: completedAt.toUtc()) {
    _validateDates(this.startedAt, this.completedAt);
  }

  final Map<String, Object?> output;
}

/// Failed automation execution.
final class AutomationExecutionFailure extends AutomationExecutionResult {
  AutomationExecutionFailure({
    required super.executionId,
    required DateTime startedAt,
    required DateTime completedAt,
    required this.error,
    required this.stackTrace,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) : metadata = Map.unmodifiable(metadata),
       super(startedAt: startedAt.toUtc(), completedAt: completedAt.toUtc()) {
    _validateDates(this.startedAt, this.completedAt);
  }

  final Object error;
  final StackTrace stackTrace;
  final Map<String, Object?> metadata;
}

/// Skipped automation execution.
final class AutomationExecutionSkipped extends AutomationExecutionResult {
  AutomationExecutionSkipped({
    required super.executionId,
    required DateTime startedAt,
    required DateTime completedAt,
    required String reason,
  }) : reason = _requireReason(reason),
       super(startedAt: startedAt.toUtc(), completedAt: completedAt.toUtc()) {
    _validateDates(this.startedAt, this.completedAt);
  }

  final String reason;

  static String _requireReason(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'reason',
        'The skip reason must not be empty.',
      );
    }

    return normalizedValue;
  }
}

void _validateDates(DateTime startedAt, DateTime completedAt) {
  if (completedAt.isBefore(startedAt)) {
    throw ArgumentError.value(
      completedAt,
      'completedAt',
      'The completion date must not be earlier than the start date.',
    );
  }
}
