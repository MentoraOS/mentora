import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';
import 'package:mentora/core/financial/domain/primitives/percentage/percentage.dart';
import 'package:mentora/core/financial/domain/shared/rates/revenue_share.dart';

void main() {
  group('ConsultationSettlement', () {
    late SettlementLine expertLine;

    setUp(() {
      expertLine = SettlementLine(
        party: SettlementParty.expert,
        rate: RevenueShare(Percentage.fromWholePercent(85)),
        amount: Money(minorUnits: 8500, currency: FinancialCurrency.xof),
      );
    });

    test('creates a valid settlement', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: [expertLine],
      );

      expect(settlement.id.value, 'settlement_001');
      expect(settlement.status, SettlementStatus.pending);
      expect(settlement.lineCount, 1);
      expect(settlement.isEmpty, isFalse);
      expect(settlement.isNotEmpty, isTrue);
    });

    test('markProcessing changes status', () {
      final settlement = createSettlement();

      final processingSettlement = settlement.markProcessing();

      expect(settlement.status, SettlementStatus.pending);

      expect(processingSettlement.status, SettlementStatus.processing);

      expect(processingSettlement.version, 1);
    });

    test('markCompleted changes status', () {
      final settlement = createSettlement();

      final processingSettlement = settlement.markProcessing();

      final completedSettlement = processingSettlement.markCompleted();

      expect(completedSettlement.status, SettlementStatus.completed);

      expect(completedSettlement.version, 2);
    });

    test('markFailed changes status', () {
      final settlement = createSettlement();

      final failedSettlement = settlement.markProcessing().markFailed(
        reason: 'Simulated settlement failure.',
      );

      expect(failedSettlement.status, SettlementStatus.failed);

      expect(failedSettlement.version, 2);
    });

    test('markRefunded changes status', () {
      final settlement = createSettlement();

      final refundedSettlement = settlement
          .markProcessing()
          .markCompleted()
          .markRefunded();

      expect(refundedSettlement.status, SettlementStatus.refunded);

      expect(refundedSettlement.version, 3);
    });

    test('markCancelled changes status', () {
      final settlement = createSettlement();

      final cancelledSettlement = settlement.markCancelled();

      expect(cancelledSettlement.status, SettlementStatus.cancelled);

      expect(cancelledSettlement.version, 1);
    });

    test('two identical settlements are equal', () {
      final first = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: [expertLine],
      );

      final second = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: [expertLine],
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('toString contains useful information', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: [expertLine],
      );

      expect(settlement.toString(), contains('ConsultationSettlement'));

      expect(settlement.toString(), contains('settlement_001'));
    });
  });
}

ConsultationSettlement createSettlement({
  SettlementStatus status = SettlementStatus.pending,
  int version = 0,
}) {
  return ConsultationSettlement(
    id: SettlementId('settlement_001'),
    lines: const <SettlementLine>[],
    status: status,
    version: version,
  );
}
