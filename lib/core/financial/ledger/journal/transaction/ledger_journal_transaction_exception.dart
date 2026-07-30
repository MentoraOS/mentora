class LedgerJournalTransactionException implements Exception {
  const LedgerJournalTransactionException(this.message);

  final String message;

  @override
  String toString() => message;
}
