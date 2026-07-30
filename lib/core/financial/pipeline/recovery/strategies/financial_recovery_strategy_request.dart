import '../../financial_pipeline_context.dart';

// Input inspected by a financial recovery strategy.
//
// It preserves the initial failure and the current recovery attempt so the
// strategy can make a deterministic decision without depending on global
// mutable state.

final class FinancialRecoveryStrategyRequest<
  TContext extends FinancialPipelineContext
> {
  FinancialRecoveryStrategyRequest({
    required String recoveryId,
    required String pipelineId,
    required this.context,
    required this.error,
    required this.stackTrace,
    required this.attempt,
    required DateTime requestedAt,
    Map<String, dynamic> metadata = const {},
  }) : recoveryId = _normalizeRequired(recoveryId, 'recoveryId'),
       pipelineId = _normalizeRequired(pipelineId, 'pipelineId'),
       requestedAt = requestedAt.toUtc(),
       metadata = Map.unmodifiable(Map<String, dynamic>.from(metadata)) {
    if (attempt < 1) {
      throw ArgumentError.value(
        attempt,
        'attempt',
        'Recovery attempt must be greater than zero.',
      );
    }
  }

  // Unique identifier of this recovery execution.
  final String recoveryId;

  // Identifier of the interrupted financial pipeline.
  final String pipelineId;

  // Original pipeline context.
  final TContext context;

  // Initial or most recent failure.
  final Object error;

  // Stack trace associated with [error].
  final StackTrace stackTrace;

  // Current recovery attempt, starting at one.
  final int attempt;

  // UTC instant at which recovery was requested.
  final DateTime requestedAt;

  // Additional immutable diagnostic data.
  final Map<String, dynamic> metadata;

  static String _normalizeRequired(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must not be empty.',
      );
    }

    return normalized;
  }
}
