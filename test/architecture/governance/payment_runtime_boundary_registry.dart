/// Payment runtime boundary governance.
///
/// Sprint -1.2 / Lot E.5.1.
///
/// Mock payment implementations may exist in the repository for testing,
/// but they must never participate in the production dependency graph.
abstract final class PaymentRuntimeBoundaryRegistry {
  static const Set<String> forbiddenRuntimeSymbols = {'MockPaymentProvider'};

  static const Set<String> forbiddenRuntimeImportFragments = {
    'mock_payment_provider.dart',
  };

  /// Declaration files are allowed to contain the mock itself.
  ///
  /// External runtime consumers are not.
  static const Set<String> declarationFiles = {
    'core/engines/payment/providers/mock_payment_provider.dart',
  };
}
