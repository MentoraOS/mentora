import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/orchestrator/registry/financial_workflow_registry.dart';
import 'package:mentora/core/financial/orchestrator/workflows/financial_workflow.dart';

void main() {
  group('FinancialWorkflowRegistry', () {
    late FinancialWorkflowRegistry registry;

    setUp(() {
      registry = FinancialWorkflowRegistry();
    });

    test('should register and resolve a financial workflow', () {
      final workflow = _TestFinancialWorkflow(
        key: 'settle.consultation',
        result: 'settled',
      );

      registry.register<_TestContext, String>(workflow);

      final resolved = registry.resolve<_TestContext, String>(
        'settle.consultation',
      );

      expect(resolved, same(workflow));
      expect(registry.length, 1);
      expect(registry.registeredKeys, contains('settle.consultation'));
    });

    test('should normalize workflow keys when resolving', () {
      final workflow = _TestFinancialWorkflow(
        key: 'settle.consultation',
        result: 'settled',
      );

      registry.register<_TestContext, String>(workflow);

      final resolved = registry.resolve<_TestContext, String>(
        '  SETTLE.CONSULTATION  ',
      );

      expect(resolved, same(workflow));
    });

    test('should report whether a workflow is supported', () {
      final workflow = _TestFinancialWorkflow(
        key: 'refund.payment',
        result: 'refunded',
      );

      registry.register<_TestContext, String>(workflow);

      expect(registry.supports('refund.payment'), isTrue);

      expect(registry.supports(' REFUND.PAYMENT '), isTrue);

      expect(registry.supports('request.payout'), isFalse);
    });

    test('should reject duplicate workflow registration', () {
      final first = _TestFinancialWorkflow(key: 'fund.escrow', result: 'first');

      final second = _TestFinancialWorkflow(
        key: ' FUND.ESCROW ',
        result: 'second',
      );

      registry.register<_TestContext, String>(first);

      expect(
        () => registry.register<_TestContext, String>(second),
        throwsStateError,
      );

      expect(registry.length, 1);
    });

    test('should reject an unknown workflow', () {
      expect(
        () => registry.resolve<_TestContext, String>('unknown.workflow'),
        throwsStateError,
      );
    });

    test('should reject incompatible generic types', () {
      final workflow = _TestFinancialWorkflow(
        key: 'settle.consultation',
        result: 'settled',
      );

      registry.register<_TestContext, String>(workflow);

      expect(
        () => registry.resolve<_AnotherContext, int>('settle.consultation'),
        throwsStateError,
      );
    });

    test('should unregister a financial workflow', () {
      final workflow = _TestFinancialWorkflow(
        key: 'request.payout',
        result: 'requested',
      );

      registry.register<_TestContext, String>(workflow);

      registry.unregister(' REQUEST.PAYOUT ');

      expect(registry.length, 0);
      expect(registry.supports('request.payout'), isFalse);
    });

    test('should reject unregistering an unknown workflow', () {
      expect(() => registry.unregister('unknown.workflow'), throwsStateError);
    });

    test('should clear every registered workflow', () {
      registry.register<_TestContext, String>(
        _TestFinancialWorkflow(key: 'authorize.payment', result: 'authorized'),
      );

      registry.register<_TestContext, String>(
        _TestFinancialWorkflow(key: 'fund.escrow', result: 'funded'),
      );

      expect(registry.length, 2);

      registry.clear();

      expect(registry.length, 0);
      expect(registry.registeredKeys, isEmpty);
    });

    test('should reject an empty workflow key', () {
      final workflow = _TestFinancialWorkflow(key: '   ', result: 'invalid');

      expect(
        () => registry.register<_TestContext, String>(workflow),
        throwsArgumentError,
      );
    });

    test('should execute the resolved workflow', () async {
      final workflow = _TestFinancialWorkflow(
        key: 'settle.consultation',
        result: 'consultation-settled',
      );

      registry.register<_TestContext, String>(workflow);

      final resolved = registry.resolve<_TestContext, String>(
        'settle.consultation',
      );

      final result = await resolved.execute(
        const _TestContext(operationId: 'operation_001'),
      );

      expect(result, 'consultation-settled');
      expect(workflow.executionCount, 1);
      expect(workflow.lastContext?.operationId, 'operation_001');
    });
  });
}

class _TestContext {
  final String operationId;

  const _TestContext({required this.operationId});
}

class _AnotherContext {
  final String id;

  const _AnotherContext({required this.id});
}

class _TestFinancialWorkflow
    implements FinancialWorkflow<_TestContext, String> {
  @override
  final String key;

  final String result;

  int executionCount = 0;
  _TestContext? lastContext;

  _TestFinancialWorkflow({required this.key, required this.result});

  @override
  Future<String> execute(_TestContext context) async {
    executionCount++;
    lastContext = context;

    return result;
  }
}
