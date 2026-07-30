class SettlementPostingReceipt {
  final String operationId;
  final List<String> ledgerTransactionIds;

  const SettlementPostingReceipt({
    required this.operationId,
    required this.ledgerTransactionIds,
  });

  bool get isComplete => ledgerTransactionIds.isNotEmpty;

  String get primaryLedgerTransactionId {
    if (ledgerTransactionIds.isEmpty) {
      throw StateError(
        'Settlement posting receipt contains no ledger transaction',
      );
    }

    return ledgerTransactionIds.first;
  }
}
