import '../models/ledger_journal_status.dart';
import '../../validation/ledger_journal_validation_issue.dart';

sealed class LedgerJournalEngineException implements Exception {
  const LedgerJournalEngineException(this.message);

  final String message;

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}

final class LedgerJournalValidationException
    extends LedgerJournalEngineException {
  LedgerJournalValidationException({
    required List<LedgerJournalValidationIssue> issues,
  }) : issues = List.unmodifiable(issues),
       super(
         'Ledger journal validation failed with '
         '${issues.length} issue(s).',
       );

  final List<LedgerJournalValidationIssue> issues;
}

final class InvalidLedgerJournalTransitionException
    extends LedgerJournalEngineException {
  InvalidLedgerJournalTransitionException({
    required this.journalId,
    required this.currentStatus,
    required this.targetStatus,
  }) : super(
         'Ledger journal "$journalId" cannot transition '
         'from ${currentStatus.name} to ${targetStatus.name}.',
       );

  final String journalId;
  final LedgerJournalStatus currentStatus;
  final LedgerJournalStatus targetStatus;
}

final class LedgerJournalAlreadyExistsException
    extends LedgerJournalEngineException {
  const LedgerJournalAlreadyExistsException({required this.operationId})
    : super(
        'A ledger journal already exists for operation '
        '"$operationId".',
      );

  final String operationId;
}

final class LedgerJournalMissingException extends LedgerJournalEngineException {
  const LedgerJournalMissingException({required this.journalId})
    : super('Ledger journal "$journalId" was not found.');

  final String journalId;
}
