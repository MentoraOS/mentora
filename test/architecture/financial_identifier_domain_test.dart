import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/financial/domain/shared/exceptions/invalid_financial_identifier_exception.dart';
import 'package:mentora/core/financial/domain/shared/identity/identity.dart';

void main() {
  group('FinancialIdentifier', () {
    test('creates a strongly typed identifier and trims edge whitespace', () {
      final SettlementId id = SettlementId.fromString(' settlement_001 ');

      expect(id.value, 'settlement_001');
      expect(id.toPrimitive(), 'settlement_001');
      expect(id.toString(), 'SettlementId(settlement_001)');
    });

    test('rejects an empty identifier at runtime', () {
      expect(
        () => SettlementId.fromString(''),
        throwsA(isA<InvalidFinancialIdentifierException>()),
      );
    });

    test('rejects whitespace-only identifiers at runtime', () {
      expect(
        () => PaymentId.fromString('  \n\t  '),
        throwsA(isA<InvalidFinancialIdentifierException>()),
      );
    });

    test('uses value equality inside the same identifier type', () {
      final first = EscrowId.fromString('escrow_001');
      final same = EscrowId.fromString('escrow_001');
      final different = EscrowId.fromString('escrow_002');

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first, isNot(different));
    });

    test('never equates different identifier types', () {
      final settlement = SettlementId.fromString('shared_001');
      final payment = PaymentId.fromString('shared_001');

      expect(settlement, isNot(payment));
      expect(settlement.hashCode, isNot(payment.hashCode));
    });

    test('supports every initial financial identifier type', () {
      final identifiers = <FinancialIdentifier>[
        SettlementId.fromString('settlement_001'),
        EscrowId.fromString('escrow_001'),
        PaymentId.fromString('payment_001'),
        PayoutId.fromString('payout_001'),
        RefundId.fromString('refund_001'),
        WalletId.fromString('wallet_001'),
        FinancialOperationId.fromString('operation_001'),
        LedgerTransactionId.fromString('ledger_tx_001'),
        ExecutionId.fromString('execution_001'),
        CorrelationId.fromString('correlation_001'),
      ];

      expect(identifiers, hasLength(10));
      expect(identifiers.map((id) => id.value), everyElement(isNotEmpty));
    });
  });
}
