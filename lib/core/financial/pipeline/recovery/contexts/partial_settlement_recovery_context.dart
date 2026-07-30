import '../../../splits/models/settlement_split.dart';
import '../../financial_pipeline_context.dart';

/// Recovery context for a settlement whose accounting components may have
/// been only partially posted.
///
/// A consultation settlement can produce several deterministic postings:
///
/// - expert payment;
/// - platform commission;
/// - tax payable;
/// - payment-provider fee.
///
/// This context contains the original immutable settlement intention.
/// The recovery strategy derives every expected transaction identifier from:
///
/// operationId + split component code
///
/// It therefore does not accept arbitrary transaction identifiers and cannot
/// accidentally recover unrelated Ledger transactions.
final class PartialSettlementRecoveryContext extends FinancialPipelineContext {
  PartialSettlementRecoveryContext({
    required String operationId,
    required String consultationId,
    required String escrowId,
    required String clientId,
    required String expertId,
    required this.split,
    required DateTime occurredAt,
    Map<String, dynamic> metadata = const {},
  }) : operationId = _normalizeRequired(operationId, 'operationId'),
       consultationId = _normalizeRequired(consultationId, 'consultationId'),
       escrowId = _normalizeRequired(escrowId, 'escrowId'),
       clientId = _normalizeRequired(clientId, 'clientId'),
       expertId = _normalizeRequired(expertId, 'expertId'),
       occurredAt = occurredAt.toUtc(),
       metadata = Map.unmodifiable(Map<String, dynamic>.from(metadata)) {
    _validateSplit(split);
  }

  /// Unique identifier of the complete settlement operation.
  ///
  /// Every expected component transaction derives its identifier from this
  /// value.
  final String operationId;

  final String consultationId;

  final String escrowId;

  final String clientId;

  final String expertId;

  /// Original settlement allocation that must be fully represented in the
  /// Ledger.
  final SettlementSplit split;

  /// Business time of the original settlement.
  final DateTime occurredAt;

  /// Immutable audit and business metadata.
  final Map<String, dynamic> metadata;

  String get currency => split.currency.trim().toUpperCase();

  int get totalMinor => split.totalMinor;

  int get componentCount => split.components.length;

  /// Returns the deterministic Ledger transaction identifier for a split
  /// component.
  ///
  /// This must remain aligned with SettlementPostingAdapter.
  String transactionIdForComponentCode(String componentCode) {
    final normalizedCode = _normalizeRequired(
      componentCode,
      'componentCode',
    ).toLowerCase();

    return '${operationId}_$normalizedCode';
  }

  /// Deterministic transaction identifiers expected for the full settlement.
  List<String> get expectedTransactionIds {
    final identifiers = split.components
        .map((component) => transactionIdForComponentCode(component.code))
        .toList(growable: false);

    return List.unmodifiable(identifiers);
  }

  /// Number of distinct posting components expected by the settlement.
  bool get hasComponents => split.components.isNotEmpty;

  PartialSettlementRecoveryContext copyWith({
    String? operationId,
    String? consultationId,
    String? escrowId,
    String? clientId,
    String? expertId,
    SettlementSplit? split,
    DateTime? occurredAt,
    Map<String, dynamic>? metadata,
  }) {
    return PartialSettlementRecoveryContext(
      operationId: operationId ?? this.operationId,
      consultationId: consultationId ?? this.consultationId,
      escrowId: escrowId ?? this.escrowId,
      clientId: clientId ?? this.clientId,
      expertId: expertId ?? this.expertId,
      split: split ?? this.split,
      occurredAt: occurredAt ?? this.occurredAt,
      metadata: metadata ?? this.metadata,
    );
  }

  static void _validateSplit(SettlementSplit split) {
    if (!split.isBalanced) {
      throw ArgumentError(
        'Partial settlement recovery requires a balanced split.',
      );
    }

    if (split.currency.trim().isEmpty) {
      throw ArgumentError.value(
        split.currency,
        'split.currency',
        'Settlement split currency must not be empty.',
      );
    }

    if (split.components.isEmpty) {
      throw ArgumentError(
        'Partial settlement recovery requires at least one '
        'split component.',
      );
    }

    final componentCodes = <String>{};

    for (final component in split.components) {
      final normalizedCode = component.code.trim().toLowerCase();

      if (normalizedCode.isEmpty) {
        throw ArgumentError.value(
          component.code,
          'split.components.code',
          'Settlement split component code must not be empty.',
        );
      }

      if (!componentCodes.add(normalizedCode)) {
        throw StateError(
          'Settlement split contains duplicate component code '
          '"$normalizedCode".',
        );
      }

      if (component.amountMinor <= 0) {
        throw ArgumentError.value(
          component.amountMinor,
          'split.components.amountMinor',
          'Settlement split component amount must be greater '
              'than zero.',
        );
      }
    }
  }

  static String _normalizeRequired(String value, String fieldName) {
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

  @override
  String toString() {
    return 'PartialSettlementRecoveryContext('
        'operationId: $operationId, '
        'consultationId: $consultationId, '
        'currency: $currency, '
        'totalMinor: $totalMinor, '
        'componentCount: $componentCount'
        ')';
  }
}
