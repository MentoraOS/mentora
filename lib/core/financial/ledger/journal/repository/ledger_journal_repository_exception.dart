// Base exception raised by ledger journal repositories.
sealed class LedgerJournalRepositoryException implements Exception {
  const LedgerJournalRepositoryException(this.message);

  final String message;

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}

// Raised when a journal ID already exists.
final class DuplicateLedgerJournalIdException
    extends LedgerJournalRepositoryException {
  const DuplicateLedgerJournalIdException({required this.journalId})
    : super(
        'A ledger journal already exists with ID '
        '"$journalId".',
      );

  final String journalId;
}

// Raised when an operation has already produced a journal.
final class DuplicateLedgerOperationException
    extends LedgerJournalRepositoryException {
  const DuplicateLedgerOperationException({required this.operationId})
    : super(
        'A ledger journal already exists for operation '
        '"$operationId".',
      );

  final String operationId;
}

// Raised when attempting to update a missing journal.
final class LedgerJournalNotFoundException
    extends LedgerJournalRepositoryException {
  const LedgerJournalNotFoundException({required this.journalId})
    : super('Ledger journal "$journalId" was not found.');

  final String journalId;
}

// Raised when optimistic version validation fails.
final class LedgerJournalVersionConflictException
    extends LedgerJournalRepositoryException {
  const LedgerJournalVersionConflictException({
    required this.journalId,
    required this.expectedVersion,
    required this.actualVersion,
  }) : super(
         'Ledger journal "$journalId" version conflict: '
         'expected $expectedVersion but found $actualVersion.',
       );

  final String journalId;
  final int expectedVersion;
  final int actualVersion;
}
