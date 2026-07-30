import 'financial_domain_exception.dart';

/// Raised when a monetary amount violates the Money value object's rules.
final class InvalidMoneyAmountException extends FinancialDomainException {
  InvalidMoneyAmountException(int minorUnits)
    : super(
        code: 'financial.invalid_money_amount',
        message: 'Money cannot contain a negative amount: $minorUnits.',
        details: <String, Object?>{'minorUnits': minorUnits},
      );
}
