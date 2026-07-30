class LedgerJournalTransactionContext {
  const LedgerJournalTransactionContext({
    required this.operationId,
    required this.description,
  });

  final String operationId;
  final String description;
}
