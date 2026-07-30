import '../shared/exceptions/financial_domain_exception.dart';

// Exception thrown when a settlement violates
// a business rule or domain invariant.

final class SettlementException extends FinancialDomainException {
  const SettlementException(
    String message, {
    super.details = const <String, Object?>{},
  }) : super(code: 'financial.settlement', message: message);
}
