import '../models/ledger_journal.dart';
import '../models/ledger_journal_status.dart';

import 'ledger_journal_repository.dart';
import 'ledger_journal_repository_exception.dart';

/// In-memory implementation of [LedgerJournalRepository].
///
/// Intended for:
/// - automated tests;
/// - local development;
/// - bootstrap scenarios.
///
/// Transactions are implemented with copy-on-write:
/// changes are applied to a staged repository and committed only if
/// the whole action completes successfully.
final class MemoryLedgerJournalRepository implements LedgerJournalRepository {
  MemoryLedgerJournalRepository()
    : _journalsById = <String, LedgerJournal>{},
      _journalIdByOperationId = <String, String>{};

  MemoryLedgerJournalRepository._({
    required Map<String, LedgerJournal> journalsById,
    required Map<String, String> journalIdByOperationId,
  }) : _journalsById = journalsById,
       _journalIdByOperationId = journalIdByOperationId;

  final Map<String, LedgerJournal> _journalsById;

  final Map<String, String> _journalIdByOperationId;

  @override
  Future<void> create(LedgerJournal journal) async {
    final journalId = journal.journalId;
    final operationId = journal.operationId;

    if (_journalsById.containsKey(journalId)) {
      throw DuplicateLedgerJournalIdException(journalId: journalId);
    }

    if (_journalIdByOperationId.containsKey(operationId)) {
      throw DuplicateLedgerOperationException(operationId: operationId);
    }

    _journalsById[journalId] = journal;
    _journalIdByOperationId[operationId] = journalId;
  }

  @override
  Future<void> update({
    required LedgerJournal journal,
    required int expectedVersion,
  }) async {
    final current = _journalsById[journal.journalId];

    if (current == null) {
      throw LedgerJournalNotFoundException(journalId: journal.journalId);
    }

    if (current.version != expectedVersion) {
      throw LedgerJournalVersionConflictException(
        journalId: journal.journalId,
        expectedVersion: expectedVersion,
        actualVersion: current.version,
      );
    }

    if (journal.operationId != current.operationId) {
      throw ArgumentError('Ledger journal operationId cannot be changed.');
    }

    if (journal.journalId != current.journalId) {
      throw ArgumentError('Ledger journal ID cannot be changed.');
    }

    if (journal.version <= current.version) {
      throw ArgumentError.value(
        journal.version,
        'journal.version',
        'Updated journal version must be greater '
            'than the stored version.',
      );
    }

    _journalsById[journal.journalId] = journal;
  }

  @override
  Future<LedgerJournal?> findById(String journalId) async {
    final normalizedJournalId = _normalizeRequired(journalId, 'journalId');

    return _journalsById[normalizedJournalId];
  }

  @override
  Future<LedgerJournal?> findByOperationId(String operationId) async {
    final normalizedOperationId = _normalizeRequired(
      operationId,
      'operationId',
    );

    final journalId = _journalIdByOperationId[normalizedOperationId];

    if (journalId == null) {
      return null;
    }

    return _journalsById[journalId];
  }

  @override
  Future<List<LedgerJournal>> findAll() async {
    return _sorted(_journalsById.values);
  }

  @override
  Future<List<LedgerJournal>> findByStatus(LedgerJournalStatus status) async {
    return _sorted(
      _journalsById.values.where((journal) => journal.status == status),
    );
  }

  @override
  Future<List<LedgerJournal>> findByWorkflowKey(String workflowKey) async {
    final normalizedWorkflowKey = _normalizeRequired(
      workflowKey,
      'workflowKey',
    );

    return _sorted(
      _journalsById.values.where(
        (journal) => journal.workflowKey == normalizedWorkflowKey,
      ),
    );
  }

  @override
  Future<List<LedgerJournal>> findBySource({
    required String sourceType,
    required String sourceId,
  }) async {
    final normalizedSourceType = _normalizeRequired(
      sourceType,
      'sourceType',
    ).toLowerCase();

    final normalizedSourceId = _normalizeRequired(
      sourceId,
      'sourceId',
    ).toLowerCase();

    return _sorted(
      _journalsById.values.where(
        (journal) =>
            journal.source.type == normalizedSourceType &&
            journal.source.id == normalizedSourceId,
      ),
    );
  }

  @override
  Future<List<LedgerJournal>> findOccurredBetween({
    required DateTime from,
    required DateTime to,
  }) async {
    final normalizedFrom = from.toUtc();
    final normalizedTo = to.toUtc();

    if (!normalizedFrom.isBefore(normalizedTo)) {
      throw ArgumentError(
        'The journal query start time must be '
        'before the end time.',
      );
    }

    return _sorted(
      _journalsById.values.where((journal) {
        final occurredAt = journal.occurredAt;

        final isOnOrAfterFrom =
            occurredAt.isAtSameMomentAs(normalizedFrom) ||
            occurredAt.isAfter(normalizedFrom);

        final isBeforeTo = occurredAt.isBefore(normalizedTo);

        return isOnOrAfterFrom && isBeforeTo;
      }),
    );
  }

  @override
  Future<bool> existsByOperationId(String operationId) async {
    final normalizedOperationId = _normalizeRequired(
      operationId,
      'operationId',
    );

    return _journalIdByOperationId.containsKey(normalizedOperationId);
  }

  @override
  Future<int> count() async {
    return _journalsById.length;
  }

  @override
  Future<T> runInTransaction<T>(
    Future<T> Function(LedgerJournalRepository repository) action,
  ) async {
    final stagedRepository = MemoryLedgerJournalRepository._(
      journalsById: Map<String, LedgerJournal>.of(_journalsById),
      journalIdByOperationId: Map<String, String>.of(_journalIdByOperationId),
    );

    final result = await action(stagedRepository);

    _journalsById
      ..clear()
      ..addAll(stagedRepository._journalsById);

    _journalIdByOperationId
      ..clear()
      ..addAll(stagedRepository._journalIdByOperationId);

    return result;
  }

  /// Clears all in-memory journals.
  ///
  /// Intended only for tests and local development.
  void clear() {
    _journalsById.clear();
    _journalIdByOperationId.clear();
  }

  List<LedgerJournal> _sorted(Iterable<LedgerJournal> journals) {
    final result = journals.toList(growable: true)
      ..sort((first, second) {
        final occurredComparison = first.occurredAt.compareTo(
          second.occurredAt,
        );

        if (occurredComparison != 0) {
          return occurredComparison;
        }

        return first.journalId.compareTo(second.journalId);
      });

    return List<LedgerJournal>.unmodifiable(result);
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
