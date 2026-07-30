import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/infrastructure/settlement/'
    'settlement_firestore_mapper.dart';
import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/money/'
    'financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';
import 'package:mentora/core/financial/domain/shared/rates/rates.dart';

void main() {
  group('SettlementFirestoreMapper', () {
    const mapper = SettlementFirestoreMapper();

    test('should serialize and rehydrate a settlement without data loss', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        status: SettlementStatus.processing,
        version: 7,
        lines: <SettlementLine>[
          SettlementLine(
            party: SettlementParty.expert,
            rate: RevenueShare.fromWholePercent(81),
            amount: Money(minorUnits: 8100, currency: FinancialCurrency.xof),
          ),
          SettlementLine(
            party: SettlementParty.platform,
            rate: CommissionRate.fromWholePercent(15),
            amount: Money(minorUnits: 1500, currency: FinancialCurrency.xof),
          ),
          SettlementLine(
            party: SettlementParty.tax,
            rate: VatRate.fromWholePercent(3),
            amount: Money(minorUnits: 300, currency: FinancialCurrency.xof),
          ),
          SettlementLine(
            party: SettlementParty.paymentProvider,
            rate: FeeRate.fromWholePercent(1),
            amount: Money(minorUnits: 100, currency: FinancialCurrency.xof),
          ),
        ],
      );

      final data = mapper.toMap(settlement);
      final restored = mapper.fromMap(data);

      expect(restored.id, settlement.id);
      expect(restored.status, SettlementStatus.processing);
      expect(restored.version, 7);
      expect(restored.lines, settlement.lines);
      expect(restored.domainEvents, isEmpty);
    });

    test('should use the fallback document id', () {
      final data = <String, dynamic>{
        'schemaVersion': SettlementFirestoreMapper.currentSchemaVersion,
        'status': 'pending',
        'version': 0,
        'lines': <Map<String, dynamic>>[],
      };

      final restored = mapper.fromMap(data, fallbackId: 'settlement_fallback');

      expect(restored.id, SettlementId('settlement_fallback'));
    });

    test('should preserve every supported settlement party', () {
      for (final party in SettlementParty.values) {
        final settlement = ConsultationSettlement(
          id: SettlementId('settlement_${party.name}'),
          lines: <SettlementLine>[
            SettlementLine(
              party: party,
              rate: RevenueShare.fromWholePercent(100),
              amount: Money(minorUnits: 1000, currency: FinancialCurrency.xof),
            ),
          ],
        );

        final restored = mapper.fromMap(mapper.toMap(settlement));

        expect(restored.lines.single.party, party);
      }
    });

    test('should preserve every supported financial rate type', () {
      final rates = <FinancialRate>[
        CommissionRate.fromBasisPoints(1500),
        FeeRate.fromBasisPoints(75),
        RevenueShare.fromWholePercent(80),
        VatRate.fromWholePercent(18),
      ];

      for (final rate in rates) {
        final settlement = ConsultationSettlement(
          id: SettlementId('settlement_${rate.runtimeType}'),
          lines: <SettlementLine>[
            SettlementLine(
              party: SettlementParty.platform,
              rate: rate,
              amount: Money(minorUnits: 1000, currency: FinancialCurrency.usd),
            ),
          ],
        );

        final restored = mapper.fromMap(mapper.toMap(settlement));

        final restoredRate = restored.lines.single.rate;

        expect(restoredRate.runtimeType, rate.runtimeType);
        expect(restoredRate.toPrimitive(), rate.toPrimitive());
      }
    });

    test('should reject an unknown settlement status', () {
      final data = <String, dynamic>{
        'schemaVersion': SettlementFirestoreMapper.currentSchemaVersion,
        'id': 'settlement_001',
        'status': 'unknown',
        'version': 0,
        'lines': <Map<String, dynamic>>[],
      };

      expect(() => mapper.fromMap(data), throwsStateError);
    });

    test('should reject an unknown financial rate type', () {
      final data = <String, dynamic>{
        'schemaVersion': SettlementFirestoreMapper.currentSchemaVersion,
        'id': 'settlement_001',
        'status': 'pending',
        'version': 0,
        'lines': <Map<String, dynamic>>[
          <String, dynamic>{
            'party': 'platform',
            'rateType': 'unknown_rate',
            'ratePartsPerMillion': 100000,
            'amountMinor': 1000,
            'currency': 'XOF',
          },
        ],
      };

      expect(() => mapper.fromMap(data), throwsStateError);
    });

    test('should reject a negative aggregate version', () {
      final data = <String, dynamic>{
        'schemaVersion': SettlementFirestoreMapper.currentSchemaVersion,
        'id': 'settlement_001',
        'status': 'pending',
        'version': -1,
        'lines': <Map<String, dynamic>>[],
      };

      expect(() => mapper.fromMap(data), throwsStateError);
    });

    test('should reject an unsupported schema version', () {
      final data = <String, dynamic>{
        'schemaVersion': 999,
        'id': 'settlement_001',
        'status': 'pending',
        'version': 0,
        'lines': <Map<String, dynamic>>[],
      };

      expect(() => mapper.fromMap(data), throwsStateError);
    });
  });
}
