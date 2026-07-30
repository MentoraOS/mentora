import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/escrow/domains/escrow_domain.dart';
import 'package:mentora/core/escrow/engine/escrow_engine.dart';
import 'package:mentora/core/escrow/models/escrow.dart';
import 'package:mentora/core/escrow/models/escrow_status.dart';
import 'package:mentora/core/escrow/repositories/memory_escrow_repository.dart';

import 'package:mentora/core/financial/ledger/balance/balance_engine.dart';
import 'package:mentora/core/financial/ledger/chart/account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/chart_of_accounts.dart';
import 'package:mentora/core/financial/ledger/engine/ledger_engine.dart';
import 'package:mentora/core/financial/ledger/posting/builders/ledger_posting_builder.dart';
import 'package:mentora/core/financial/ledger/posting/engine/posting_engine.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_request.dart';
import 'package:mentora/core/financial/ledger/posting/models/posting_type.dart';
import 'package:mentora/core/financial/ledger/posting/services/escrow_posting_service.dart';
import 'package:mentora/core/financial/ledger/posting/templates/payment_posting_templates.dart';
import 'package:mentora/core/financial/ledger/repositories/memory_ledger_repository.dart';

void main() {
  group('EscrowEngine posting integration', () {
    late MemoryEscrowRepository escrowRepository;
    late EscrowDomain escrowDomain;

    late MemoryLedgerRepository ledgerRepository;
    late AccountRegistry accountRegistry;
    late ChartOfAccounts chartOfAccounts;
    late LedgerEngine ledgerEngine;
    late BalanceEngine balanceEngine;
    late PaymentPostingTemplates paymentTemplates;
    late LedgerPostingBuilder postingBuilder;
    late PostingEngine postingEngine;
    late EscrowPostingService escrowPostingService;

    late EscrowEngine escrowEngine;

    setUp(() {
      // Escrow infrastructure
      escrowRepository = MemoryEscrowRepository();

      escrowDomain = EscrowDomain(repository: escrowRepository);

      // Financial infrastructure
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

      escrowEngine = EscrowEngine(
        domain: escrowDomain,
        postingService: escrowPostingService,
      );
    });

    test(
      'should post ledger entries only after a successful lock transition',
      () async {
        final escrow = _buildEscrow();

        final createResult = await escrowEngine.create(escrow);

        expect(createResult.success, isTrue);
        expect(createResult.escrow, isNotNull);
        expect(createResult.escrow!.status, EscrowStatus.pending);

        // Le paiement autorisé crédite d’abord le wallet client.
        await postingEngine.post(
          _buildAuthorizationRequest(escrow: escrow, amountMinor: 6000),
        );

        final lockResult = await escrowEngine.lock(
          createResult.escrow!,
          amountMinor: 6000,
          occurredAt: DateTime.utc(2026, 7, 11, 10),
        );

        expect(lockResult.success, isTrue);
        expect(lockResult.escrow, isNotNull);
        expect(lockResult.escrow!.status, EscrowStatus.locked);

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

        final posting = await ledgerRepository.findTransactionById(
          'escrow_${escrow.id}_locked',
        );

        expect(posting, isNotNull);
        expect(posting!.isBalanced, isTrue);
      },
    );

    test('should release locked escrow funds to expert wallet', () async {
      final escrow = _buildEscrow();

      final createResult = await escrowEngine.create(escrow);

      await postingEngine.post(
        _buildAuthorizationRequest(escrow: escrow, amountMinor: 6000),
      );

      final lockResult = await escrowEngine.lock(
        createResult.escrow!,
        amountMinor: 6000,
        occurredAt: DateTime.utc(2026, 7, 11, 10),
      );

      expect(lockResult.success, isTrue);

      final releaseResult = await escrowEngine.release(
        lockResult.escrow!,
        amountMinor: 6000,
        occurredAt: DateTime.utc(2026, 7, 11, 11),
      );

      expect(releaseResult.success, isTrue);
      expect(releaseResult.escrow, isNotNull);
      expect(releaseResult.escrow!.status, EscrowStatus.released);

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

      final releasePosting = await ledgerRepository.findTransactionById(
        'escrow_${escrow.id}_released',
      );

      expect(releasePosting, isNotNull);
      expect(releasePosting!.isBalanced, isTrue);
    });

    test('should refund locked escrow funds to client wallet', () async {
      final escrow = _buildEscrow();

      final createResult = await escrowEngine.create(escrow);

      await postingEngine.post(
        _buildAuthorizationRequest(escrow: escrow, amountMinor: 6000),
      );

      final lockResult = await escrowEngine.lock(
        createResult.escrow!,
        amountMinor: 6000,
        occurredAt: DateTime.utc(2026, 7, 11, 10),
      );

      final refundResult = await escrowEngine.refund(
        lockResult.escrow!,
        amountMinor: 6000,
        occurredAt: DateTime.utc(2026, 7, 11, 11),
      );

      expect(refundResult.success, isTrue);
      expect(refundResult.escrow, isNotNull);
      expect(refundResult.escrow!.status, EscrowStatus.refunded);

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

      final refundPosting = await ledgerRepository.findTransactionById(
        'escrow_${escrow.id}_refunded',
      );

      expect(refundPosting, isNotNull);
      expect(refundPosting!.isBalanced, isTrue);
    });

    test(
      'should not create posting when escrow transition is invalid',
      () async {
        final escrow = _buildEscrow();

        final createResult = await escrowEngine.create(escrow);

        expect(createResult.success, isTrue);

        // pending → released est interdit par EscrowStateMachine.
        final releaseResult = await escrowEngine.release(
          createResult.escrow!,
          amountMinor: 6000,
          occurredAt: DateTime.utc(2026, 7, 11, 11),
        );

        expect(releaseResult.success, isFalse);

        final releasePosting = await ledgerRepository.findTransactionById(
          'escrow_${escrow.id}_released',
        );

        expect(releasePosting, isNull);

        final expertWallet = chartOfAccounts.ensureExpertWallet(
          expertId: escrow.receiverId,
          currency: escrow.currency,
        );

        final expertBalance = await balanceEngine.calculate(expertWallet.id);

        expect(expertBalance.balanceMinor, 0);
      },
    );

    test(
      'should cancel pending escrow without creating ledger posting',
      () async {
        final escrow = _buildEscrow();

        final createResult = await escrowEngine.create(escrow);

        final cancelResult = await escrowEngine.cancel(
          createResult.escrow!,
          occurredAt: DateTime.utc(2026, 7, 11, 10),
        );

        expect(cancelResult.success, isTrue);
        expect(cancelResult.escrow, isNotNull);
        expect(cancelResult.escrow!.status, EscrowStatus.cancelled);

        final cancelPosting = await ledgerRepository.findTransactionById(
          'escrow_${escrow.id}_cancelled',
        );

        expect(cancelPosting, isNull);
      },
    );
  });
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
    status: EscrowStatus.pending,
  );
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
    metadata: const {'source': 'escrow_engine_posting_test'},
  );
}
