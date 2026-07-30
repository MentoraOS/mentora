import '../../posting/models/posting_request.dart';

import '../models/ledger_journal_source.dart';

import 'ledger_journal_posting_request.dart';

// Converts a transaction posting request into a journal posting request.
//
// This factory is:
// - pure;
// - deterministic;
// - stateless;
// - free of persistence and posting side effects.
//
// It defines the official identity and traceability conventions between:
//
// PostingRequest
//      ↓
// LedgerJournalPostingRequest
final class LedgerJournalPostingRequestFactory {
  const LedgerJournalPostingRequestFactory({
    this.journalIdPrefix = 'journal',
    this.workflowKeyPrefix = 'financial.posting',
    this.sourceType = 'financial_posting',
  });

  // Prefix used to derive the journal identifier.
  //
  // Example:
  // posting_001 → journal_posting_001
  final String journalIdPrefix;

  // Prefix used to construct the workflow key.
  //
  // Example:
  // paymentReleased
  // → financial.posting.paymentReleased
  final String workflowKeyPrefix;

  // Source type recorded in [LedgerJournalSource].
  final String sourceType;

  LedgerJournalPostingRequest create(PostingRequest request) {
    final normalizedPostingId = _normalizeRequired(request.id, 'request.id');

    final normalizedReferenceId = _normalizeRequired(
      request.referenceId,
      'request.referenceId',
    );

    final normalizedConsultationId = _normalizeRequired(
      request.consultationId,
      'request.consultationId',
    );

    final normalizedClientId = _normalizeRequired(
      request.clientId,
      'request.clientId',
    );

    final normalizedExpertId = _normalizeRequired(
      request.expertId,
      'request.expertId',
    );

    final normalizedCurrency = _normalizeCurrency(request.currency);

    if (request.amountMinor <= 0) {
      throw ArgumentError.value(
        request.amountMinor,
        'request.amountMinor',
        'Posting amount must be greater than zero.',
      );
    }

    final normalizedJournalIdPrefix = _normalizeRequired(
      journalIdPrefix,
      'journalIdPrefix',
    );

    final normalizedWorkflowKeyPrefix = _normalizeRequired(
      workflowKeyPrefix,
      'workflowKeyPrefix',
    );

    final normalizedSourceType = _normalizeRequired(sourceType, 'sourceType');

    final occurredAt = request.createdAt.toUtc();

    return LedgerJournalPostingRequest(
      postingRequest: request,
      journalId: '${normalizedJournalIdPrefix}_$normalizedPostingId',
      workflowKey: '$normalizedWorkflowKeyPrefix.${request.type.name}',
      source: LedgerJournalSource(
        type: normalizedSourceType,
        id: normalizedReferenceId,
      ),
      occurredAt: occurredAt,
      createdAt: occurredAt,
      metadata: {
        ...request.metadata,
        'postingType': request.type.name,
        'postingRequestId': normalizedPostingId,
        'postingReferenceId': normalizedReferenceId,
        'consultationId': normalizedConsultationId,
        'clientId': normalizedClientId,
        'expertId': normalizedExpertId,
        'amountMinor': request.amountMinor,
        'currency': normalizedCurrency,
        'journalizedBy': 'ledger_journal_posting_request_factory',
      },
    );
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

  String _normalizeCurrency(String currency) {
    final normalized = currency.trim().toUpperCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        currency,
        'request.currency',
        'Posting currency cannot be empty.',
      );
    }

    if (normalized.length < 3) {
      throw ArgumentError.value(
        currency,
        'request.currency',
        'Posting currency must contain at least three characters.',
      );
    }

    return normalized;
  }
}
