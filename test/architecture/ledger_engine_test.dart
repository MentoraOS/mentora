import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/chart/account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/chart_of_accounts.dart';
import 'package:mentora/core/financial/ledger/engine/ledger_engine.dart';
import 'package:mentora/core/financial/ledger/models/ledger_account.dart';
import 'package:mentora/core/financial/ledger/models/ledger_account_type.dart';
import 'package:mentora/core/financial/ledger/models/ledger_entry.dart';
import 'package:mentora/core/financial/ledger/models/ledger_entry_side.dart';
import 'package:mentora/core/financial/ledger/models/ledger_transaction.dart';
import 'package:mentora/core/financial/ledger/models/ledger_transaction_status.dart';
import 'package:mentora/core/financial/ledger/repositories/memory_ledger_repository.dart';

void main() {
  group('LedgerEngine', () {
    late MemoryLedgerRepository repository;
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;
    late LedgerEngine engine;

    setUp(() {
      repository = MemoryLedgerRepository();
      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('USD');

      engine = LedgerEngine(
        repository: repository,
        chartOfAccounts: chartOfAccounts,
      );
    });

    test('should post and retrieve a ledger transaction', () async {
      final clientWallet = chartOfAccounts.ensureClientWallet(
        clientId: 'client_001',
        currency: 'USD',
      );

      final clearing = chartOfAccounts.clearing('USD');

      final transaction = _buildTransaction(
        debitAccountId: clientWallet.id,
        creditAccountId: clearing.id,
      );

      final posted = await engine.post(transaction);

      expect(posted.id, transaction.id);
      expect(posted.referenceId, transaction.referenceId);
      expect(posted.isBalanced, isTrue);

      final saved = await engine.findById(transaction.id);

      expect(saved, isNotNull);
      expect(saved!.id, transaction.id);
    });

    test('should remain idempotent when posted twice', () async {
      final clientWallet = chartOfAccounts.ensureClientWallet(
        clientId: 'client_001',
        currency: 'USD',
      );

      final clearing = chartOfAccounts.clearing('USD');

      final transaction = _buildTransaction(
        debitAccountId: clientWallet.id,
        creditAccountId: clearing.id,
      );

      await engine.post(transaction);
      await engine.post(transaction);

      final transactions = await repository.findTransactionsByAccountId(
        clientWallet.id,
      );

      expect(transactions.length, 1);
    });

    test(
      'should reject the same transaction id with different content',
      () async {
        final clientWallet = chartOfAccounts.ensureClientWallet(
          clientId: 'client_001',
          currency: 'USD',
        );

        final clearing = chartOfAccounts.clearing('USD');

        const conflictingAccount = LedgerAccount(
          id: 'different_account_USD',
          ownerId: 'mentora_platform',
          currency: 'USD',
          type: LedgerAccountType.asset,
          name: 'Different Account USD',
        );

        accountRegistry.register(conflictingAccount);

        final original = _buildTransaction(
          debitAccountId: clientWallet.id,
          creditAccountId: clearing.id,
        );

        final conflicting = _buildTransaction(
          debitAccountId: clientWallet.id,
          creditAccountId: conflictingAccount.id,
        );

        await engine.post(original);

        expect(() => engine.post(conflicting), throwsStateError);
      },
    );

    test('should reject an unknown ledger account', () async {
      final clearing = chartOfAccounts.clearing('USD');

      final transaction = _buildTransaction(
        debitAccountId: 'unknown_account',
        creditAccountId: clearing.id,
      );

      expect(() => engine.post(transaction), throwsStateError);
    });

    test('should reject an inactive ledger account', () async {
      const inactiveAccount = LedgerAccount(
        id: 'inactive_wallet_USD',
        ownerId: 'client_001',
        currency: 'USD',
        type: LedgerAccountType.liability,
        name: 'Inactive Wallet USD',
        active: false,
      );

      accountRegistry.register(inactiveAccount);

      final clearing = chartOfAccounts.clearing('USD');

      final transaction = _buildTransaction(
        debitAccountId: inactiveAccount.id,
        creditAccountId: clearing.id,
      );

      expect(() => engine.post(transaction), throwsStateError);
    });

    test('should reject an account with another currency', () async {
      chartOfAccounts.initializeCurrency('EUR');

      final euroWallet = chartOfAccounts.ensureClientWallet(
        clientId: 'client_001',
        currency: 'EUR',
      );

      final usdClearing = chartOfAccounts.clearing('USD');

      final transaction = _buildTransaction(
        debitAccountId: euroWallet.id,
        creditAccountId: usdClearing.id,
      );

      expect(() => engine.post(transaction), throwsStateError);
    });

    test('should find a transaction by reference id', () async {
      final clientWallet = chartOfAccounts.ensureClientWallet(
        clientId: 'client_001',
        currency: 'USD',
      );

      final clearing = chartOfAccounts.clearing('USD');

      final transaction = _buildTransaction(
        debitAccountId: clientWallet.id,
        creditAccountId: clearing.id,
      );

      await engine.post(transaction);

      final saved = await engine.findByReferenceId(transaction.referenceId);

      expect(saved, isNotNull);
      expect(saved!.id, transaction.id);
    });
  });
}

LedgerTransaction _buildTransaction({
  required String debitAccountId,
  required String creditAccountId,
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
        accountId: debitAccountId,
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
