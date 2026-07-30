import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_workflow.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/settle_consultation_context.dart';

import 'package:mentora/core/financial/runtime/context/'
    'financial_runtime_execution_context.dart';

import 'package:mentora/core/financial/runtime/engine/'
    'financial_runtime.dart';

import 'package:mentora/core/financial/runtime/result/'
    'financial_runtime_execution_result.dart';

import 'finalize_consultation_settlement_infrastructure_exception.dart';
import 'finalize_consultation_settlement_result.dart';

import 'pipeline/'
    'finalize_consultation_settlement_context.dart';

import 'pipeline/'
    'finalize_consultation_settlement_pipeline.dart';

import 'pipeline/settlement_failure_handler.dart';

/// Generates the unique Runtime execution identifier for one settlement.
typedef FinalizeSettlementExecutionIdFactory =
    String Function(SettleConsultationContext context);

/// Generates the business correlation identifier for one settlement.
///
/// All retries of the same settlement operation should return the same
/// correlation identifier.
typedef FinalizeSettlementCorrelationIdFactory =
    String Function(SettleConsultationContext context);

/// Resolves the current execution attempt.
///
/// The initial attempt should return 1.
typedef FinalizeSettlementAttemptFactory =
    int Function(SettleConsultationContext context);

/// Produces immutable Runtime metadata for one settlement execution.
typedef FinalizeSettlementMetadataFactory =
    Map<String, Object?> Function(SettleConsultationContext context);

final class FinalizeConsultationSettlementWorkflow
    implements
        FinancialWorkflow<
          SettleConsultationContext,
          FinalizeConsultationSettlementResult
        > {
  FinalizeConsultationSettlementWorkflow({
    required FinancialRuntime financialRuntime,
    required FinalizeConsultationSettlementPipeline pipeline,
    required SettlementFailureHandler failureHandler,
    required FinalizeSettlementExecutionIdFactory executionIdFactory,
    required FinalizeSettlementCorrelationIdFactory correlationIdFactory,
    FinalizeSettlementAttemptFactory? attemptFactory,
    FinalizeSettlementMetadataFactory? metadataFactory,
    DateTime Function()? clock,
  }) : _financialRuntime = financialRuntime,
       _pipeline = pipeline,
       _failureHandler = failureHandler,
       _executionIdFactory = executionIdFactory,
       _correlationIdFactory = correlationIdFactory,
       _attemptFactory = attemptFactory ?? _defaultAttemptFactory,
       _metadataFactory = metadataFactory ?? _defaultMetadataFactory,
       _clock = clock ?? DateTime.now;

  static const String workflowKey = 'finalize.consultation.settlement';

  final FinancialRuntime _financialRuntime;

  final FinalizeConsultationSettlementPipeline _pipeline;

  final SettlementFailureHandler _failureHandler;

  final FinalizeSettlementExecutionIdFactory _executionIdFactory;

  final FinalizeSettlementCorrelationIdFactory _correlationIdFactory;

  final FinalizeSettlementAttemptFactory _attemptFactory;

  final FinalizeSettlementMetadataFactory _metadataFactory;

  final DateTime Function() _clock;

  @override
  String get key => workflowKey;

  @override
  Future<FinalizeConsultationSettlementResult> execute(
    SettleConsultationContext context,
  ) async {
    final pipelineContext = FinalizeConsultationSettlementContext(
      settlementContext: context,
    );

    try {
      final executionId = _requireIdentifier(
        value: _executionIdFactory(context),
        fieldName: 'executionId',
      );

      final correlationId = _requireIdentifier(
        value: _correlationIdFactory(context),
        fieldName: 'correlationId',
      );

      final attempt = _attemptFactory(context);

      if (attempt < 1) {
        throw ArgumentError.value(
          attempt,
          'attempt',
          'The settlement execution attempt must be '
              'greater than or equal to 1.',
        );
      }

      final executionContext =
          FinancialRuntimeExecutionContext<
            FinalizeConsultationSettlementContext
          >(
            executionId: executionId,
            correlationId: correlationId,
            pipelineContext: pipelineContext,
            startedAt: _utcNow(),
            attempt: attempt,
            metadata: <String, Object?>{
              'workflowKey': workflowKey,
              ..._metadataFactory(context),
            },
          );

      final runtimeResult = await _financialRuntime.execute(
        pipeline: _pipeline,
        executionContext: executionContext,
      );

      switch (runtimeResult) {
        case FinancialRuntimeExecutionSuccess():
          return _requireFinalResult(pipelineContext);

        case FinancialRuntimeExecutionFailure failure:
          Error.throwWithStackTrace(failure.error, failure.stackTrace);

        case FinancialRuntimeInfrastructureFailure failure:
          final exception =
              FinalizeConsultationSettlementInfrastructureException(
                runtimeFailure: failure,
              );

          Error.throwWithStackTrace(exception, failure.stackTrace);
      }
    } catch (error, stackTrace) {
      await _handleFailureWithoutMaskingOriginalError(
        pipelineContext: pipelineContext,
        originalError: error,
        originalStackTrace: stackTrace,
      );
    }
  }

  Future<Never> _handleFailureWithoutMaskingOriginalError({
    required FinalizeConsultationSettlementContext pipelineContext,
    required Object originalError,
    required StackTrace originalStackTrace,
  }) async {
    try {
      await _failureHandler.handle(
        context: pipelineContext,
        error: originalError,
      );
    } catch (failurePersistenceError, failureStackTrace) {
      final combinedException = StateError(
        'Settlement finalization failed with '
        '"$originalError". Persisting the failed settlement '
        'also failed with "$failurePersistenceError". '
        'Failure persistence stack trace: '
        '$failureStackTrace',
      );

      Error.throwWithStackTrace(combinedException, originalStackTrace);
    }

    Error.throwWithStackTrace(originalError, originalStackTrace);
  }

  FinalizeConsultationSettlementResult _requireFinalResult(
    FinalizeConsultationSettlementContext context,
  ) {
    final result = context.result;

    if (result == null) {
      throw StateError(
        'Finalize consultation settlement pipeline '
        'completed successfully without producing '
        'a final result.',
      );
    }

    return result;
  }

  DateTime _utcNow() => _clock().toUtc();

  static int _defaultAttemptFactory(SettleConsultationContext context) {
    return 1;
  }

  static Map<String, Object?> _defaultMetadataFactory(
    SettleConsultationContext context,
  ) {
    return const <String, Object?>{};
  }

  static String _requireIdentifier({
    required String value,
    required String fieldName,
  }) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        'The identifier must not be empty.',
      );
    }

    return normalizedValue;
  }
}
