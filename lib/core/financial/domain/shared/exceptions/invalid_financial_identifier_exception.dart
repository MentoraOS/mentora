import 'financial_domain_exception.dart';

/// Raised when a typed financial identifier is empty or malformed.
final class InvalidFinancialIdentifierException
    extends FinancialDomainException {
  InvalidFinancialIdentifierException({
    required String identifierType,
    required String? value,
  }) : super(
         code: 'financial.invalid_identifier',
         message: '$identifierType must contain a non-empty value.',
         details: <String, Object?>{
           'identifierType': identifierType,
           'value': value,
         },
       );
}
