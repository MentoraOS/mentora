import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_source.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_status.dart';

import 'package:mentora/core/financial/ledger/journal/posting/'
    'ledger_journal_posting_request.dart';

import 'package:mentora/core/financial/ledger/posting/models/'
    'posting_request.dart';

import 'package:mentora/core/financial/ledger/posting/models/'
    'posting_type.dart';

import 'package:mentora/core/phoenix/bootstrap/'
    'phoenix_bootstrap.dart';

void main() {
  group('Phoenix financial journal reporting integration', () {
    setUp(() async {
      PhoenixBootstrap.reset();
      await PhoenixBootstrap.initialize();
    });

    tearDown(() {
      PhoenixBootstrap.reset();
    });

    test(
      'a journal posted by the bridge is immediately visible to reporting',
      () async {
        const transactionId = 'integration_posting_001';

        const journalId = 'journal_integration_posting_001';

        const accountCurrency = 'XOF';

        final result = await PhoenixBootstrap.journalPostingBridge.post(
          request: LedgerJournalPostingRequest(
            postingRequest: PostingRequest(
              id: transactionId,
              referenceId: 'consultation_integration_001',
              type: PostingType.paymentAuthorized,
              consultationId: 'consultation_integration_001',
              clientId: 'client_integration_001',
              expertId: 'expert_integration_001',
              amountMinor: 10000,
              currency: accountCurrency,
              createdAt: DateTime.utc(2026, 7, 15, 10),
              metadata: const {
                'test': 'phoenix_financial_journal_reporting_integration',
              },
            ),
            journalId: journalId,
            workflowKey: 'integration.financial.posting',
            source: LedgerJournalSource(
              type: 'integration_test',
              id: 'consultation_integration_001',
            ),
            occurredAt: DateTime.utc(2026, 7, 15, 10),
            createdAt: DateTime.utc(2026, 7, 15, 10),
            metadata: const {'integration': true},
          ),
        );

        expect(result.transaction.id, transactionId);

        expect(result.journal.journalId, journalId);

        expect(result.journal.status, LedgerJournalStatus.posted);

        final storedJournal = await PhoenixBootstrap.journalRepository.findById(
          journalId,
        );

        expect(storedJournal, isNotNull);

        expect(storedJournal, result.journal);

        final summary = await PhoenixBootstrap.ledgerJournalReportingEngine
            .summary(currency: accountCurrency);

        expect(summary.totalJournals, 1);

        expect(summary.postedJournals, 1);

        expect(summary.pendingJournals, 0);

        expect(summary.cancelledJournals, 0);

        expect(summary.reversedJournals, 0);
      },
    );

    test(
      'posting and reporting use the same journal repository instance',
      () async {
        final moduleRepository =
            PhoenixBootstrap.financialModule.reportingEngine.repository;

        expect(
          identical(moduleRepository, PhoenixBootstrap.journalRepository),
          isTrue,
        );

        expect(
          identical(
            PhoenixBootstrap.ledgerTrialBalanceEngine.repository,
            PhoenixBootstrap.journalRepository,
          ),
          isTrue,
        );

        expect(
          identical(
            PhoenixBootstrap.ledgerGeneralLedgerEngine.repository,
            PhoenixBootstrap.journalRepository,
          ),
          isTrue,
        );

        expect(
          identical(
            PhoenixBootstrap.journalEngine.repository,
            PhoenixBootstrap.journalRepository,
          ),
          isTrue,
        );
      },
    );
  });
}
