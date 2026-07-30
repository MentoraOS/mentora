import '../models/ledger_journal.dart';
import '../models/ledger_journal_status.dart';
import '../repository/ledger_journal_repository.dart';
import '../repository/ledger_journal_repository_exception.dart';
import '../reversal/ledger_journal_reversal_request.dart';
import '../reversal/ledger_journal_reversal_result.dart';
import '../reversal/service/ledger_journal_reversal_service.dart';
import '../../validation/ledger_journal_validator.dart';

import 'ledger_journal_engine_exception.dart';

///Executes lifecycle operations for ledger journals.
//
// The engine owns:
// - journal creation;
// - journal posting;
// - journal cancellation;
// - accounting reversal delegation.

final class LedgerJournalEngine {
  const LedgerJournalEngine({
    required this.repository,
    required this.validator,
    required this.reversalService,
  });

  final LedgerJournalRepository repository;
  final LedgerJournalValidator validator;
  final LedgerJournalReversalService reversalService;

  Future<LedgerJournal> create(LedgerJournal journal) async {
    final existing = await repository.findByOperationId(journal.operationId);

    if (existing != null) {
      throw LedgerJournalAlreadyExistsException(
        operationId: journal.operationId,
      );
    }

    if (journal.status != LedgerJournalStatus.pending) {
      throw InvalidLedgerJournalTransitionException(
        journalId: journal.journalId,
        currentStatus: journal.status,
        targetStatus: LedgerJournalStatus.pending,
      );
    }

    try {
      await repository.create(journal);
    } on DuplicateLedgerOperationException {
      throw LedgerJournalAlreadyExistsException(
        operationId: journal.operationId,
      );
    }

    return journal;
  }

  Future<LedgerJournal> post(String journalId) async {
    final current = await _getRequired(journalId);

    _ensureTransition(
      journal: current,
      targetStatus: LedgerJournalStatus.posted,
    );

    final validation = await validator.validateForPosting(current);

    if (validation.isInvalid) {
      throw LedgerJournalValidationException(issues: validation.issues);
    }

    final posted = current.copyWith(
      status: LedgerJournalStatus.posted,
      version: current.version + 1,
    );

    await repository.update(journal: posted, expectedVersion: current.version);

    return posted;
  }

  Future<LedgerJournal> cancel(String journalId) async {
    final current = await _getRequired(journalId);

    _ensureTransition(
      journal: current,
      targetStatus: LedgerJournalStatus.cancelled,
    );

    final cancelled = current.copyWith(
      status: LedgerJournalStatus.cancelled,
      version: current.version + 1,
    );

    await repository.update(
      journal: cancelled,
      expectedVersion: current.version,
    );

    return cancelled;
  }

  Future<LedgerJournalReversalResult> reverse({
    required LedgerJournalReversalRequest request,
  }) {
    return reversalService.reverse(request: request);
  }

  Future<LedgerJournal> getRequired(String journalId) {
    return _getRequired(journalId);
  }

  Future<LedgerJournal?> findByOperationId(String operationId) {
    return repository.findByOperationId(operationId);
  }

  Future<LedgerJournal> _getRequired(String journalId) async {
    final normalizedJournalId = _normalizeRequired(journalId, 'journalId');

    final journal = await repository.findById(normalizedJournalId);

    if (journal == null) {
      throw LedgerJournalMissingException(journalId: normalizedJournalId);
    }

    return journal;
  }

  void _ensureTransition({
    required LedgerJournal journal,
    required LedgerJournalStatus targetStatus,
  }) {
    final allowed = switch (journal.status) {
      LedgerJournalStatus.pending =>
        targetStatus == LedgerJournalStatus.posted ||
            targetStatus == LedgerJournalStatus.cancelled,
      LedgerJournalStatus.posted => false,
      LedgerJournalStatus.reversed => false,
      LedgerJournalStatus.cancelled => false,
    };

    if (!allowed) {
      throw InvalidLedgerJournalTransitionException(
        journalId: journal.journalId,
        currentStatus: journal.status,
        targetStatus: targetStatus,
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
