import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/primitives/percentage/percentage.dart';
import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';
import 'package:mentora/core/financial/domain/shared/rates/rates.dart';

import 'package:mentora/core/financial/orchestrator/workflows/financial_posting/factories/settlement_posting_instruction_factory.dart';

void main() {
  group('SettlementPostingInstructionFactory', () {
    const factory = SettlementPostingInstructionFactory();

    ConsultationSettlement createSettlement() {
      return ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: [
          SettlementLine(
            party: SettlementParty.expert,
            rate: RevenueShare(Percentage.fromWholePercent(70)),
            amount: Money(minorUnits: 7000, currency: FinancialCurrency.xof),
          ),
          SettlementLine(
            party: SettlementParty.platform,
            rate: FeeRate(Percentage.fromWholePercent(15)),
            amount: Money(minorUnits: 1500, currency: FinancialCurrency.xof),
          ),
          SettlementLine(
            party: SettlementParty.tax,
            rate: VatRate(Percentage.fromWholePercent(10)),
            amount: Money(minorUnits: 1000, currency: FinancialCurrency.xof),
          ),
          SettlementLine(
            party: SettlementParty.paymentProvider,
            rate: FeeRate(Percentage.fromWholePercent(5)),
            amount: Money(minorUnits: 500, currency: FinancialCurrency.xof),
          ),
        ],
      );
    }

    test('creates a valid posting instruction', () {
      final instruction = factory.create(
        settlement: createSettlement(),
        operationId: 'operation_001',
        consultationId: 'consultation_001',
        escrowId: 'escrow_001',
        clientId: 'client_001',
        expertId: 'expert_001',
        occurredAt: DateTime.utc(2026, 7, 19),
      );

      expect(instruction.settlementId.value, 'settlement_001');

      expect(instruction.lineCount, 4);

      expect(instruction.totalMinorUnits, 10000);

      expect(instruction.currency, FinancialCurrency.xof);
    });

    test('maps accounting codes correctly', () {
      final instruction = factory.create(
        settlement: createSettlement(),
        operationId: 'operation_001',
        consultationId: 'consultation_001',
        escrowId: 'escrow_001',
        clientId: 'client_001',
        expertId: 'expert_001',
        occurredAt: DateTime.utc(2026, 7, 19),
      );

      expect(instruction.lines[0].code, 'EXPERT_REVENUE');

      expect(instruction.lines[1].code, 'PLATFORM_REVENUE');

      expect(instruction.lines[2].code, 'TAX_PAYABLE');

      expect(instruction.lines[3].code, 'PAYMENT_PROVIDER_FEE');
    });

    test('copies settlement amounts', () {
      final instruction = factory.create(
        settlement: createSettlement(),
        operationId: 'operation_001',
        consultationId: 'consultation_001',
        escrowId: 'escrow_001',
        clientId: 'client_001',
        expertId: 'expert_001',
        occurredAt: DateTime.utc(2026, 7, 19),
      );

      expect(instruction.lines[0].amount.minorUnits, 7000);

      expect(instruction.lines[1].amount.minorUnits, 1500);

      expect(instruction.lines[2].amount.minorUnits, 1000);

      expect(instruction.lines[3].amount.minorUnits, 500);
    });

    test('adds default metadata', () {
      final instruction = factory.create(
        settlement: createSettlement(),
        operationId: 'operation_001',
        consultationId: 'consultation_001',
        escrowId: 'escrow_001',
        clientId: 'client_001',
        expertId: 'expert_001',
        occurredAt: DateTime.utc(2026, 7, 19),
      );

      expect(instruction.metadata['settlementId'], 'settlement_001');

      expect(instruction.metadata['settlementStatus'], 'pending');
    });

    test('keeps custom metadata', () {
      final instruction = factory.create(
        settlement: createSettlement(),
        operationId: 'operation_001',
        consultationId: 'consultation_001',
        escrowId: 'escrow_001',
        clientId: 'client_001',
        expertId: 'expert_001',
        occurredAt: DateTime.utc(2026, 7, 19),
        metadata: const {'source': 'pipeline'},
      );

      expect(instruction.metadata['source'], 'pipeline');

      expect(instruction.metadata['settlementId'], 'settlement_001');
    });
  });
}
