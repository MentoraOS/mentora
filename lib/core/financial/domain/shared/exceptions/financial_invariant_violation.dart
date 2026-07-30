import 'financial_domain_exception.dart';

/// Raised when an operation would put a financial object in an invalid state.
class FinancialInvariantViolation extends FinancialDomainException {
  const FinancialInvariantViolation({
    required super.code,
    required super.message,
    super.details,
  });
}
