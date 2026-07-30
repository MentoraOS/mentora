import '../ledger/financial_ledger_factory.dart';
import '../ledger/models/ledger_entry.dart';
import '../ledger/models/ledger_transaction.dart';
import '../ledger/models/ledger_transaction_status.dart';
import '../ledger/models/ledger_transaction_type.dart';
import 'withdrawal_engine.dart';
import 'withdrawal_status.dart';

class WithdrawalProcessor {
  WithdrawalProcessor._();

  static Future<void> approve({required String requestId}) async {
    final engine = WithdrawalEngine.firestore();
    final request = await engine.findWithdrawal(requestId);

    if (request == null) {
      throw Exception('Withdrawal request not found');
    }

    if (request.status != WithdrawalStatus.pending) {
      throw Exception('Withdrawal request already processed');
    }

    final ledger = FinancialLedgerFactory.firestore();

    await ledger.recordTransaction(
      LedgerTransaction(
        id: 'ledger_withdrawal_$requestId',
        reference: requestId,
        transactionType: LedgerTransactionType.payout,
        status: LedgerTransactionStatus.posted,
        expertId: request.expertId,
        countryCode: request.countryCode,
        currency: request.currency,
        provider: request.method,
        createdAt: DateTime.now(),
        entries: [
          LedgerEntry(
            accountId: 'expert_wallet_${request.expertId}',
            type: LedgerEntryType.debit,
            amount: request.amount,
          ),
          LedgerEntry(
            accountId: 'external_provider_${request.method}',
            type: LedgerEntryType.credit,
            amount: request.amount,
          ),
        ],
        metadata: {
          'withdrawalRequestId': requestId,
          'method': request.method,
          'destination': request.destination,
        },
      ),
    );

    await engine.updateWithdrawalStatus(
      id: requestId,
      status: WithdrawalStatus.approved,
    );
  }

  static Future<void> reject({required String requestId}) async {
    final engine = WithdrawalEngine.firestore();

    await engine.updateWithdrawalStatus(
      id: requestId,
      status: WithdrawalStatus.rejected,
    );
  }
}
