import '../../shared/exceptions/financial_domain_exception.dart';

// Raised when a percentage cannot be represented by the domain.
final class InvalidPercentageException extends FinancialDomainException {
  InvalidPercentageException({required super.message, Object? value})
    : super(
        code: 'financial.invalid_percentage',
        details: <String, Object?>{'value': value},
      );
}
