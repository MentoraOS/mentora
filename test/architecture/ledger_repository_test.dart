import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/financial/ledger/models/ledger_entry.dart';
import 'package:mentora/core/financial/ledger/models/ledger_entry_side.dart';
import 'package:mentora/core/financial/ledger/models/ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/ledger_transaction_status.dart';
import 'package:mentora/core/financial/ledger/repositories/memory_ledger_repository.dart';

void main() {
  group('MemoryLedgerRepository', () {
    late MemoryLedgerRepository repository;

    setUp(() {
      repository = MemoryLedgerRepository();
    });

    test('should save and retrieve a transaction', () async {
      final transaction = _buildTransaction();

      await repository.saveTransaction(transaction);

      final saved = await repository.findTransactionById(transaction.id);

      expect(saved, same(transaction));
      expect(
        await repository.existsByReferenceId(transaction.referenceId),
        isTrue,
      );
    });

    test('should accept an idempotent duplicate', () async {
      final transaction = _buildTransaction();

      await repository.saveTransaction(transaction);
      await repository.saveTransaction(transaction);

      final transactions = await repository.findTransactionsByAccountId(
        'client_wallet_001',
      );

      expect(transactions.length, 1);
    });

    test(
      'should reject the same transaction id with different content',
      () async {
        final original = _buildTransaction();

        final conflicting = _buildTransaction(
          creditAccountId: 'another_account',
        );

        await repository.saveTransaction(original);

        expect(() => repository.saveTransaction(conflicting), throwsStateError);
      },
    );

    test('should find entries by account id', () async {
      final transaction = _buildTransaction();

      await repository.saveTransaction(transaction);

      final entries = await repository.findEntriesByAccountId(
        'client_wallet_001',
      );

      expect(entries.length, 1);
      expect(entries.first.amountMinor, 6000);
    });
  });
}

LedgerTransaction _buildTransaction({
  String creditAccountId = 'mentora_clearing_001',
}) {
  final now = DateTime.utc(2026, 7, 10);

  return LedgerTransaction(
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
        accountId: creditAccountId,
        amountMinor: 6000,
        currency: 'USD',
        side: LedgerEntrySide.credit,
        createdAt: now,
      ),
    ],
  );
}
