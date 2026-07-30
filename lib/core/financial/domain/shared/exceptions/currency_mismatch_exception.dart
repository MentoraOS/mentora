import 'financial_domain_exception.dart';

/// Raised when an arithmetic or comparison operation mixes currencies.
final class CurrencyMismatchException extends FinancialDomainException {
  CurrencyMismatchException({
    required String leftCurrency,
    required String rightCurrency,
  }) : super(
         code: 'financial.currency_mismatch',
         message: 'Cannot operate on $leftCurrency and $rightCurrency amounts.',
         details: <String, Object?>{
           'leftCurrency': leftCurrency,
           'rightCurrency': rightCurrency,
         },
       );
}
