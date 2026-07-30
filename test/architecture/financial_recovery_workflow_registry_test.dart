import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/pipeline/'
    'financial_pipeline_context.dart';

import 'package:mentora/core/financial/pipeline/recovery/registry/'
    'financial_recovery_workflow_registry.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_decision.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_request.dart';
import 'package:mentora/core/financial/pipeline/recovery/strategies/'
    'financial_recovery_strategy_result.dart';

import 'package:mentora/core/financial/pipeline/recovery/workflows/'
    'financial_recovery_workflow.dart';

void main() {
  group('FinancialRecoveryWorkflowRegistry', () {
    late FinancialRecoveryWorkflowRegistry registry;

    setUp(() {
      registry = FinancialRecoveryWorkflowRegistry();
    });

    test('starts empty', () {
      expect(registry.length, 0);

      expect(registry.isEmpty, isTrue);

      expect(registry.isNotEmpty, isFalse);

      expect(registry.workflowKeys, isEmpty);

      expect(registry.pipelineIds, isEmpty);
    });

    test('registers one workflow', () {
      final workflow = _workflow();

      registry.register(workflow);

      expect(registry.length, 1);

      expect(registry.isEmpty, isFalse);

      expect(registry.isNotEmpty, isTrue);

      expect(registry.containsWorkflowKey(workflow.workflowKey), isTrue);

      expect(registry.containsPipelineId(workflow.pipelineId), isTrue);

      expect(registry.workflowKeys, ['recover.test.workflow']);

      expect(registry.pipelineIds, ['test.recovery.pipeline']);
    });

    test('normalizes workflow key and pipeline id during registration', () {
      final workflow = _workflow(
        workflowKey: '  recover.test.workflow  ',
        pipelineId: '  test.recovery.pipeline  ',
      );

      registry.register(workflow);

      expect(registry.containsWorkflowKey('recover.test.workflow'), isTrue);

      expect(registry.containsPipelineId('test.recovery.pipeline'), isTrue);

      expect(registry.workflowKeys, ['recover.test.workflow']);

      expect(registry.pipelineIds, ['test.recovery.pipeline']);
    });

    test('rejects an empty workflow key', () {
      final workflow = _workflow(workflowKey: '   ');

      expect(() => registry.register(workflow), throwsArgumentError);

      expect(registry.isEmpty, isTrue);
    });

    test('rejects an empty pipeline id', () {
      final workflow = _workflow(pipelineId: '   ');

      expect(() => registry.register(workflow), throwsArgumentError);

      expect(registry.isEmpty, isTrue);
    });

    test('rejects duplicate workflow keys', () {
      final first = _workflow(
        workflowKey: 'recover.shared.workflow',
        pipelineId: 'first.recovery.pipeline',
      );

      final second = _workflow(
        workflowKey: ' recover.shared.workflow ',
        pipelineId: 'second.recovery.pipeline',
      );

      registry.register(first);

      expect(() => registry.register(second), throwsStateError);

      expect(registry.length, 1);

      expect(registry.containsPipelineId(second.pipelineId), isFalse);
    });

    test('rejects duplicate pipeline ownership', () {
      final first = _workflow(
        workflowKey: 'recover.first.workflow',
        pipelineId: 'shared.recovery.pipeline',
      );

      final second = _workflow(
        workflowKey: 'recover.second.workflow',
        pipelineId: ' shared.recovery.pipeline ',
      );

      registry.register(first);

      expect(() => registry.register(second), throwsStateError);

      expect(registry.length, 1);

      expect(registry.containsWorkflowKey(second.workflowKey), isFalse);
    });

    test('finds a workflow by key', () {
      final workflow = _workflow();

      registry.register(workflow);

      final found = registry.findByKey<_TestRecoveryContext>(
        workflow.workflowKey,
      );

      expect(found, same(workflow));
    });

    test('normalizes workflow key during lookup', () {
      final workflow = _workflow();

      registry.register(workflow);

      final found = registry.findByKey<_TestRecoveryContext>(
        '  ${workflow.workflowKey}  ',
      );

      expect(found, same(workflow));
    });

    test('returns null for an unknown workflow key', () {
      expect(
        registry.findByKey<_TestRecoveryContext>('unknown.workflow'),
        isNull,
      );
    });

    test('returns null for an empty workflow key', () {
      expect(registry.findByKey<_TestRecoveryContext>('   '), isNull);
    });

    test('returns null when workflow context type does not match', () {
      final workflow = _workflow();

      registry.register(workflow);

      final found = registry.findByKey<_AnotherRecoveryContext>(
        workflow.workflowKey,
      );

      expect(found, isNull);
    });

    test('finds a workflow by pipeline id', () {
      final workflow = _workflow();

      registry.register(workflow);

      final found = registry.findByPipelineId<_TestRecoveryContext>(
        workflow.pipelineId,
      );

      expect(found, same(workflow));
    });

    test('normalizes pipeline id during lookup', () {
      final workflow = _workflow();

      registry.register(workflow);

      final found = registry.findByPipelineId<_TestRecoveryContext>(
        '  ${workflow.pipelineId}  ',
      );

      expect(found, same(workflow));
    });

    test('returns null for an unknown pipeline id', () {
      expect(
        registry.findByPipelineId<_TestRecoveryContext>(
          'unknown.recovery.pipeline',
        ),
        isNull,
      );
    });

    test('returns null for an empty pipeline id', () {
      expect(registry.findByPipelineId<_TestRecoveryContext>('   '), isNull);
    });

    test('resolves the workflow supporting a request', () {
      final workflow = _workflow();

      registry.register(workflow);

      final request = _request(pipelineId: workflow.pipelineId);

      final resolved = registry.resolve(request);

      expect(resolved, same(workflow));

      expect(workflow.supportsCallCount, 1);

      expect(workflow.receivedRequest, same(request));
    });

    test('returns null when no workflow owns the request pipeline', () {
      registry.register(_workflow());

      final resolved = registry.resolve(
        _request(pipelineId: 'unknown.recovery.pipeline'),
      );

      expect(resolved, isNull);
    });

    test('returns null when the workflow rejects the request', () {
      final workflow = _workflow(supportsRequest: false);

      registry.register(workflow);

      final request = _request(pipelineId: workflow.pipelineId);

      final resolved = registry.resolve(request);

      expect(resolved, isNull);

      expect(workflow.supportsCallCount, 1);

      expect(workflow.receivedRequest, same(request));
    });

    test('resolveRequired returns the supported workflow', () {
      final workflow = _workflow();

      registry.register(workflow);

      final request = _request(pipelineId: workflow.pipelineId);

      final resolved = registry.resolveRequired(request);

      expect(resolved, same(workflow));
    });

    test('resolveRequired throws when no workflow can execute the request', () {
      registry.register(_workflow());

      final request = _request(pipelineId: 'unknown.recovery.pipeline');

      expect(() => registry.resolveRequired(request), throwsStateError);
    });

    test('resolveRequired throws when the workflow rejects the request', () {
      final workflow = _workflow(supportsRequest: false);

      registry.register(workflow);

      final request = _request(pipelineId: workflow.pipelineId);

      expect(() => registry.resolveRequired(request), throwsStateError);
    });

    test('contains methods normalize identifiers', () {
      final workflow = _workflow();

      registry.register(workflow);

      expect(
        registry.containsWorkflowKey('  ${workflow.workflowKey}  '),
        isTrue,
      );

      expect(registry.containsPipelineId('  ${workflow.pipelineId}  '), isTrue);

      expect(registry.containsWorkflowKey('   '), isFalse);

      expect(registry.containsPipelineId('   '), isFalse);
    });

    test('returns workflow keys sorted and immutable', () {
      registry.register(
        _workflow(workflowKey: 'workflow.b', pipelineId: 'pipeline.b'),
      );

      registry.register(
        _workflow(workflowKey: 'workflow.a', pipelineId: 'pipeline.a'),
      );

      registry.register(
        _workflow(workflowKey: 'workflow.c', pipelineId: 'pipeline.c'),
      );

      final keys = registry.workflowKeys;

      expect(keys, ['workflow.a', 'workflow.b', 'workflow.c']);

      expect(() => keys.add('workflow.d'), throwsUnsupportedError);
    });

    test('returns pipeline ids sorted and immutable', () {
      registry.register(
        _workflow(workflowKey: 'workflow.b', pipelineId: 'pipeline.b'),
      );

      registry.register(
        _workflow(workflowKey: 'workflow.a', pipelineId: 'pipeline.a'),
      );

      registry.register(
        _workflow(workflowKey: 'workflow.c', pipelineId: 'pipeline.c'),
      );

      final ids = registry.pipelineIds;

      expect(ids, ['pipeline.a', 'pipeline.b', 'pipeline.c']);

      expect(() => ids.add('pipeline.d'), throwsUnsupportedError);
    });

    test('does not execute workflows during registration or resolution', () {
      final workflow = _workflow();

      registry.register(workflow);

      final request = _request(pipelineId: workflow.pipelineId);

      registry.resolveRequired(request);

      expect(workflow.executeCallCount, 0);
    });
  });
}

_FakeRecoveryWorkflow _workflow({
  String workflowKey = 'recover.test.workflow',
  String pipelineId = 'test.recovery.pipeline',
  bool supportsRequest = true,
}) {
  return _FakeRecoveryWorkflow(
    workflowKey: workflowKey,
    pipelineId: pipelineId,
    supportsRequest: supportsRequest,
  );
}

FinancialRecoveryStrategyRequest<_TestRecoveryContext> _request({
  String pipelineId = 'test.recovery.pipeline',
}) {
  return FinancialRecoveryStrategyRequest<_TestRecoveryContext>(
    recoveryId: 'recovery_001',
    pipelineId: pipelineId,
    context: const _TestRecoveryContext(operationId: 'operation_001'),
    error: StateError('Original financial operation failed.'),
    stackTrace: StackTrace.current,
    attempt: 1,
    requestedAt: DateTime.utc(2026, 7, 17, 10),
    metadata: const {'trigger': 'registry_test'},
  );
}

final class _FakeRecoveryWorkflow
    implements FinancialRecoveryWorkflow<_TestRecoveryContext> {
  _FakeRecoveryWorkflow({
    required this.workflowKey,
    required this.pipelineId,
    required this.supportsRequest,
  });

  @override
  final String workflowKey;

  @override
  final String pipelineId;

  final bool supportsRequest;

  Object? receivedRequest;

  int supportsCallCount = 0;

  int executeCallCount = 0;

  @override
  bool supports(
    FinancialRecoveryStrategyRequest<_TestRecoveryContext> request,
  ) {
    supportsCallCount++;

    receivedRequest = request;

    return supportsRequest && request.pipelineId.trim() == pipelineId.trim();
  }

  @override
  Future<FinancialRecoveryStrategyResult> execute({
    required FinancialRecoveryStrategyRequest<_TestRecoveryContext> request,
  }) async {
    executeCallCount++;

    return FinancialRecoveryStrategySuccess(
      recoveryId: request.recoveryId,
      strategyKey: workflowKey,
      decision: FinancialRecoveryDecision.ignore,
      attempt: request.attempt,
      duration: Duration.zero,
      completedAt: DateTime.utc(2026, 7, 17, 11),
    );
  }
}

final class _TestRecoveryContext extends FinancialPipelineContext {
  const _TestRecoveryContext({required this.operationId});

  final String operationId;
}

final class _AnotherRecoveryContext extends FinancialPipelineContext {
  const _AnotherRecoveryContext({required this.referenceId});

  final String referenceId;
}
