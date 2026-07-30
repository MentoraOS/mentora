import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'default_financial_pipeline_engine.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_exception.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_result.dart';
import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_step.dart';

import 'package:mentora/core/financial/runtime/bootstrap/'
    'financial_runtime_module.dart';
import 'package:mentora/core/financial/runtime/context/'
    'financial_runtime_execution_context.dart';
import 'package:mentora/core/financial/runtime/result/'
    'financial_runtime_execution_result.dart';

void main() {
  group('Financial Runtime Integration', () {
    test(
      'should execute a complete pipeline through the Runtime module',
      () async {
        final executionLog = <String>[];

        final pipeline = _IntegrationFinancialPipeline(
          id: 'consultation-settlement',
          steps: [
            _RecordingFinancialPipelineStep(
              id: 'validate-settlement',
              onExecute: (context) async {
                executionLog.add('validate-settlement');
                context.validated = true;
              },
            ),
            _RecordingFinancialPipelineStep(
              id: 'calculate-settlement',
              onExecute: (context) async {
                executionLog.add('calculate-settlement');

                if (!context.validated) {
                  throw StateError('Settlement must be validated first.');
                }

                context.calculated = true;
              },
            ),
            _RecordingFinancialPipelineStep(
              id: 'post-ledger-journal',
              onExecute: (context) async {
                executionLog.add('post-ledger-journal');

                if (!context.calculated) {
                  throw StateError('Settlement must be calculated first.');
                }

                context.journalPosted = true;
              },
            ),
          ],
        );

        final pipelineEngine = DefaultFinancialPipelineEngine(
          clock: () => DateTime.utc(2026, 7, 17, 20),
        );

        final runtimeModule = FinancialRuntimeModule.initialize(
          pipelineEngine: pipelineEngine,
          clock: () => DateTime.utc(2026, 7, 17, 20, 0, 2),
        );

        final pipelineContext = _IntegrationFinancialPipelineContext();

        final executionContext =
            FinancialRuntimeExecutionContext<
              _IntegrationFinancialPipelineContext
            >(
              executionId: 'execution-001',
              correlationId: 'consultation-001',
              pipelineContext: pipelineContext,
              startedAt: DateTime.utc(2026, 7, 17, 20),
              metadata: const {
                'workflow': 'finalize-consultation-settlement',
                'source': 'financial-runtime-integration',
              },
            );

        final result = await runtimeModule.runtime.execute(
          pipeline: pipeline,
          executionContext: executionContext,
        );

        expect(result, isA<FinancialRuntimeExecutionSuccess>());

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);

        expect(result.executionId, 'execution-001');
        expect(result.correlationId, 'consultation-001');

        expect(result.pipelineId, 'consultation-settlement');

        expect(result.executedSteps, 3);
        expect(result.attempt, 1);
        expect(result.isRetry, isFalse);

        expect(result.runtimeDuration, const Duration(seconds: 2));

        expect(result.metadata['workflow'], 'finalize-consultation-settlement');

        expect(result.metadata['source'], 'financial-runtime-integration');

        expect(executionLog, [
          'validate-settlement',
          'calculate-settlement',
          'post-ledger-journal',
        ]);

        expect(pipelineContext.validated, isTrue);
        expect(pipelineContext.calculated, isTrue);
        expect(pipelineContext.journalPosted, isTrue);

        final success = result as FinancialRuntimeExecutionSuccess;

        expect(success.pipelineResult, isA<FinancialPipelineSuccess>());
      },
    );

    test('should execute pipeline steps sequentially', () async {
      final executionLog = <String>[];

      final firstStep = _RecordingFinancialPipelineStep(
        id: 'first-step',
        onExecute: (context) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));

          executionLog.add('first-step');
        },
      );

      final secondStep = _RecordingFinancialPipelineStep(
        id: 'second-step',
        onExecute: (context) async {
          executionLog.add('second-step');
        },
      );

      final thirdStep = _RecordingFinancialPipelineStep(
        id: 'third-step',
        onExecute: (context) async {
          executionLog.add('third-step');
        },
      );

      final fixture = _FinancialRuntimeFixture(
        completionTime: DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await fixture.execute(
        pipeline: _IntegrationFinancialPipeline(
          id: 'sequential-pipeline',
          steps: [firstStep, secondStep, thirdStep],
        ),
      );

      expect(result.isSuccess, isTrue);

      expect(executionLog, ['first-step', 'second-step', 'third-step']);

      expect(firstStep.executionCount, 1);
      expect(secondStep.executionCount, 1);
      expect(thirdStep.executionCount, 1);
    });

    test('should transform a failed step into Runtime failure', () async {
      final expectedError = StateError('Ledger posting failed.');

      final executionLog = <String>[];

      final pipeline = _IntegrationFinancialPipeline(
        id: 'failing-settlement',
        steps: [
          _RecordingFinancialPipelineStep(
            id: 'validate-settlement',
            onExecute: (context) async {
              executionLog.add('validate-settlement');
              context.validated = true;
            },
          ),
          _RecordingFinancialPipelineStep(
            id: 'post-ledger-journal',
            onExecute: (context) async {
              executionLog.add('post-ledger-journal');
              throw expectedError;
            },
          ),
          _RecordingFinancialPipelineStep(
            id: 'publish-settlement',
            onExecute: (context) async {
              executionLog.add('publish-settlement');
              context.published = true;
            },
          ),
        ],
      );

      final fixture = _FinancialRuntimeFixture(
        completionTime: DateTime.utc(2026, 7, 17, 20, 0, 1),
      );

      final result = await fixture.execute(
        pipeline: pipeline,
        executionId: 'execution-002',
        correlationId: 'consultation-002',
        attempt: 2,
      );

      expect(result, isA<FinancialRuntimeExecutionFailure>());

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.executionId, 'execution-002');
      expect(result.correlationId, 'consultation-002');
      expect(result.attempt, 2);
      expect(result.isRetry, isTrue);

      final failure = result as FinancialRuntimeExecutionFailure;

      expect(failure.pipelineId, 'failing-settlement');

      expect(failure.executedSteps, 1);

      expect(failure.failedStepId, 'post-ledger-journal');

      expect(failure.error, same(expectedError));
      expect(failure.stackTrace, isNotNull);

      expect(failure.pipelineResult, isA<FinancialPipelineFailure>());

      expect(executionLog, ['validate-settlement', 'post-ledger-journal']);
    });

    test('should stop execution immediately after a failed step', () async {
      final firstStep = _RecordingFinancialPipelineStep(
        id: 'first-step',
        onExecute: (context) async {
          context.validated = true;
        },
      );

      final failingStep = _RecordingFinancialPipelineStep(
        id: 'failing-step',
        onExecute: (context) async {
          throw StateError('Expected failure.');
        },
      );

      final unreachableStep = _RecordingFinancialPipelineStep(
        id: 'unreachable-step',
        onExecute: (context) async {
          context.published = true;
        },
      );

      final fixture = _FinancialRuntimeFixture();

      final result = await fixture.execute(
        pipeline: _IntegrationFinancialPipeline(
          id: 'stop-after-failure',
          steps: [firstStep, failingStep, unreachableStep],
        ),
      );

      expect(result.isFailure, isTrue);

      expect(firstStep.executionCount, 1);
      expect(failingStep.executionCount, 1);
      expect(unreachableStep.executionCount, 0);

      expect(fixture.pipelineContext.published, isFalse);
    });

    test(
      'should preserve the same pipeline context across all steps',
      () async {
        final receivedContexts = <Object>[];

        final fixture = _FinancialRuntimeFixture();

        final result = await fixture.execute(
          pipeline: _IntegrationFinancialPipeline(
            id: 'context-identity',
            steps: [
              _RecordingFinancialPipelineStep(
                id: 'step-001',
                onExecute: (context) async {
                  receivedContexts.add(context);
                },
              ),
              _RecordingFinancialPipelineStep(
                id: 'step-002',
                onExecute: (context) async {
                  receivedContexts.add(context);
                },
              ),
              _RecordingFinancialPipelineStep(
                id: 'step-003',
                onExecute: (context) async {
                  receivedContexts.add(context);
                },
              ),
            ],
          ),
        );

        expect(result.isSuccess, isTrue);
        expect(receivedContexts, hasLength(3));

        for (final receivedContext in receivedContexts) {
          expect(receivedContext, same(fixture.pipelineContext));
        }
      },
    );

    test(
      'should preserve immutable metadata through the complete chain',
      () async {
        final originalMetadata = <String, Object?>{
          'provider': 'paydunya',
          'country': 'ML',
        };

        final fixture = _FinancialRuntimeFixture();

        final result = await fixture.execute(
          pipeline: _IntegrationFinancialPipeline(
            id: 'metadata-pipeline',
            steps: [
              _RecordingFinancialPipelineStep(
                id: 'metadata-step',
                onExecute: (context) async {},
              ),
            ],
          ),
          metadata: originalMetadata,
        );

        originalMetadata['provider'] = 'modified';

        expect(result.metadata['provider'], 'paydunya');

        expect(result.metadata['country'], 'ML');

        expect(
          () => result.metadata['new-key'] = 'value',
          throwsUnsupportedError,
        );
      },
    );

    test(
      'should propagate invalid pipeline configuration exceptions',
      () async {
        final fixture = _FinancialRuntimeFixture();

        final future = fixture.execute(
          pipeline: _IntegrationFinancialPipeline(
            id: '',
            steps: [
              _RecordingFinancialPipelineStep(
                id: 'valid-step',
                onExecute: (context) async {},
              ),
            ],
          ),
        );

        await expectLater(
          future,
          throwsA(isA<InvalidFinancialPipelineException>()),
        );
      },
    );

    test('should reject a pipeline without steps', () async {
      final fixture = _FinancialRuntimeFixture();

      final future = fixture.execute(
        pipeline: _IntegrationFinancialPipeline(
          id: 'empty-pipeline',
          steps: const [],
        ),
      );

      await expectLater(
        future,
        throwsA(isA<InvalidFinancialPipelineException>()),
      );
    });

    test('should reject duplicate pipeline step identifiers', () async {
      final fixture = _FinancialRuntimeFixture();

      final future = fixture.execute(
        pipeline: _IntegrationFinancialPipeline(
          id: 'duplicate-steps',
          steps: [
            _RecordingFinancialPipelineStep(
              id: 'duplicate-step',
              onExecute: (context) async {},
            ),
            _RecordingFinancialPipelineStep(
              id: 'duplicate-step',
              onExecute: (context) async {},
            ),
          ],
        ),
      );

      await expectLater(
        future,
        throwsA(isA<InvalidFinancialPipelineException>()),
      );
    });

    test(
      'should preserve correlation across independent retry attempts',
      () async {
        final pipeline = _IntegrationFinancialPipeline(
          id: 'retryable-settlement',
          steps: [
            _RecordingFinancialPipelineStep(
              id: 'successful-step',
              onExecute: (context) async {
                context.validated = true;
              },
            ),
          ],
        );

        final fixture = _FinancialRuntimeFixture();

        final firstResult = await fixture.execute(
          pipeline: pipeline,
          executionId: 'execution-001',
          correlationId: 'consultation-777',
          attempt: 1,
        );

        final secondResult = await fixture.execute(
          pipeline: pipeline,
          executionId: 'execution-002',
          correlationId: 'consultation-777',
          attempt: 2,
        );

        expect(firstResult.executionId, 'execution-001');

        expect(secondResult.executionId, 'execution-002');

        expect(firstResult.correlationId, 'consultation-777');

        expect(secondResult.correlationId, 'consultation-777');

        expect(firstResult.attempt, 1);
        expect(secondResult.attempt, 2);

        expect(firstResult.isRetry, isFalse);
        expect(secondResult.isRetry, isTrue);

        expect(firstResult.isSuccess, isTrue);
        expect(secondResult.isSuccess, isTrue);
      },
    );
  });
}

final class _FinancialRuntimeFixture {
  _FinancialRuntimeFixture({DateTime? completionTime})
    : completionTime = completionTime ?? DateTime.utc(2026, 7, 17, 20, 0, 1),
      pipelineContext = _IntegrationFinancialPipelineContext();

  final DateTime completionTime;

  final _IntegrationFinancialPipelineContext pipelineContext;

  Future<FinancialRuntimeExecutionResult> execute({
    required _IntegrationFinancialPipeline pipeline,
    String executionId = 'execution-001',
    String correlationId = 'consultation-001',
    int attempt = 1,
    Map<String, Object?> metadata = const {},
  }) {
    final pipelineEngine = DefaultFinancialPipelineEngine(
      clock: () => DateTime.utc(2026, 7, 17, 20),
    );

    final runtimeModule = FinancialRuntimeModule.initialize(
      pipelineEngine: pipelineEngine,
      clock: () => completionTime,
    );

    final executionContext =
        FinancialRuntimeExecutionContext<_IntegrationFinancialPipelineContext>(
          executionId: executionId,
          correlationId: correlationId,
          pipelineContext: pipelineContext,
          startedAt: DateTime.utc(2026, 7, 17, 20),
          attempt: attempt,
          metadata: metadata,
        );

    return runtimeModule.runtime.execute(
      pipeline: pipeline,
      executionContext: executionContext,
    );
  }
}

final class _IntegrationFinancialPipelineContext
    extends FinancialPipelineContext {
  _IntegrationFinancialPipelineContext();

  bool validated = false;
  bool calculated = false;
  bool journalPosted = false;
  bool published = false;
}

final class _IntegrationFinancialPipeline
    implements FinancialPipeline<_IntegrationFinancialPipelineContext> {
  const _IntegrationFinancialPipeline({required this.id, required this.steps});

  @override
  final String id;

  @override
  final List<FinancialPipelineStep<_IntegrationFinancialPipelineContext>> steps;
}

typedef _StepExecution =
    Future<void> Function(_IntegrationFinancialPipelineContext context);

final class _RecordingFinancialPipelineStep
    implements FinancialPipelineStep<_IntegrationFinancialPipelineContext> {
  _RecordingFinancialPipelineStep({
    required this.id,
    required _StepExecution onExecute,
  }) : _onExecute = onExecute;

  @override
  final String id;

  final _StepExecution _onExecute;

  int executionCount = 0;

  @override
  Future<void> execute(_IntegrationFinancialPipelineContext context) async {
    executionCount++;
    await _onExecute(context);
  }
}
