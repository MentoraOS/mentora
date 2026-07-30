import 'ledger_engine.dart';
import 'models/ledger_entry.dart';
import 'models/ledger_transaction.dart';
import 'repository/in_memory_ledger_repository.dart';
import 'models/ledger_transaction_status.dart';
import 'models/ledger_transaction_type.dart';

Future<void> runLedgerManualTest() async {
  final repository = InMemoryLedgerRepository();
  final ledger = LedgerEngine(repository: repository);

  final transaction = LedgerTransaction(
    id: 'txn_001',
    reference: 'booking_001_payment',
    transactionType: LedgerTransactionType.payment,
    status: LedgerTransactionStatus.posted,
    bookingId: 'booking_001',
    clientId: 'client_001',
    expertId: 'expert_001',
    countryCode: 'ML',
    currency: 'XOF',
    provider: 'mock',
    createdAt: DateTime.now(),
    entries: const [
      LedgerEntry(
        accountId: 'client_wallet_001',
        type: LedgerEntryType.debit,
        amount: 15000,
      ),
      LedgerEntry(
        accountId: 'escrow_001',
        type: LedgerEntryType.credit,
        amount: 15000,
      ),
    ],
  );

  await ledger.recordTransaction(transaction);

  final clientBalance = await ledger.balanceOf('client_wallet_001');
  final escrowBalance = await ledger.balanceOf('escrow_001');

  print('Client balance: $clientBalance');
  print('Escrow balance: $escrowBalance');
}
