import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/escrow/models/escrow.dart';
import 'package:mentora/core/escrow/models/escrow_status.dart';

import 'package:mentora/core/financial/ledger/balance/balance_engine.dart';
import 'package:mentora/core/financial/ledger/chart/account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/chart_of_accounts.dart';
import 'package:mentora/core/financial/ledger/engine/ledger_engine.dart';
import 'package:mentora/core/financial/ledger/posting/builders/ledger_posting_builder.dart';
import 'package:mentora/core/financial/ledger/posting/engine/posting_engine.dart';
import 'package:mentora/core/financial/ledger/posting/services/escrow_posting_service.dart';
import 'package:mentora/core/financial/ledger/posting/templates/payment_posting_templates.dart';
import 'package:mentora/core/financial/ledger/repositories/memory_ledger_repository.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_request.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_type.dart';

void main() {
  group('EscrowPostingService', () {
    late MemoryLedgerRepository ledgerRepository;
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;
    late LedgerEngine ledgerEngine;
    late BalanceEngine balanceEngine;
    late PaymentPostingTemplates paymentTemplates;
    late LedgerPostingBuilder postingBuilder;
    late PostingEngine postingEngine;
    late EscrowPostingService escrowPostingService;

    setUp(() {
      ledgerRepository = MemoryLedgerRepository();
      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('USD');

      ledgerEngine = LedgerEngine(
        repository: ledgerRepository,
        chartOfAccounts: chartOfAccounts,
      );

      balanceEngine = BalanceEngine(
        repository: ledgerRepository,
        chartOfAccounts: chartOfAccounts,
      );

      paymentTemplates = PaymentPostingTemplates(
        chartOfAccounts: chartOfAccounts,
      );

      postingBuilder = LedgerPostingBuilder(paymentTemplates: paymentTemplates);

      postingEngine = PostingEngine(
        builder: postingBuilder,
        ledgerEngine: ledgerEngine,
        balanceEngine: balanceEngine,
      );

      escrowPostingService = EscrowPostingService(postingEngine: postingEngine);
    });

    test('should move client wallet funds to escrow when locked', () async {
      final escrow = _buildEscrow();

      // Précondition comptable :
      // le paiement a déjà crédité le wallet client.
      await postingEngine.post(
        _buildAuthorizationRequest(escrow: escrow, amountMinor: 6000),
      );

      await escrowPostingService.onLocked(
        escrow: escrow,
        amountMinor: 6000,
        occurredAt: DateTime.utc(2026, 7, 11, 10),
      );

      final clientWallet = chartOfAccounts.ensureClientWallet(
        clientId: escrow.payerId,
        currency: escrow.currency,
      );

      final escrowAccount = chartOfAccounts.ensureEscrow(
        consultationId: escrow.consultationId,
        currency: escrow.currency,
      );

      final clientBalance = await balanceEngine.calculate(clientWallet.id);

      final escrowBalance = await balanceEngine.calculate(escrowAccount.id);

      expect(clientBalance.creditMinor, 6000);
      expect(clientBalance.debitMinor, 6000);
      expect(clientBalance.balanceMinor, 0);

      expect(escrowBalance.creditMinor, 6000);
      expect(escrowBalance.debitMinor, 0);
      expect(escrowBalance.balanceMinor, 6000);
    });

    test('should move escrow funds to expert wallet when released', () async {
      final escrow = _buildEscrow();

      await postingEngine.post(
        _buildAuthorizationRequest(escrow: escrow, amountMinor: 6000),
      );

      await escrowPostingService.onLocked(
        escrow: escrow,
        amountMinor: 6000,
        occurredAt: DateTime.utc(2026, 7, 11, 10),
      );

      await escrowPostingService.onReleased(
        escrow: escrow,
        amountMinor: 6000,
        occurredAt: DateTime.utc(2026, 7, 11, 11),
      );

      final escrowAccount = chartOfAccounts.ensureEscrow(
        consultationId: escrow.consultationId,
        currency: escrow.currency,
      );

      final expertWallet = chartOfAccounts.ensureExpertWallet(
        expertId: escrow.receiverId,
        currency: escrow.currency,
      );

      final escrowBalance = await balanceEngine.calculate(escrowAccount.id);

      final expertBalance = await balanceEngine.calculate(expertWallet.id);

      expect(escrowBalance.creditMinor, 6000);
      expect(escrowBalance.debitMinor, 6000);
      expect(escrowBalance.balanceMinor, 0);

      expect(expertBalance.creditMinor, 6000);
      expect(expertBalance.debitMinor, 0);
      expect(expertBalance.balanceMinor, 6000);
    });

    test('should return escrow funds to client wallet when refunded', () async {
      final escrow = _buildEscrow();

      await postingEngine.post(
        _buildAuthorizationRequest(escrow: escrow, amountMinor: 6000),
      );

      await escrowPostingService.onLocked(
        escrow: escrow,
        amountMinor: 6000,
        occurredAt: DateTime.utc(2026, 7, 11, 10),
      );

      await escrowPostingService.onRefunded(
        escrow: escrow,
        amountMinor: 6000,
        occurredAt: DateTime.utc(2026, 7, 11, 11),
      );

      final clientWallet = chartOfAccounts.ensureClientWallet(
        clientId: escrow.payerId,
        currency: escrow.currency,
      );

      final escrowAccount = chartOfAccounts.ensureEscrow(
        consultationId: escrow.consultationId,
        currency: escrow.currency,
      );

      final clientBalance = await balanceEngine.calculate(clientWallet.id);

      final escrowBalance = await balanceEngine.calculate(escrowAccount.id);

      expect(clientBalance.creditMinor, 12000);
      expect(clientBalance.debitMinor, 6000);
      expect(clientBalance.balanceMinor, 6000);

      expect(escrowBalance.creditMinor, 6000);
      expect(escrowBalance.debitMinor, 6000);
      expect(escrowBalance.balanceMinor, 0);
    });

    test('should not create a ledger transaction when cancelled', () async {
      final escrow = _buildEscrow();

      await escrowPostingService.onCancelled(
        escrow: escrow,
        occurredAt: DateTime.utc(2026, 7, 11, 10),
      );

      final transaction = await ledgerRepository.findTransactionById(
        'escrow_${escrow.id}_cancelled',
      );

      expect(transaction, isNull);
    });

    test('should remain idempotent when lock is posted twice', () async {
      final escrow = _buildEscrow();
      final occurredAt = DateTime.utc(2026, 7, 11, 10);

      await postingEngine.post(
        _buildAuthorizationRequest(escrow: escrow, amountMinor: 6000),
      );

      await escrowPostingService.onLocked(
        escrow: escrow,
        amountMinor: 6000,
        occurredAt: occurredAt,
      );

      await escrowPostingService.onLocked(
        escrow: escrow,
        amountMinor: 6000,
        occurredAt: occurredAt,
      );

      final escrowAccount = chartOfAccounts.ensureEscrow(
        consultationId: escrow.consultationId,
        currency: escrow.currency,
      );

      final transactions = await ledgerRepository.findTransactionsByAccountId(
        escrowAccount.id,
      );

      expect(transactions.length, 1);

      final balance = await balanceEngine.calculate(escrowAccount.id);

      expect(balance.balanceMinor, 6000);
    });

    test('should reject an invalid amount', () async {
      final escrow = _buildEscrow();

      expect(
        () => escrowPostingService.onLocked(
          escrow: escrow,
          amountMinor: 0,
          occurredAt: DateTime.utc(2026, 7, 11, 10),
        ),
        throwsArgumentError,
      );
    });
  });
}

PostingRequest _buildAuthorizationRequest({
  required Escrow escrow,
  required int amountMinor,
}) {
  return PostingRequest(
    id: 'payment_${escrow.paymentId}_authorized',
    referenceId: escrow.paymentId,
    type: PostingType.paymentAuthorized,
    consultationId: escrow.consultationId,
    clientId: escrow.payerId,
    expertId: escrow.receiverId,
    amountMinor: amountMinor,
    currency: escrow.currency,
    createdAt: DateTime.utc(2026, 7, 11, 9),
    metadata: const {'source': 'escrow_posting_service_test'},
  );
}

Escrow _buildEscrow() {
  return const Escrow(
    id: 'escrow_001',
    paymentId: 'payment_001',
    consultationId: 'consultation_001',
    payerId: 'client_001',
    receiverId: 'expert_001',
    amount: 60,
    currency: 'USD',
    status: EscrowStatus.locked,
  );
}
