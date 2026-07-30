import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/money/'
    'financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';

import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/financial_posting_context.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/financial_posting_result.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/financial_posting_workflow.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_category.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_instruction.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/models/settlement_posting_line.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/settlement_posting_port.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'financial_posting/settlement_posting_receipt.dart';

import 'package:mentora/core/financial/splits/models/'
    'settlement_split.dart';
import 'package:mentora/core/financial/splits/models/'
    'settlement_split_component.dart';
import 'package:mentora/core/financial/splits/models/'
    'split_destination.dart';

void main() {
  group('FinancialPostingWorkflow', () {
    late _FakeSettlementPostingPort postingPort;
    late FinancialPostingWorkflow workflow;

    setUp(() {
      postingPort = _FakeSettlementPostingPort();

      workflow = FinancialPostingWorkflow(postingPort: postingPort);
    });

    test('should expose its workflow key', () {
      expect(workflow.key, 'post.financial.settlement');
    });

    test('should post a valid settlement instruction', () async {
      final context = _buildContext();

      final FinancialPostingResult result = await workflow.execute(context);

      expect(result.success, isTrue);
      expect(result.operationId, 'settlement_001');
      expect(result.consultationId, 'consultation_001');
      expect(result.ledgerTransactionIds, contains('ledger_tx_001'));

      expect(postingPort.lastInstruction, isNotNull);
      expect(postingPort.lastInstruction!.totalMinorUnits, 10000);

      expect(result.postedAt, DateTime.utc(2026, 7, 12, 10));

      expect(postingPort.callCount, 1);
    });

    test(
      'should forward the complete instruction to the posting port',
      () async {
        final context = _buildContext();

        await workflow.execute(context);

        final instruction = postingPort.lastInstruction;

        expect(instruction, isNotNull);
        expect(instruction!.operationId, 'settlement_001');
        expect(instruction.consultationId, 'consultation_001');
        expect(instruction.escrowId, 'escrow_001');
        expect(instruction.clientId, 'client_001');
        expect(instruction.expertId, 'expert_001');
        expect(instruction.totalMinorUnits, 10000);
        expect(instruction.currency, FinancialCurrency.xof);
        expect(instruction.occurredAt, DateTime.utc(2026, 7, 12, 10));
        expect(
          instruction.metadata['source'],
          'financial_posting_workflow_test',
        );
      },
    );

    test(
      'should reject an instruction with a different operation id',
      () async {
        final context = _buildContext(
          instructionOperationId: 'another_settlement',
        );

        await expectLater(workflow.execute(context), throwsStateError);

        expect(postingPort.callCount, 0);
      },
    );

    test(
      'should reject an instruction with a different consultation id',
      () async {
        final context = _buildContext(
          instructionConsultationId: 'another_consultation',
        );

        await expectLater(workflow.execute(context), throwsStateError);

        expect(postingPort.callCount, 0);
      },
    );

    test('should reject an empty operation id', () {
      expect(() => _buildContext(operationId: '   '), throwsArgumentError);

      expect(postingPort.callCount, 0);
    });

    test('should reject an empty consultation id', () {
      expect(() => _buildContext(consultationId: ''), throwsArgumentError);

      expect(postingPort.callCount, 0);
    });

    test('should reject an empty escrow id', () {
      expect(() => _buildContext(escrowId: ' '), throwsArgumentError);

      expect(postingPort.callCount, 0);
    });

    test('should reject an empty client id', () {
      expect(() => _buildContext(clientId: ' '), throwsArgumentError);

      expect(postingPort.callCount, 0);
    });

    test('should reject an empty expert id', () {
      expect(() => _buildContext(expertId: ' '), throwsArgumentError);

      expect(postingPort.callCount, 0);
    });

    test('should propagate a posting port failure', () async {
      postingPort.shouldFail = true;

      await expectLater(workflow.execute(_buildContext()), throwsStateError);

      expect(postingPort.callCount, 1);
    });
  });
}

FinancialPostingContext _buildContext({
  String operationId = 'settlement_001',
  String consultationId = 'consultation_001',
  String escrowId = 'escrow_001',
  String clientId = 'client_001',
  String expertId = 'expert_001',
  String? instructionOperationId,
  String? instructionConsultationId,
}) {
  final split = _buildBalancedSplit();

  final instruction = _buildInstruction(
    operationId: instructionOperationId ?? operationId,
    consultationId: instructionConsultationId ?? consultationId,
    escrowId: escrowId,
    clientId: clientId,
    expertId: expertId,
    split: split,
  );

  return FinancialPostingContext(
    operationId: operationId,
    consultationId: consultationId,
    escrowId: escrowId,
    clientId: clientId,
    expertId: expertId,
    instruction: instruction,
    occurredAt: DateTime.utc(2026, 7, 12, 10),
    metadata: const <String, dynamic>{
      'source': 'financial_posting_workflow_test',
    },
  );
}

SettlementPostingInstruction _buildInstruction({
  required String operationId,
  required String consultationId,
  required String escrowId,
  required String clientId,
  required String expertId,
  required SettlementSplit split,
}) {
  return SettlementPostingInstruction(
    settlementId: SettlementId(
      operationId.trim().isEmpty ? 'fallback_settlement' : operationId,
    ),
    operationId: operationId,
    consultationId: consultationId,
    escrowId: escrowId,
    clientId: clientId,
    expertId: expertId,
    lines: split.components.map(_postingLineFor).toList(growable: false),
    occurredAt: DateTime.utc(2026, 7, 12, 10),
    metadata: const <String, Object?>{
      'source': 'financial_posting_workflow_test',
    },
  );
}

SettlementPostingLine _postingLineFor(SettlementSplitComponent component) {
  return SettlementPostingLine(
    party: _partyFor(component.destination),
    category: _categoryFor(component.destination),
    amount: Money(
      minorUnits: component.amountMinor,
      currency: FinancialCurrency.xof,
    ),
    code: component.code,
    label: component.label,
  );
}

SettlementParty _partyFor(SplitDestination destination) {
  return switch (destination) {
    SplitDestination.expertWallet => SettlementParty.expert,

    SplitDestination.platformRevenue => SettlementParty.platform,

    SplitDestination.taxPayable => SettlementParty.tax,

    SplitDestination.paymentProviderFee => SettlementParty.paymentProvider,
  };
}

SettlementPostingCategory _categoryFor(SplitDestination destination) {
  return switch (destination) {
    SplitDestination.expertWallet => SettlementPostingCategory.expertRevenue,

    SplitDestination.platformRevenue =>
      SettlementPostingCategory.platformRevenue,

    SplitDestination.taxPayable => SettlementPostingCategory.taxPayable,

    SplitDestination.paymentProviderFee =>
      SettlementPostingCategory.paymentProviderFee,
  };
}

SettlementSplit _buildBalancedSplit() {
  return SettlementSplit(
    grossAmountMinor: 10000,
    currency: 'XOF',
    components: _buildComponents(),
  );
}

List<SettlementSplitComponent> _buildComponents() {
  return const <SettlementSplitComponent>[
    SettlementSplitComponent(
      destination: SplitDestination.expertWallet,
      amountMinor: 8130,
      code: 'EXPERT_NET',
      label: 'Expert net amount',
    ),
    SettlementSplitComponent(
      destination: SplitDestination.platformRevenue,
      amountMinor: 1500,
      code: 'PLATFORM_FEE',
      label: 'Platform revenue',
    ),
    SettlementSplitComponent(
      destination: SplitDestination.taxPayable,
      amountMinor: 270,
      code: 'VAT',
      label: 'VAT payable',
    ),
    SettlementSplitComponent(
      destination: SplitDestination.paymentProviderFee,
      amountMinor: 100,
      code: 'PAYMENT_PROVIDER_FEE',
      label: 'Payment provider fee',
    ),
  ];
}

final class _FakeSettlementPostingPort implements SettlementPostingPort {
  bool shouldFail = false;
  int callCount = 0;

  SettlementPostingInstruction? lastInstruction;

  @override
  Future<SettlementPostingReceipt> postSettlement({
    required SettlementPostingInstruction instruction,
  }) async {
    callCount++;
    lastInstruction = instruction;

    if (shouldFail) {
      throw StateError('Simulated settlement posting failure');
    }

    return SettlementPostingReceipt(
      operationId: instruction.operationId,
      ledgerTransactionIds: const <String>['ledger_tx_001'],
    );
  }
}
