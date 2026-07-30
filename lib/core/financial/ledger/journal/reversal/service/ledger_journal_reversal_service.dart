import '../../models/ledger_journal.dart';
import '../../models/ledger_journal_status.dart';
import '../../repository/ledger_journal_repository.dart';

import '../../../validation/ledger_journal_validation_issue.dart';
import '../../../validation/ledger_journal_validator.dart';

import '../ledger_journal_reversal_builder.dart';
import '../ledger_journal_reversal_request.dart';
import '../ledger_journal_reversal_result.dart';

// Coordinates the complete accounting reversal of a posted journal.
//
// The service:
// 1. loads the original journal;
// 2. builds a compensating journal;
// 3. stores the compensating journal;
// 4. validates it;
// 5. posts it;
// 6. marks the original journal as reversed;
// 7. returns both final journals.
//
// This service does not generate identifiers or timestamps. Those values
// are supplied through [LedgerJournalReversalRequest], which keeps the
// operation deterministic and testable.
final class LedgerJournalReversalService {
  const LedgerJournalReversalService({
    required this.repository,
    required this.validator,
    required this.builder,
  });

  final LedgerJournalRepository repository;
  final LedgerJournalValidator validator;
  final LedgerJournalReversalBuilder builder;

  Future<LedgerJournalReversalResult> reverse({
    required LedgerJournalReversalRequest request,
  }) {
    return repository.runInTransaction((transactionalRepository) async {
      final original = await _loadOriginalJournal(
        request.originalJournalId,
        repository: transactionalRepository,
      );

      _validateOriginalState(original);

      final builtResult = builder.build(original: original, request: request);

      final pendingReversal = builtResult.reversalJournal;

      await _ensureReversalDoesNotAlreadyExist(
        pendingReversal,
        repository: transactionalRepository,
      );

      await transactionalRepository.create(pendingReversal);

      final transactionalValidator = LedgerJournalValidator(
        chartOfAccounts: validator.chartOfAccounts,
        repository: transactionalRepository,
      );

      final validationResult = await transactionalValidator.validateForPosting(
        pendingReversal,
      );

      if (validationResult.isInvalid) {
        throw LedgerJournalReversalValidationException(
          reversalJournalId: pendingReversal.journalId,
          issues: validationResult.issues,
        );
      }

      final postedReversal = pendingReversal.copyWith(
        status: LedgerJournalStatus.posted,
        version: pendingReversal.version + 1,
        metadata: {
          ...pendingReversal.metadata,
          'postedBy': 'ledger_journal_reversal_service',
        },
      );

      await transactionalRepository.update(
        journal: postedReversal,
        expectedVersion: pendingReversal.version,
      );

      final reversedOriginal = original.copyWith(
        status: LedgerJournalStatus.reversed,
        version: original.version + 1,
        metadata: {
          ...original.metadata,
          'reversalJournalId': postedReversal.journalId,
          'reversalOperationId': postedReversal.operationId,
          'reversalReason': request.reason,
          'reversedAt': request.occurredAt.toIso8601String(),
        },
      );

      await transactionalRepository.update(
        journal: reversedOriginal,
        expectedVersion: original.version,
      );

      return LedgerJournalReversalResult(
        originalJournal: reversedOriginal,
        reversalJournal: postedReversal,
      );
    });
  }

  Future<LedgerJournal> _loadOriginalJournal(
    String journalId, {
    required LedgerJournalRepository repository,
  }) async {
    final normalizedJournalId = _normalizeRequired(journalId, 'journalId');

    final journal = await repository.findById(normalizedJournalId);

    if (journal == null) {
      throw LedgerJournalReversalOriginalNotFoundException(
        journalId: normalizedJournalId,
      );
    }

    return journal;
  }

  void _validateOriginalState(LedgerJournal original) {
    if (original.status != LedgerJournalStatus.posted) {
      throw LedgerJournalReversalInvalidStateException(
        journalId: original.journalId,
        actualStatus: original.status,
      );
    }

    if (!original.isBalanced) {
      throw LedgerJournalReversalInvalidOriginalException(
        journalId: original.journalId,
        reason: 'The original journal is not balanced.',
      );
    }

    if (original.containsMultipleCurrencies) {
      throw LedgerJournalReversalInvalidOriginalException(
        journalId: original.journalId,
        reason: 'The original journal contains multiple currencies.',
      );
    }
  }

  Future<void> _ensureReversalDoesNotAlreadyExist(
    LedgerJournal reversal, {
    required LedgerJournalRepository repository,
  }) async {
    final journalWithSameId = await repository.findById(reversal.journalId);

    if (journalWithSameId != null) {
      throw LedgerJournalReversalAlreadyExistsException(
        reversalJournalId: reversal.journalId,
        reversalOperationId: reversal.operationId,
      );
    }

    final journalWithSameOperation = await repository.findByOperationId(
      reversal.operationId,
    );

    if (journalWithSameOperation != null) {
      throw LedgerJournalReversalAlreadyExistsException(
        reversalJournalId: journalWithSameOperation.journalId,
        reversalOperationId: reversal.operationId,
      );
    }
  }

  String _normalizeRequired(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName cannot be empty.',
      );
    }

    return normalized;
  }
}

// Base exception raised by the reversal service.
sealed class LedgerJournalReversalServiceException implements Exception {
  const LedgerJournalReversalServiceException(this.message);

  final String message;

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}

// Raised when the original journal cannot be found.
final class LedgerJournalReversalOriginalNotFoundException
    extends LedgerJournalReversalServiceException {
  const LedgerJournalReversalOriginalNotFoundException({
    required this.journalId,
  }) : super(
         'Original ledger journal '
         '"$journalId" was not found.',
       );

  final String journalId;
}

// Raised when the original journal is not posted.
final class LedgerJournalReversalInvalidStateException
    extends LedgerJournalReversalServiceException {
  LedgerJournalReversalInvalidStateException({
    required this.journalId,
    required this.actualStatus,
  }) : super(
         'Ledger journal "$journalId" cannot be '
         'reversed from status '
         '"${actualStatus.name}". Only a posted '
         'journal can be reversed.',
       );

  final String journalId;
  final LedgerJournalStatus actualStatus;
}

// Raised when the original journal violates accounting invariants.
final class LedgerJournalReversalInvalidOriginalException
    extends LedgerJournalReversalServiceException {
  const LedgerJournalReversalInvalidOriginalException({
    required this.journalId,
    required this.reason,
  }) : super(
         'Ledger journal "$journalId" cannot be '
         'reversed: $reason',
       );

  final String journalId;
  final String reason;
}

// Raised when the reversal journal or operation already exists.
final class LedgerJournalReversalAlreadyExistsException
    extends LedgerJournalReversalServiceException {
  const LedgerJournalReversalAlreadyExistsException({
    required this.reversalJournalId,
    required this.reversalOperationId,
  }) : super(
         'A reversal already exists with journal ID '
         '"$reversalJournalId" or operation ID '
         '"$reversalOperationId".',
       );

  final String reversalJournalId;
  final String reversalOperationId;
}

// Raised when the compensating journal fails posting validation.
final class LedgerJournalReversalValidationException
    extends LedgerJournalReversalServiceException {
  LedgerJournalReversalValidationException({
    required this.reversalJournalId,
    required List<LedgerJournalValidationIssue> issues,
  }) : issues = List<LedgerJournalValidationIssue>.unmodifiable(issues),
       super(
         'Reversal journal "$reversalJournalId" '
         'failed validation with '
         '${issues.length} issue(s).',
       );

  final String reversalJournalId;
  final List<LedgerJournalValidationIssue> issues;
}

// Raised when the reversal journal was posted but the original journal
// could not be marked as reversed.
//
// This exception represents a partial commit and must be handled by a
// recovery mechanism until the repository supports atomic transactions.
final class LedgerJournalReversalCommitException
    extends LedgerJournalReversalServiceException {
  LedgerJournalReversalCommitException({
    required this.originalJournalId,
    required this.reversalJournalId,
    required this.cause,
    required this.stackTrace,
  }) : super(
         'Reversal journal "$reversalJournalId" was '
         'posted, but original journal '
         '"$originalJournalId" could not be marked '
         'as reversed.',
       );

  final String originalJournalId;
  final String reversalJournalId;
  final Object cause;
  final StackTrace stackTrace;
}
