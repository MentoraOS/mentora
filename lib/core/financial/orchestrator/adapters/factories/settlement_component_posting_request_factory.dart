import '../../../ledger/posting/models/posting_request.dart';
import '../../../ledger/posting/models/posting_type.dart';

import '../../workflows/financial_posting/models/'
    'settlement_posting_category.dart';
import '../../workflows/financial_posting/models/'
    'settlement_posting_instruction.dart';
import '../../workflows/financial_posting/models/'
    'settlement_posting_line.dart';

/// Builds the deterministic PostingRequest for one settlement posting line.
///
/// This factory is shared by normal posting and recovery so both paths
/// generate identical transaction identifiers and accounting posting types.
final class SettlementComponentPostingRequestFactory {
  const SettlementComponentPostingRequestFactory();

  PostingRequest create({
    required SettlementPostingInstruction instruction,
    required SettlementPostingLine line,
  }) {
    final operationId = _normalizeRequired(
      instruction.operationId,
      'instruction.operationId',
    );

    final consultationId = _normalizeRequired(
      instruction.consultationId,
      'instruction.consultationId',
    );

    final escrowId = _normalizeRequired(
      instruction.escrowId,
      'instruction.escrowId',
    );

    final clientId = _normalizeRequired(
      instruction.clientId,
      'instruction.clientId',
    );

    final expertId = _normalizeRequired(
      instruction.expertId,
      'instruction.expertId',
    );

    final lineCode = _normalizeRequired(line.code, 'line.code');

    final lineLabel = _normalizeRequired(line.label, 'line.label');

    if (line.amount.minorUnits <= 0) {
      throw ArgumentError.value(
        line.amount.minorUnits,
        'line.amount.minorUnits',
        'Settlement posting amount must be greater than zero.',
      );
    }

    return PostingRequest(
      id: transactionIdFor(operationId: operationId, lineCode: lineCode),
      referenceId: operationId,
      type: postingTypeFor(line.category),
      consultationId: consultationId,
      clientId: clientId,
      expertId: expertId,
      amountMinor: line.amount.minorUnits,
      currency: line.amount.currency.code,
      createdAt: instruction.occurredAt.toUtc(),
      metadata: Map<String, dynamic>.unmodifiable(<String, dynamic>{
        ...instruction.metadata,
        'escrowId': escrowId,
        'settlementId': instruction.settlementId.value,
        'postingCode': lineCode,
        'postingLabel': lineLabel,
        'postingCategory': line.category.name,
        'settlementParty': line.party.name,
      }),
    );
  }

  PostingType postingTypeFor(SettlementPostingCategory category) {
    return switch (category) {
      SettlementPostingCategory.expertRevenue => PostingType.paymentReleased,

      SettlementPostingCategory.platformRevenue =>
        PostingType.platformCommission,

      SettlementPostingCategory.taxPayable => PostingType.taxPayable,

      SettlementPostingCategory.paymentProviderFee =>
        PostingType.paymentProviderFee,

      SettlementPostingCategory.affiliateCommission =>
        PostingType.affiliateCommission,

      SettlementPostingCategory.partnerCommission =>
        PostingType.partnerCommission,
    };
  }

  String transactionIdFor({
    required String operationId,
    required String lineCode,
  }) {
    final normalizedOperationId = _normalizeRequired(
      operationId,
      'operationId',
    );

    final normalizedLineCode = _normalizeRequired(
      lineCode,
      'lineCode',
    ).toLowerCase();

    return '${normalizedOperationId}_$normalizedLineCode';
  }

  String journalIdFor({required String operationId, required String lineCode}) {
    return 'journal_${transactionIdFor(operationId: operationId, lineCode: lineCode)}';
  }

  String _normalizeRequired(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must not be empty.',
      );
    }

    return normalized;
  }
}
