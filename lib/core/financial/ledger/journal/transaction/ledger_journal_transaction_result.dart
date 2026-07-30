class LedgerJournalTransactionResult {
  const LedgerJournalTransactionResult({required this.success, this.error});

  final bool success;
  final Object? error;

  bool get failed => !success;
}
