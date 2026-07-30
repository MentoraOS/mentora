import 'financial_domain_exception.dart';

/// Raised when an unsupported or malformed currency code enters the domain.
final class InvalidFinancialCurrencyException extends FinancialDomainException {
  InvalidFinancialCurrencyException(String? code)
    : super(
        code: 'financial.invalid_currency',
        message: 'Unsupported financial currency code: ${code ?? '<null>'}.',
        details: <String, Object?>{'currencyCode': code},
      );
}
