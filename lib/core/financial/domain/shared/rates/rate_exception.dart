import '../exceptions/financial_domain_exception.dart';

/// Base exception for all Financial Rate related errors.
final class FinancialRateException extends FinancialDomainException {
  const FinancialRateException({required super.message, super.details})
    : super(code: 'financial.rate');
}
