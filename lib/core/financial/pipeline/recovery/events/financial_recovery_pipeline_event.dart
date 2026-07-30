import '../../financial_pipeline_context.dart';

import '../strategies/'
    'financial_recovery_strategy_request.dart';
import '../strategies/'
    'financial_recovery_strategy_result.dart';

/// Base lifecycle event emitted by the Financial Recovery Pipeline.
///
/// Events contain operational information only. They never execute recovery
/// logic and never mutate the recovery request or its context.
sealed class FinancialRecoveryPipelineEvent {
  const FinancialRecoveryPipelineEvent({
    required this.recoveryId,
    required this.pipelineId,
    required this.attempt,
    required this.occurredAt,
    this.metadata = const {},
  });

  final String recoveryId;
  final String pipelineId;
  final int attempt;
  final DateTime occurredAt;
  final Map<String, dynamic> metadata;
}

/// Emitted immediately before the Recovery Engine is invoked.
final class FinancialRecoveryPipelineStarted<
  TContext extends FinancialPipelineContext
>
    extends FinancialRecoveryPipelineEvent {
  const FinancialRecoveryPipelineStarted({
    required this.request,
    required super.recoveryId,
    required super.pipelineId,
    required super.attempt,
    required super.occurredAt,
    super.metadata,
  });

  final FinancialRecoveryStrategyRequest<TContext> request;
}

/// Emitted when the Recovery Engine produces a successful strategy result.
final class FinancialRecoveryPipelineSucceeded<
  TContext extends FinancialPipelineContext
>
    extends FinancialRecoveryPipelineEvent {
  const FinancialRecoveryPipelineSucceeded({
    required this.request,
    required this.result,
    required this.duration,
    required super.recoveryId,
    required super.pipelineId,
    required super.attempt,
    required super.occurredAt,
    super.metadata,
  });

  final FinancialRecoveryStrategyRequest<TContext> request;

  final FinancialRecoveryStrategySuccess result;

  final Duration duration;
}

/// Emitted when the Recovery Engine produces a controlled failure result.
///
/// This represents a valid recovery outcome such as:
/// - retry;
/// - manual review;
/// - terminal failure.
///
/// It is not a technical crash.
final class FinancialRecoveryPipelineFailed<
  TContext extends FinancialPipelineContext
>
    extends FinancialRecoveryPipelineEvent {
  const FinancialRecoveryPipelineFailed({
    required this.request,
    required this.result,
    required this.duration,
    required super.recoveryId,
    required super.pipelineId,
    required super.attempt,
    required super.occurredAt,
    super.metadata,
  });

  final FinancialRecoveryStrategyRequest<TContext> request;

  final FinancialRecoveryStrategyFailure result;

  final Duration duration;
}

/// Emitted when the Recovery Pipeline terminates because of an unexpected
/// technical exception.
///
/// The original error and stack trace are preserved for diagnostics.
final class FinancialRecoveryPipelineCrashed<
  TContext extends FinancialPipelineContext
>
    extends FinancialRecoveryPipelineEvent {
  const FinancialRecoveryPipelineCrashed({
    required this.request,
    required this.error,
    required this.stackTrace,
    required this.duration,
    required super.recoveryId,
    required super.pipelineId,
    required super.attempt,
    required super.occurredAt,
    super.metadata,
  });

  final FinancialRecoveryStrategyRequest<TContext> request;

  final Object error;

  final StackTrace stackTrace;

  final Duration duration;
}

/// Emitted at the end of every Recovery Pipeline execution.
///
/// It is emitted after:
/// - success;
/// - controlled failure;
/// - technical crash.
final class FinancialRecoveryPipelineFinished<
  TContext extends FinancialPipelineContext
>
    extends FinancialRecoveryPipelineEvent {
  const FinancialRecoveryPipelineFinished({
    required this.request,
    required this.duration,
    required super.recoveryId,
    required super.pipelineId,
    required super.attempt,
    required super.occurredAt,
    super.metadata,
  });

  final FinancialRecoveryStrategyRequest<TContext> request;

  final Duration duration;
}
