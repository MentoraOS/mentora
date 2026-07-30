import 'financial_recovery_decision.dart';

// Result returned by a specialized financial recovery strategy.

sealed class FinancialRecoveryStrategyResult {
  FinancialRecoveryStrategyResult({
    required String recoveryId,
    required String strategyKey,
    required this.decision,
    required this.attempt,
    required this.duration,
    required DateTime completedAt,
    Map<String, dynamic> metadata = const {},
  }) : recoveryId = _normalizeRequired(recoveryId, 'recoveryId'),
       strategyKey = _normalizeRequired(strategyKey, 'strategyKey'),
       completedAt = completedAt.toUtc(),
       metadata = Map.unmodifiable(Map<String, dynamic>.from(metadata)) {
    if (attempt < 1) {
      throw ArgumentError.value(
        attempt,
        'attempt',
        'Recovery attempt must be greater than zero.',
      );
    }

    if (duration.isNegative) {
      throw ArgumentError.value(
        duration,
        'duration',
        'Recovery duration must not be negative.',
      );
    }
  }

  final String recoveryId;

  // Stable identifier of the strategy that handled recovery.
  final String strategyKey;

  final FinancialRecoveryDecision decision;

  final int attempt;

  final Duration duration;

  final DateTime completedAt;

  final Map<String, dynamic> metadata;

  bool get isSuccess => this is FinancialRecoveryStrategySuccess;

  bool get isFailure => this is FinancialRecoveryStrategyFailure;

  bool get requiresManualReview =>
      decision == FinancialRecoveryDecision.manualReview;

  bool get isTerminal => decision == FinancialRecoveryDecision.terminalFailure;

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

// Recovery completed without an unhandled strategy error.
//
// This includes successful retry, compensation or an intentional no-op.
final class FinancialRecoveryStrategySuccess
    extends FinancialRecoveryStrategyResult {
  FinancialRecoveryStrategySuccess({
    required super.recoveryId,
    required super.strategyKey,
    required super.decision,
    required super.attempt,
    required super.duration,
    required super.completedAt,
    super.metadata,
  }) : assert(
         decision == FinancialRecoveryDecision.retry ||
             decision == FinancialRecoveryDecision.compensate ||
             decision == FinancialRecoveryDecision.ignore,
         'A successful recovery result must use retry, compensate or ignore.',
       );
}

// Recovery could not be completed automatically.
final class FinancialRecoveryStrategyFailure
    extends FinancialRecoveryStrategyResult {
  FinancialRecoveryStrategyFailure({
    required super.recoveryId,
    required super.strategyKey,
    required super.decision,
    required super.attempt,
    required super.duration,
    required super.completedAt,
    required this.error,
    required this.stackTrace,
    super.metadata,
  }) : assert(
         decision == FinancialRecoveryDecision.manualReview ||
             decision == FinancialRecoveryDecision.terminalFailure,
         'A failed recovery result must require manual review '
         'or represent a terminal failure.',
       );

  final Object error;

  final StackTrace stackTrace;
}
