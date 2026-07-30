import '../exceptions/financial_domain_exception.dart';

/// Exception raised when a financial allocation violates
/// an allocation invariant or cannot be completed safely.
///
/// Examples:
/// - allocation requests are missing;
/// - allocation rates do not total exactly 100%;
/// - generated amounts do not match the original amount;
/// - allocation currencies are inconsistent.
final class FinancialAllocationException extends FinancialDomainException {
  const FinancialAllocationException({required super.message, super.details})
    : super(code: 'financial.allocation');
}
