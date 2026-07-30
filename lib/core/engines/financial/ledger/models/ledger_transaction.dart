import 'ledger_entry.dart';
import 'ledger_transaction_status.dart';
import 'ledger_transaction_type.dart';

class LedgerTransaction {
  final String id;
  final String reference;

  final LedgerTransactionType transactionType;
  final LedgerTransactionStatus status;

  final String? bookingId;
  final String? consultationId;
  final String? clientId;
  final String? expertId;

  final String countryCode;
  final String currency;
  final String? provider;

  final DateTime createdAt;
  final List<LedgerEntry> entries;

  final Map<String, dynamic>? metadata;

  const LedgerTransaction({
    required this.id,
    required this.reference,
    required this.transactionType,
    required this.status,
    required this.countryCode,
    required this.currency,
    required this.createdAt,
    required this.entries,
    this.bookingId,
    this.consultationId,
    this.clientId,
    this.expertId,
    this.provider,
    this.metadata,
  });
}
