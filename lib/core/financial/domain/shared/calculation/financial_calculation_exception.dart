import '../exceptions/financial_domain_exception.dart';

/// Exception thrown when a financial calculation cannot be completed.
final class FinancialCalculationException extends FinancialDomainException {
  const FinancialCalculationException({required super.message, super.details})
    : super(code: 'financial.calculation.failed');

  @override
  String toString() {
    return 'FinancialCalculationException('
        'code: $code, '
        'message: $message, '
        'details: $details'
        ')';
  }
}
