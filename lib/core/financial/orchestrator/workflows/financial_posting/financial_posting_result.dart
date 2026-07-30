class FinancialPostingResult {
  final bool success;

  final String operationId;
  final String consultationId;

  final List<String> ledgerTransactionIds;

  final DateTime postedAt;

  const FinancialPostingResult({
    required this.success,
    required this.operationId,
    required this.consultationId,
    required this.ledgerTransactionIds,
    required this.postedAt,
  });

  String get primaryLedgerTransactionId {
    if (ledgerTransactionIds.isEmpty) {
      throw StateError(
        'Financial posting result contains no ledger transaction',
      );
    }

    return ledgerTransactionIds.first;
  }
}
