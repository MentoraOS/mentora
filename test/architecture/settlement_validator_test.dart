import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/primitives/percentage/percentage.dart';
import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/shared/money/financial_currency.dart';
import 'package:mentora/core/financial/domain/shared/money/money.dart';
import 'package:mentora/core/financial/domain/shared/rates/revenue_share.dart';

void main() {
  group('SettlementValidator', () {
    SettlementLine createLine({
      required SettlementParty party,
      required int minorUnits,
      required FinancialCurrency currency,
      required int wholePercent,
    }) {
      return SettlementLine(
        party: party,
        rate: RevenueShare(Percentage.fromWholePercent(wholePercent)),
        amount: Money(minorUnits: minorUnits, currency: currency),
      );
    }

    test('accepts a valid settlement', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: <SettlementLine>[
          createLine(
            party: SettlementParty.expert,
            minorUnits: 8500,
            currency: FinancialCurrency.xof,
            wholePercent: 85,
          ),
          createLine(
            party: SettlementParty.platform,
            minorUnits: 1500,
            currency: FinancialCurrency.xof,
            wholePercent: 15,
          ),
        ],
      );

      expect(() => SettlementValidator.validate(settlement), returnsNormally);
    });

    test('rejects an empty settlement', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_empty'),
        lines: const <SettlementLine>[],
      );

      expect(
        () => SettlementValidator.validate(settlement),
        throwsA(
          isA<SettlementException>()
              .having(
                (exception) => exception.code,
                'code',
                'financial.settlement',
              )
              .having(
                (exception) => exception.message,
                'message',
                'A settlement must contain at least one settlement line.',
              ),
        ),
      );
    });

    test('rejects settlement lines using different currencies', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_mixed_currency'),
        lines: <SettlementLine>[
          createLine(
            party: SettlementParty.expert,
            minorUnits: 8500,
            currency: FinancialCurrency.xof,
            wholePercent: 85,
          ),
          createLine(
            party: SettlementParty.platform,
            minorUnits: 1500,
            currency: FinancialCurrency.usd,
            wholePercent: 15,
          ),
        ],
      );

      expect(
        () => SettlementValidator.validate(settlement),
        throwsA(
          isA<SettlementException>()
              .having(
                (exception) => exception.code,
                'code',
                'financial.settlement',
              )
              .having(
                (exception) => exception.message,
                'message',
                'All settlement lines must use the same currency.',
              ),
        ),
      );
    });

    test('currency mismatch exception contains diagnostic details', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_details'),
        lines: <SettlementLine>[
          createLine(
            party: SettlementParty.expert,
            minorUnits: 8500,
            currency: FinancialCurrency.xof,
            wholePercent: 85,
          ),
          createLine(
            party: SettlementParty.platform,
            minorUnits: 1500,
            currency: FinancialCurrency.usd,
            wholePercent: 15,
          ),
        ],
      );

      try {
        SettlementValidator.validate(settlement);
        fail('SettlementException was expected.');
      } on SettlementException catch (exception) {
        expect(
          exception.details['expectedCurrency'],
          FinancialCurrency.xof.code,
        );
        expect(exception.details['actualCurrency'], FinancialCurrency.usd.code);
        expect(exception.details['party'], SettlementParty.platform.name);
      }
    });

    test('isValid returns true for a valid settlement', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_valid'),
        lines: <SettlementLine>[
          createLine(
            party: SettlementParty.expert,
            minorUnits: 8500,
            currency: FinancialCurrency.xof,
            wholePercent: 85,
          ),
          createLine(
            party: SettlementParty.platform,
            minorUnits: 1500,
            currency: FinancialCurrency.xof,
            wholePercent: 15,
          ),
        ],
      );

      expect(SettlementValidator.isValid(settlement), isTrue);
    });

    test('isValid returns false for an empty settlement', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_invalid_empty'),
        lines: const <SettlementLine>[],
      );

      expect(SettlementValidator.isValid(settlement), isFalse);
    });

    test('isValid returns false for different currencies', () {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_invalid_currency'),
        lines: <SettlementLine>[
          createLine(
            party: SettlementParty.expert,
            minorUnits: 8500,
            currency: FinancialCurrency.xof,
            wholePercent: 85,
          ),
          createLine(
            party: SettlementParty.platform,
            minorUnits: 1500,
            currency: FinancialCurrency.usd,
            wholePercent: 15,
          ),
        ],
      );

      expect(SettlementValidator.isValid(settlement), isFalse);
    });
  });
}
