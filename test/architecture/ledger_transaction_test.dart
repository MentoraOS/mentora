import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/financial/ledger/models/ledger_entry.dart';
import 'package:mentora/core/financial/ledger/models/ledger_entry_side.dart';
import 'package:mentora/core/financial/ledger/models/ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/ledger_transaction_status.dart';

void main() {
  group('LedgerTransaction', () {
    test('should accept a balanced double-entry transaction', () {
      final now = DateTime.now();

      final transaction = LedgerTransaction(
        id: 'ledger_tx_001',
        referenceId: 'payment_001',
        description: 'Client payment authorization',
        currency: 'USD',
        status: LedgerTransactionStatus.posted,
        createdAt: now,
        entries: [
          LedgerEntry(
            id: 'entry_001',
            transactionId: 'ledger_tx_001',
            accountId: 'client_wallet_001',
            amountMinor: 6000,
            currency: 'USD',
            side: LedgerEntrySide.debit,
            createdAt: now,
          ),
          LedgerEntry(
            id: 'entry_002',
            transactionId: 'ledger_tx_001',
            accountId: 'mentora_clearing_001',
            amountMinor: 6000,
            currency: 'USD',
            side: LedgerEntrySide.credit,
            createdAt: now,
          ),
        ],
      );

      expect(transaction.isBalanced, isTrue);
      expect(transaction.totalDebits, 6000);
      expect(transaction.totalCredits, 6000);
    });

    test('should reject an unbalanced transaction', () {
      final now = DateTime.now();

      expect(
        () => LedgerTransaction(
          id: 'ledger_tx_002',
          referenceId: 'payment_002',
          description: 'Invalid transaction',
          currency: 'USD',
          status: LedgerTransactionStatus.pending,
          createdAt: now,
          entries: [
            LedgerEntry(
              id: 'entry_003',
              transactionId: 'ledger_tx_002',
              accountId: 'client_wallet_001',
              amountMinor: 6000,
              currency: 'USD',
              side: LedgerEntrySide.debit,
              createdAt: now,
            ),
            LedgerEntry(
              id: 'entry_004',
              transactionId: 'ledger_tx_002',
              accountId: 'mentora_clearing_001',
              amountMinor: 5000,
              currency: 'USD',
              side: LedgerEntrySide.credit,
              createdAt: now,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });
  });
}
