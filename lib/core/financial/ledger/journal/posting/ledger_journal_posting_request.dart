import '../../posting/models/posting_request.dart';

import '../models/ledger_journal_source.dart';

// Unified request used to post both:
// - the transaction ledger;
// - the journal ledger.

final class LedgerJournalPostingRequest {
  const LedgerJournalPostingRequest({
    required this.postingRequest,
    required this.journalId,
    required this.workflowKey,
    required this.source,
    this.occurredAt,
    this.createdAt,
    this.metadata = const {},
  });

  final PostingRequest postingRequest;

  final String journalId;

  final String workflowKey;

  final LedgerJournalSource source;

  final DateTime? occurredAt;

  final DateTime? createdAt;

  final Map<String, dynamic> metadata;
}
