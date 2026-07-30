import '../models/ledger_journal.dart';
import '../repository/ledger_journal_repository.dart';

import 'ledger_journal_query.dart';
import 'ledger_journal_query_result.dart';

// Read-only engine for searching and auditing ledger journals.
//
// This first implementation evaluates criteria over the repository
// contract. A future PostgreSQL adapter can translate the same query
// object into indexed SQL without changing callers.

final class LedgerJournalQueryEngine {
  const LedgerJournalQueryEngine({required this.repository});

  final LedgerJournalRepository repository;

  Future<LedgerJournalQueryResult> execute(LedgerJournalQuery query) async {
    final storedJournals = await repository.findAll();

    final matching = storedJournals
        .where((journal) => _matches(journal: journal, query: query))
        .toList(growable: true);

    _sort(journals: matching, order: query.sortOrder);

    final totalCount = matching.length;

    final paginated = _paginate(
      journals: matching,
      offset: query.offset,
      limit: query.limit,
    );

    return LedgerJournalQueryResult(
      journals: paginated,
      totalCount: totalCount,
      offset: query.offset,
      limit: query.limit,
    );
  }

  Future<LedgerJournal?> findById(String journalId) {
    return repository.findById(journalId);
  }

  Future<LedgerJournal?> findByOperationId(String operationId) {
    return repository.findByOperationId(operationId);
  }

  bool _matches({
    required LedgerJournal journal,
    required LedgerJournalQuery query,
  }) {
    if (query.journalId != null && journal.journalId != query.journalId) {
      return false;
    }

    if (query.operationId != null && journal.operationId != query.operationId) {
      return false;
    }

    if (query.workflowKey != null &&
        journal.workflowKey.toLowerCase() != query.workflowKey) {
      return false;
    }

    if (query.sourceType != null &&
        journal.source.type.toLowerCase() != query.sourceType) {
      return false;
    }

    if (query.sourceId != null &&
        journal.source.id.toLowerCase() != query.sourceId) {
      return false;
    }

    if (query.status != null && journal.status != query.status) {
      return false;
    }

    if (query.currency != null) {
      final currencies = journal.entries.map((entry) => entry.currency).toSet();

      if (!currencies.contains(query.currency)) {
        return false;
      }
    }

    if (query.accountId != null) {
      final containsAccount = journal.entries.any(
        (entry) => entry.accountId == query.accountId,
      );

      if (!containsAccount) {
        return false;
      }
    }

    if (query.occurredFrom != null &&
        journal.occurredAt.isBefore(query.occurredFrom!)) {
      return false;
    }

    if (query.occurredTo != null &&
        !journal.occurredAt.isBefore(query.occurredTo!)) {
      return false;
    }

    final amountMinor = journal.debitAmountMinor;

    if (query.minimumAmountMinor != null &&
        amountMinor < query.minimumAmountMinor!) {
      return false;
    }

    if (query.maximumAmountMinor != null &&
        amountMinor > query.maximumAmountMinor!) {
      return false;
    }

    if (query.reversalOfJournalId != null) {
      final metadataOriginalId = journal.metadata['reversalOfJournalId'];

      final matchesMetadata = metadataOriginalId == query.reversalOfJournalId;

      final matchesSource =
          journal.source.type == 'ledger_reversal' &&
          journal.source.id == query.reversalOfJournalId;

      if (!matchesMetadata && !matchesSource) {
        return false;
      }
    }

    if (query.reversalsOnly && !_isReversal(journal)) {
      return false;
    }

    return true;
  }

  bool _isReversal(LedgerJournal journal) {
    return journal.source.type == 'ledger_reversal' ||
        journal.metadata.containsKey('reversalOfJournalId');
  }

  void _sort({
    required List<LedgerJournal> journals,
    required LedgerJournalSortOrder order,
  }) {
    journals.sort((first, second) {
      final comparison = switch (order) {
        LedgerJournalSortOrder.occurredAtAscending =>
          first.occurredAt.compareTo(second.occurredAt),
        LedgerJournalSortOrder.occurredAtDescending =>
          second.occurredAt.compareTo(first.occurredAt),
        LedgerJournalSortOrder.createdAtAscending => first.createdAt.compareTo(
          second.createdAt,
        ),
        LedgerJournalSortOrder.createdAtDescending =>
          second.createdAt.compareTo(first.createdAt),
      };

      if (comparison != 0) {
        return comparison;
      }

      return first.journalId.compareTo(second.journalId);
    });
  }

  List<LedgerJournal> _paginate({
    required List<LedgerJournal> journals,
    required int offset,
    required int limit,
  }) {
    if (offset >= journals.length) {
      return const [];
    }

    final end = offset + limit > journals.length
        ? journals.length
        : offset + limit;

    return List<LedgerJournal>.unmodifiable(journals.sublist(offset, end));
  }
}
