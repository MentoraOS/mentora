import '../../../../domain/settlement/settlement_id.dart';
import '../../../../domain/shared/money/financial_currency.dart';
import '../../../../domain/shared/money/money.dart';

import 'settlement_posting_line.dart';

/// Represents the complete technical instruction sent toward the Ledger.
///
/// This model is built from a validated ConsultationSettlement and enriches
/// it with the orchestration metadata required for accounting posting.
final class SettlementPostingInstruction {
  SettlementPostingInstruction({
    required this.settlementId,
    required String operationId,
    required String consultationId,
    required String escrowId,
    required String clientId,
    required String expertId,
    required List<SettlementPostingLine> lines,
    required this.occurredAt,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) : operationId = _normalizeRequired(
         value: operationId,
         fieldName: 'operationId',
       ),
       consultationId = _normalizeRequired(
         value: consultationId,
         fieldName: 'consultationId',
       ),
       escrowId = _normalizeRequired(value: escrowId, fieldName: 'escrowId'),
       clientId = _normalizeRequired(value: clientId, fieldName: 'clientId'),
       expertId = _normalizeRequired(value: expertId, fieldName: 'expertId'),
       lines = List<SettlementPostingLine>.unmodifiable(lines),
       metadata = Map<String, Object?>.unmodifiable(metadata) {
    if (this.lines.isEmpty) {
      throw ArgumentError.value(
        lines,
        'lines',
        'A settlement posting instruction must contain at least one line.',
      );
    }

    _validateCurrencies(this.lines);
  }

  final SettlementId settlementId;

  final String operationId;

  final String consultationId;

  final String escrowId;

  final String clientId;

  final String expertId;

  final List<SettlementPostingLine> lines;

  final DateTime occurredAt;

  final Map<String, Object?> metadata;

  int get lineCount => lines.length;

  bool get isEmpty => lines.isEmpty;

  bool get isNotEmpty => lines.isNotEmpty;

  FinancialCurrency get currency => lines.first.amount.currency;

  int get totalMinorUnits {
    return lines.fold<int>(0, (total, line) => total + line.amount.minorUnits);
  }

  Money get total {
    return Money(minorUnits: totalMinorUnits, currency: currency);
  }

  SettlementPostingInstruction copyWith({
    SettlementId? settlementId,
    String? operationId,
    String? consultationId,
    String? escrowId,
    String? clientId,
    String? expertId,
    List<SettlementPostingLine>? lines,
    DateTime? occurredAt,
    Map<String, Object?>? metadata,
  }) {
    return SettlementPostingInstruction(
      settlementId: settlementId ?? this.settlementId,
      operationId: operationId ?? this.operationId,
      consultationId: consultationId ?? this.consultationId,
      escrowId: escrowId ?? this.escrowId,
      clientId: clientId ?? this.clientId,
      expertId: expertId ?? this.expertId,
      lines: lines ?? this.lines,
      occurredAt: occurredAt ?? this.occurredAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SettlementPostingInstruction &&
            other.settlementId == settlementId &&
            other.operationId == operationId &&
            other.consultationId == consultationId &&
            other.escrowId == escrowId &&
            other.clientId == clientId &&
            other.expertId == expertId &&
            _listEquals(other.lines, lines) &&
            other.occurredAt == occurredAt &&
            _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
    settlementId,
    operationId,
    consultationId,
    escrowId,
    clientId,
    expertId,
    Object.hashAll(lines),
    occurredAt,
    Object.hashAllUnordered(
      metadata.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );

  @override
  String toString() {
    return 'SettlementPostingInstruction('
        'settlementId: $settlementId, '
        'operationId: $operationId, '
        'consultationId: $consultationId, '
        'currency: ${currency.code}, '
        'lineCount: $lineCount, '
        'totalMinorUnits: $totalMinorUnits'
        ')';
  }

  static void _validateCurrencies(List<SettlementPostingLine> lines) {
    final expectedCurrency = lines.first.amount.currency;

    for (final line in lines.skip(1)) {
      if (line.amount.currency != expectedCurrency) {
        throw ArgumentError.value(
          lines,
          'lines',
          'All settlement posting lines must use the same currency.',
        );
      }
    }
  }

  static String _normalizeRequired({
    required String value,
    required String fieldName,
  }) {
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

  static bool _listEquals<T>(List<T> first, List<T> second) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }

    return true;
  }

  static bool _mapEquals<K, V>(Map<K, V> first, Map<K, V> second) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (final entry in first.entries) {
      if (!second.containsKey(entry.key) || second[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}
