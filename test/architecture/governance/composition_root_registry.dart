/// Mentora Composition Root Governance Registry.
///
/// Sprint -1.3 / Lot A / A.2.1.
///
/// This registry defines the locations that are authorized to perform
/// production dependency composition.
///
/// IMPORTANT:
/// Being listed here does NOT grant permission to business code to depend
/// on infrastructure. It only identifies official composition boundaries.
abstract final class CompositionRootRegistry {
  /// Canonical application composition root.
  ///
  /// This file will be introduced in A.2.2.
  static const Set<String> allowedCompositionRoots = {
    'composition/mentora_composition_root.dart',
  };

  /// Infrastructure implementation files that are allowed to encapsulate
  /// SDK singleton access internally.
  ///
  /// These files are infrastructure factories/providers, not application
  /// composition roots.
  static const Set<String> allowedInfrastructureProviders = {
    'infrastructure/firebase/firebase_dependencies.dart',
    'infrastructure/authentication/firebase_authentication_service.dart',
  };

  static bool isAllowedCompositionRoot(String sourcePath) {
    return allowedCompositionRoots.contains(sourcePath);
  }

  static bool isAllowedInfrastructureProvider(String sourcePath) {
    return allowedInfrastructureProviders.contains(sourcePath);
  }

  static bool isAllowedCompositionBoundary(String sourcePath) {
    return isAllowedCompositionRoot(sourcePath) ||
        isAllowedInfrastructureProvider(sourcePath);
  }
}
