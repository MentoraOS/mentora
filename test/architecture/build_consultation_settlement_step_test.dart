import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/rates/rates.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/pipeline/'
    'finalize_consultation_settlement_context.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'finalize_consultation_settlement/steps/'
    'build_consultation_settlement_step.dart';
import 'package:mentora/core/financial/orchestrator/workflows/'
    'settle_consultation/settle_consultation_context.dart';
import 'package:mentora/core/financial/splits/models/'
    'settlement_split.dart';
import 'package:mentora/core/financial/splits/models/'
    'settlement_split_component.dart';
import 'package:mentora/core/financial/splits/models/'
    'split_destination.dart';

void main() {
  group('BuildConsultationSettlementStep', () {
    const step = BuildConsultationSettlementStep();

    FinalizeConsultationSettlementContext createContext() {
      return FinalizeConsultationSettlementContext(
        settlementContext: SettleConsultationContext(
          operationId: 'settlement_001',
          consultationId: 'consultation_001',
          paymentId: 'payment_001',
          escrowId: 'escrow_001',
          clientId: 'client_001',
          expertId: 'expert_001',
          grossAmountMinor: 10000,
          currency: 'XOF',
          occurredAt: DateTime.utc(2026, 7, 18),
        ),
      )..idempotencyDecision = SettlementIdempotencyDecision.continueProcessing;
    }

    SettlementSplit createValidSplit() {
      return const SettlementSplit(
        grossAmountMinor: 10000,
        currency: 'XOF',
        components: <SettlementSplitComponent>[
          SettlementSplitComponent(
            destination: SplitDestination.expertWallet,
            amountMinor: 7000,
            code: 'EXPERT_REVENUE',
            label: 'Expert revenue',
          ),
          SettlementSplitComponent(
            destination: SplitDestination.platformRevenue,
            amountMinor: 1500,
            code: 'PLATFORM_REVENUE',
            label: 'Platform revenue',
          ),
          SettlementSplitComponent(
            destination: SplitDestination.taxPayable,
            amountMinor: 1000,
            code: 'TAX_PAYABLE',
            label: 'Tax payable',
          ),
          SettlementSplitComponent(
            destination: SplitDestination.paymentProviderFee,
            amountMinor: 500,
            code: 'PAYMENT_PROVIDER_FEE',
            label: 'Payment provider fee',
          ),
        ],
      );
    }

    test('has a stable pipeline step identifier', () {
      expect(step.id, 'build-consultation-settlement');
    });

    test('builds a valid ConsultationSettlement from the split', () async {
      final context = createContext()..split = createValidSplit();

      await step.execute(context);

      final settlement = context.settlement;

      expect(settlement, isNotNull);
      expect(settlement!.id.value, 'settlement_001');
      expect(settlement.status, SettlementStatus.pending);
      expect(settlement.lineCount, 4);
      expect(SettlementValidator.isValid(settlement), isTrue);
    });

    test('maps every split destination to the correct party', () async {
      final context = createContext()..split = createValidSplit();

      await step.execute(context);

      final lines = context.settlement!.lines;

      expect(lines[0].party, SettlementParty.expert);
      expect(lines[1].party, SettlementParty.platform);
      expect(lines[2].party, SettlementParty.tax);
      expect(lines[3].party, SettlementParty.paymentProvider);
    });

    test('converts every component amount into Money', () async {
      final context = createContext()..split = createValidSplit();

      await step.execute(context);

      final lines = context.settlement!.lines;

      expect(lines[0].amount.minorUnits, 7000);
      expect(lines[1].amount.minorUnits, 1500);
      expect(lines[2].amount.minorUnits, 1000);
      expect(lines[3].amount.minorUnits, 500);

      for (final line in lines) {
        expect(line.amount.currency.code, 'XOF');
      }
    });

    test('creates the correct strongly typed financial rates', () async {
      final context = createContext()..split = createValidSplit();

      await step.execute(context);

      final lines = context.settlement!.lines;

      expect(lines[0].rate, isA<RevenueShare>());
      expect(lines[1].rate, isA<FeeRate>());
      expect(lines[2].rate, isA<VatRate>());
      expect(lines[3].rate, isA<FeeRate>());

      expect(lines[0].rate.percentage.partsPerMillion, 700000);
      expect(lines[1].rate.percentage.partsPerMillion, 150000);
      expect(lines[2].rate.percentage.partsPerMillion, 100000);
      expect(lines[3].rate.percentage.partsPerMillion, 50000);
    });

    test('throws StateError when the split is missing', () async {
      final context = createContext();

      expect(() => step.execute(context), throwsA(isA<StateError>()));

      expect(context.settlement, isNull);
    });

    test('throws StateError when the split is unbalanced', () async {
      final context = createContext()
        ..split = const SettlementSplit(
          grossAmountMinor: 10000,
          currency: 'XOF',
          components: <SettlementSplitComponent>[
            SettlementSplitComponent(
              destination: SplitDestination.expertWallet,
              amountMinor: 7000,
              code: 'EXPERT_REVENUE',
              label: 'Expert revenue',
            ),
            SettlementSplitComponent(
              destination: SplitDestination.platformRevenue,
              amountMinor: 1000,
              code: 'PLATFORM_REVENUE',
              label: 'Platform revenue',
            ),
          ],
        );

      expect(() => step.execute(context), throwsA(isA<StateError>()));

      expect(context.settlement, isNull);
    });

    test('throws StateError when gross amount is zero', () async {
      final context = createContext()
        ..split = const SettlementSplit(
          grossAmountMinor: 0,
          currency: 'XOF',
          components: <SettlementSplitComponent>[],
        );

      expect(() => step.execute(context), throwsA(isA<StateError>()));

      expect(context.settlement, isNull);
    });

    test('normalizes the split currency code', () async {
      final context = createContext()
        ..split = const SettlementSplit(
          grossAmountMinor: 10000,
          currency: '  xof  ',
          components: <SettlementSplitComponent>[
            SettlementSplitComponent(
              destination: SplitDestination.expertWallet,
              amountMinor: 10000,
              code: 'EXPERT_REVENUE',
              label: 'Expert revenue',
            ),
          ],
        );

      await step.execute(context);

      expect(context.settlement!.lines.single.amount.currency.code, 'XOF');
    });
  });
}
