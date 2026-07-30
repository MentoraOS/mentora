import '../../../domain/settlement/settlements.dart';
import '../../../domain/shared/money/financial_currency.dart';
import '../../../domain/shared/money/money.dart';
import '../../../domain/shared/rates/rates.dart';

final class SettlementFirestoreMapper {
  const SettlementFirestoreMapper();

  static const int currentSchemaVersion = 1;

  Map<String, dynamic> toMap(ConsultationSettlement settlement) {
    return <String, dynamic>{
      'schemaVersion': currentSchemaVersion,
      'id': settlement.id.toPrimitive(),
      'status': settlement.status.name,
      'version': settlement.version,
      'lines': settlement.lines.map(_lineToMap).toList(growable: false),
    };
  }

  ConsultationSettlement fromMap(
    Map<String, dynamic> data, {
    String? fallbackId,
  }) {
    final schemaVersion = _readNonNegativeInt(
      data['schemaVersion'] ?? currentSchemaVersion,
      fieldName: 'schemaVersion',
    );

    if (schemaVersion != currentSchemaVersion) {
      throw StateError(
        'Unsupported settlement Firestore schema version '
        '"$schemaVersion".',
      );
    }

    final rawLines = data['lines'];

    if (rawLines is! List) {
      throw StateError('Invalid or missing Firestore field "lines".');
    }

    final lines = rawLines
        .map((rawLine) => _lineFromMap(_readMap(rawLine, fieldName: 'lines[]')))
        .toList(growable: false);

    return ConsultationSettlement(
      id: SettlementId.fromString(
        _readRequiredString(data['id'], fieldName: 'id', fallback: fallbackId),
      ),
      status: _statusFromString(
        _readRequiredString(data['status'], fieldName: 'status'),
      ),
      version: _readNonNegativeInt(data['version'], fieldName: 'version'),
      lines: lines,
    );
  }

  Map<String, dynamic> _lineToMap(SettlementLine line) {
    return <String, dynamic>{
      'party': line.party.name,
      'rateType': _rateTypeToCode(line.rate),
      'ratePartsPerMillion': line.rate.toPrimitive(),
      'amountMinor': line.amount.minorUnits,
      'currency': line.amount.currency.code,
    };
  }

  SettlementLine _lineFromMap(Map<String, dynamic> data) {
    return SettlementLine(
      party: _partyFromString(
        _readRequiredString(data['party'], fieldName: 'lines.party'),
      ),
      rate: _rateFromFirestore(
        type: _readRequiredString(
          data['rateType'],
          fieldName: 'lines.rateType',
        ),
        partsPerMillion: _readNonNegativeInt(
          data['ratePartsPerMillion'],
          fieldName: 'lines.ratePartsPerMillion',
        ),
      ),
      amount: Money(
        minorUnits: _readNonNegativeInt(
          data['amountMinor'],
          fieldName: 'lines.amountMinor',
        ),
        currency: FinancialCurrency.fromCode(
          _readRequiredString(data['currency'], fieldName: 'lines.currency'),
        ),
      ),
    );
  }

  String _rateTypeToCode(FinancialRate rate) {
    return switch (rate) {
      CommissionRate() => 'commission',
      FeeRate() => 'fee',
      RevenueShare() => 'revenue_share',
      VatRate() => 'vat',
      _ => throw StateError(
        'Unsupported settlement FinancialRate '
        '"${rate.runtimeType}".',
      ),
    };
  }

  FinancialRate _rateFromFirestore({
    required String type,
    required int partsPerMillion,
  }) {
    return switch (type.trim().toLowerCase()) {
      'commission' => CommissionRate.fromPartsPerMillion(partsPerMillion),
      'fee' => FeeRate.fromPartsPerMillion(partsPerMillion),
      'revenue_share' => RevenueShare.fromPartsPerMillion(partsPerMillion),
      'vat' => VatRate.fromPartsPerMillion(partsPerMillion),
      _ => throw StateError('Unknown settlement FinancialRate type "$type".'),
    };
  }

  SettlementStatus _statusFromString(String value) {
    return switch (value.trim().toLowerCase()) {
      'pending' => SettlementStatus.pending,
      'processing' => SettlementStatus.processing,
      'completed' => SettlementStatus.completed,
      'failed' => SettlementStatus.failed,
      'cancelled' => SettlementStatus.cancelled,
      'refunded' => SettlementStatus.refunded,
      _ => throw StateError('Unknown settlement status "$value".'),
    };
  }

  SettlementParty _partyFromString(String value) {
    return switch (value.trim()) {
      'expert' => SettlementParty.expert,
      'platform' => SettlementParty.platform,
      'tax' => SettlementParty.tax,
      'paymentProvider' => SettlementParty.paymentProvider,
      'affiliate' => SettlementParty.affiliate,
      'partner' => SettlementParty.partner,
      _ => throw StateError('Unknown settlement party "$value".'),
    };
  }

  Map<String, dynamic> _readMap(Object? value, {required String fieldName}) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw StateError('Invalid or missing Firestore field "$fieldName".');
  }

  String _readRequiredString(
    Object? value, {
    required String fieldName,
    String? fallback,
  }) {
    final candidate = value is String ? value.trim() : '';

    if (candidate.isNotEmpty) {
      return candidate;
    }

    final normalizedFallback = fallback?.trim() ?? '';

    if (normalizedFallback.isNotEmpty) {
      return normalizedFallback;
    }

    throw StateError('Invalid or missing Firestore field "$fieldName".');
  }

  int _readNonNegativeInt(Object? value, {required String fieldName}) {
    final int? parsed = switch (value) {
      int number => number,
      num number => number.toInt(),
      _ => null,
    };

    if (parsed == null || parsed < 0) {
      throw StateError(
        'Invalid Firestore field "$fieldName": "$value". '
        'A non-negative integer is required.',
      );
    }

    return parsed;
  }
}
