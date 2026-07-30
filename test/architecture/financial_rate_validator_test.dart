import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/primitives/percentage/percentage.dart';
import 'package:mentora/core/financial/domain/shared/rates/commission_rate.dart';
import 'package:mentora/core/financial/domain/shared/rates/financial_rate_validator.dart';
import 'package:mentora/core/financial/domain/shared/rates/rate_exception.dart';
import 'package:mentora/core/financial/domain/shared/rates/revenue_share.dart';

void main() {
  group('FinancialRateValidator', () {
    test('accepts a valid financial rate', () {
      final CommissionRate rate = CommissionRate(
        Percentage.fromWholePercent(15),
      );

      expect(() => FinancialRateValidator.validate(rate), returnsNormally);
    });

    test('accepts zero percent as a valid rate', () {
      final CommissionRate rate = CommissionRate(Percentage.zero);

      expect(() => FinancialRateValidator.validate(rate), returnsNormally);
    });

    test('accepts one hundred percent as a valid rate', () {
      final CommissionRate rate = CommissionRate(Percentage.oneHundred);

      expect(() => FinancialRateValidator.validate(rate), returnsNormally);
    });

    test('validateAll accepts multiple valid rates', () {
      final List<CommissionRate> rates = <CommissionRate>[
        CommissionRate(Percentage.fromWholePercent(10)),
        CommissionRate(Percentage.fromWholePercent(20)),
      ];

      expect(() => FinancialRateValidator.validateAll(rates), returnsNormally);
    });

    test('accepts rates totaling exactly one hundred percent', () {
      final List<RevenueShare> rates = <RevenueShare>[
        RevenueShare(Percentage.fromWholePercent(85)),
        RevenueShare(Percentage.fromWholePercent(15)),
      ];

      expect(
        () => FinancialRateValidator.validateTotal(rates),
        returnsNormally,
      );
    });

    test('accepts three rates totaling exactly one hundred percent', () {
      final List<RevenueShare> rates = <RevenueShare>[
        RevenueShare(Percentage.fromWholePercent(50)),
        RevenueShare(Percentage.fromWholePercent(30)),
        RevenueShare(Percentage.fromWholePercent(20)),
      ];

      expect(
        () => FinancialRateValidator.validateTotal(rates),
        returnsNormally,
      );
    });

    test('throws when rates total less than one hundred percent', () {
      final List<RevenueShare> rates = <RevenueShare>[
        RevenueShare(Percentage.fromWholePercent(80)),
        RevenueShare(Percentage.fromWholePercent(15)),
      ];

      expect(
        () => FinancialRateValidator.validateTotal(rates),
        throwsA(isA<FinancialRateException>()),
      );
    });

    test('throws when rates total more than one hundred percent', () {
      final List<RevenueShare> rates = <RevenueShare>[
        RevenueShare(Percentage.fromWholePercent(60)),
        RevenueShare(Percentage.fromWholePercent(50)),
      ];

      expect(
        () => FinancialRateValidator.validateTotal(rates),
        throwsA(isA<FinancialRateException>()),
      );
    });

    test('throws when rate collection is empty', () {
      expect(
        () => FinancialRateValidator.validateTotal(const <RevenueShare>[]),
        throwsA(isA<FinancialRateException>()),
      );
    });

    test('exception contains the actual total', () {
      final List<RevenueShare> rates = <RevenueShare>[
        RevenueShare(Percentage.fromWholePercent(70)),
        RevenueShare(Percentage.fromWholePercent(20)),
      ];

      expect(
        () => FinancialRateValidator.validateTotal(rates),
        throwsA(
          isA<FinancialRateException>().having(
            (FinancialRateException exception) => exception.message,
            'message',
            contains('900000 ppm'),
          ),
        ),
      );
    });
  });
}
