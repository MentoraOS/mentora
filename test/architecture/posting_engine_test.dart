import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/balance/balance_engine.dart';
import 'package:mentora/core/financial/ledger/chart/account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/chart_of_accounts.dart';
import 'package:mentora/core/financial/ledger/engine/ledger_engine.dart';
import 'package:mentora/core/financial/ledger/posting/builders/ledger_posting_builder.dart';
import 'package:mentora/core/financial/ledger/posting/engine/posting_engine.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_request.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_type.dart';
import 'package:mentora/core/financial/ledger/posting/templates/payment_posting_templates.dart';
import 'package:mentora/core/financial/ledger/repositories/memory_ledger_repository.dart';

void main() {
  group('PostingEngine', () {
    late MemoryLedgerRepository repository;
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;
    late LedgerEngine ledgerEngine;
    late BalanceEngine balanceEngine;
    late PaymentPostingTemplates paymentTemplates;
    late LedgerPostingBuilder postingBuilder;
    late PostingEngine postingEngine;

    setUp(() {
      repository = MemoryLedgerRepository();
      accountRegistry = AccountRegistry();

      chartOfAccounts = ChartOfAccounts(registry: accountRegistry);

      chartOfAccounts.initializeCurrency('USD');

      ledgerEngine = LedgerEngine(
        repository: repository,
        chartOfAccounts: chartOfAccounts,
      );

      balanceEngine = BalanceEngine(
        repository: repository,
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
    });

    test('should post a payment authorization end to end', () async {
      final request = _buildRequest(
        id: 'posting_authorized_001',
        referenceId: 'payment_001',
        type: PostingType.paymentAuthorized,
      );

      final transaction = await postingEngine.post(request);

      expect(transaction.id, request.id);
      expect(transaction.referenceId, 'paymentAuthorized:payment_001');
      expect(transaction.isBalanced, isTrue);
      expect(transaction.entries.length, 2);

      final platformCash = chartOfAccounts.platformCash('USD');

      final clientWallet = chartOfAccounts.ensureClientWallet(
        clientId: request.clientId,
        currency: request.currency,
      );

      final cashBalance = await balanceEngine.calculate(platformCash.id);

      final clientWalletBalance = await balanceEngine.calculate(
        clientWallet.id,
      );

      expect(cashBalance.debitMinor, 6000);
      expect(cashBalance.creditMinor, 0);
      expect(cashBalance.balanceMinor, 6000);

      expect(clientWalletBalance.debitMinor, 0);
      expect(clientWalletBalance.creditMinor, 6000);
      expect(clientWalletBalance.balanceMinor, 6000);
    });

    test('should move an authorized payment to escrow', () async {
      final authorizationRequest = _buildRequest(
        id: 'posting_authorized_001',
        referenceId: 'payment_001',
        type: PostingType.paymentAuthorized,
      );

      await postingEngine.post(authorizationRequest);

      final escrowRequest = _buildRequest(
        id: 'posting_escrow_001',
        referenceId: 'payment_001',
        type: PostingType.paymentMovedToEscrow,
      );

      final transaction = await postingEngine.post(escrowRequest);

      expect(transaction.isBalanced, isTrue);

      final clientWallet = chartOfAccounts.ensureClientWallet(
        clientId: escrowRequest.clientId,
        currency: escrowRequest.currency,
      );

      final escrow = chartOfAccounts.ensureEscrow(
        consultationId: escrowRequest.consultationId,
        currency: escrowRequest.currency,
      );

      final clientWalletBalance = await balanceEngine.calculate(
        clientWallet.id,
      );

      final escrowBalance = await balanceEngine.calculate(escrow.id);

      expect(clientWalletBalance.debitMinor, 6000);
      expect(clientWalletBalance.creditMinor, 6000);
      expect(clientWalletBalance.balanceMinor, 0);

      expect(escrowBalance.debitMinor, 0);
      expect(escrowBalance.creditMinor, 6000);
      expect(escrowBalance.balanceMinor, 6000);
    });

    test('should release escrow funds to expert wallet', () async {
      await postingEngine.post(
        _buildRequest(
          id: 'posting_authorized_001',
          referenceId: 'payment_001',
          type: PostingType.paymentAuthorized,
        ),
      );

      await postingEngine.post(
        _buildRequest(
          id: 'posting_escrow_001',
          referenceId: 'payment_001',
          type: PostingType.paymentMovedToEscrow,
        ),
      );

      final releaseRequest = _buildRequest(
        id: 'posting_release_001',
        referenceId: 'payment_001',
        type: PostingType.paymentReleased,
      );

      await postingEngine.post(releaseRequest);

      final escrow = chartOfAccounts.ensureEscrow(
        consultationId: releaseRequest.consultationId,
        currency: releaseRequest.currency,
      );

      final expertWallet = chartOfAccounts.ensureExpertWallet(
        expertId: releaseRequest.expertId,
        currency: releaseRequest.currency,
      );

      final escrowBalance = await balanceEngine.calculate(escrow.id);

      final expertWalletBalance = await balanceEngine.calculate(
        expertWallet.id,
      );

      expect(escrowBalance.debitMinor, 6000);
      expect(escrowBalance.creditMinor, 6000);
      expect(escrowBalance.balanceMinor, 0);

      expect(expertWalletBalance.debitMinor, 0);
      expect(expertWalletBalance.creditMinor, 6000);
      expect(expertWalletBalance.balanceMinor, 6000);
    });

    test(
      'should remain idempotent when posting the same request twice',
      () async {
        final request = _buildRequest(
          id: 'posting_authorized_001',
          referenceId: 'payment_001',
          type: PostingType.paymentAuthorized,
        );

        await postingEngine.post(request);
        await postingEngine.post(request);

        final platformCash = chartOfAccounts.platformCash('USD');

        final transactions = await repository.findTransactionsByAccountId(
          platformCash.id,
        );

        expect(transactions.length, 1);

        final balance = await balanceEngine.calculate(platformCash.id);

        expect(balance.balanceMinor, 6000);
      },
    );

    test('should reject the same posting id with different content', () async {
      final original = _buildRequest(
        id: 'posting_authorized_001',
        referenceId: 'payment_001',
        type: PostingType.paymentAuthorized,
        amountMinor: 6000,
      );

      final conflicting = _buildRequest(
        id: 'posting_authorized_001',
        referenceId: 'payment_001',
        type: PostingType.paymentAuthorized,
        amountMinor: 7000,
      );

      await postingEngine.post(original);

      expect(() => postingEngine.post(conflicting), throwsStateError);
    });

    test('should reject an unsupported wallet posting type', () async {
      final request = _buildRequest(
        id: 'wallet_deposit_001',
        referenceId: 'wallet_operation_001',
        type: PostingType.walletDeposit,
      );

      expect(() => postingEngine.post(request), throwsStateError);
    });

    test(
      'should reject invalid posting data before ledger persistence',
      () async {
        final request = _buildRequest(
          id: '',
          referenceId: 'payment_001',
          type: PostingType.paymentAuthorized,
        );

        expect(() => postingEngine.post(request), throwsArgumentError);

        final saved = await repository.findTransactionByReferenceId(
          'paymentAuthorized:payment_001',
        );

        expect(saved, isNull);
      },
    );
  });
}

PostingRequest _buildRequest({
  required String id,
  required String referenceId,
  required PostingType type,
  String consultationId = 'consultation_001',
  String clientId = 'client_001',
  String expertId = 'expert_001',
  int amountMinor = 6000,
  String currency = 'USD',
}) {
  return PostingRequest(
    id: id,
    referenceId: referenceId,
    type: type,
    consultationId: consultationId,
    clientId: clientId,
    expertId: expertId,
    amountMinor: amountMinor,
    currency: currency,
    createdAt: DateTime.utc(2026, 7, 10),
    metadata: const {'source': 'posting_engine_test'},
  );
}
