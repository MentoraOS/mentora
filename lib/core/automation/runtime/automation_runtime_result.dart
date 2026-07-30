import '../domain/automation_execution.dart';
import '../domain/automation_id.dart';

/// Base type returned by the Automation Runtime.
///
/// The sealed hierarchy forces callers to handle every possible runtime
/// outcome explicitly.
sealed class AutomationRuntimeResult {
  const AutomationRuntimeResult({
    required this.automationId,
    required this.requestedAt,
    required this.completedAt,
  });

  final AutomationId automationId;
  final DateTime requestedAt;
  final DateTime completedAt;

  Duration get duration => completedAt.difference(requestedAt);

  bool get isSuccess => this is AutomationRuntimeSuccess;

  bool get isFailure => this is AutomationRuntimeFailure;

  bool get isNotFound => this is AutomationRuntimeNotFound;
}

/// Runtime execution completed successfully.
final class AutomationRuntimeSuccess extends AutomationRuntimeResult {
  AutomationRuntimeSuccess({
    required super.automationId,
    required super.requestedAt,
    required super.completedAt,
    required this.execution,
  }) {
    _validateTimestamps(requestedAt: requestedAt, completedAt: completedAt);
  }

  final AutomationExecution execution;
}

/// Runtime execution failed after the automation was resolved.
final class AutomationRuntimeFailure extends AutomationRuntimeResult {
  AutomationRuntimeFailure({
    required super.automationId,
    required super.requestedAt,
    required super.completedAt,
    required String message,
    this.cause,
    this.stackTrace,
  }) : message = _requireMessage(message) {
    _validateTimestamps(requestedAt: requestedAt, completedAt: completedAt);
  }

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
}

/// No registered automation matched the requested identifier.
final class AutomationRuntimeNotFound extends AutomationRuntimeResult {
  AutomationRuntimeNotFound({
    required super.automationId,
    required super.requestedAt,
    required super.completedAt,
  }) {
    _validateTimestamps(requestedAt: requestedAt, completedAt: completedAt);
  }
}

String _requireMessage(String value) {
  final String normalized = value.trim();

  if (normalized.isEmpty) {
    throw ArgumentError.value(
      value,
      'message',
      'The runtime failure message must not be empty.',
    );
  }

  return normalized;
}

void _validateTimestamps({
  required DateTime requestedAt,
  required DateTime completedAt,
}) {
  if (completedAt.isBefore(requestedAt)) {
    throw ArgumentError.value(
      completedAt,
      'completedAt',
      'The completion timestamp must not be before requestedAt.',
    );
  }
}
