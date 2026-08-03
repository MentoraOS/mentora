import '../theme/theme_variant.dart';
import 'token_provider.dart';
import 'token_registry.dart';

/// The classes of token violations the Kit refuses (registry §12).
enum TokenViolationKind {
  unknownBinding,
  deprecatedBinding,
  orphanIdentity,
  missingVariant,
}

final class TokenViolation {
  final TokenViolationKind kind;
  final String tokenName;
  final String detail;

  const TokenViolation({
    required this.kind,
    required this.tokenName,
    required this.detail,
  });

  @override
  String toString() => '${kind.name}($tokenName): $detail';
}

/// Raised when validation finds violations — fail closed: an invalid
/// token state never reaches a running surface.
final class TokenValidationFailure implements Exception {
  final List<TokenViolation> violations;

  const TokenValidationFailure(this.violations);

  @override
  String toString() =>
      'TokenValidationFailure(${violations.length} violations: '
      '${violations.join('; ')})';
}

/// Validates a provider against the registry. The Kit refuses:
/// unknown bindings (value outside the registry), deprecated bindings,
/// orphan identities (registered, never bound — UTG-08: signaled, never
/// ignored), and incomplete variant coverage.
final class TokenValidator {
  const TokenValidator();

  /// Throws [TokenValidationFailure] with the full violation list;
  /// returns normally only when the state is clean.
  void validate({
    required DesignTokenRegistry registry,
    required DesignTokenProvider provider,
    Set<String> expectedComplete = const {},
  }) {
    final violations = <TokenViolation>[];

    for (final name in provider.boundNames) {
      if (!registry.contains(name)) {
        violations.add(
          TokenViolation(
            kind: TokenViolationKind.unknownBinding,
            tokenName: name,
            detail: 'bound value for a name absent from the registry',
          ),
        );
        continue;
      }
      final identity = registry.identityOf(name);
      if (!identity.isConsumable) {
        violations.add(
          TokenViolation(
            kind: TokenViolationKind.deprecatedBinding,
            tokenName: name,
            detail: 'bound while ${identity.status.name}',
          ),
        );
      }
    }

    for (final identity in registry.identities) {
      if (identity.isConsumable && !provider.isBound(identity.name)) {
        violations.add(
          TokenViolation(
            kind: TokenViolationKind.orphanIdentity,
            tokenName: identity.name,
            detail: 'registered but never bound (UTG-08)',
          ),
        );
      }
    }

    for (final name in expectedComplete) {
      if (!provider.isBound(name)) continue;
      final variants = provider.variantsOf(name);
      if (variants.isEmpty) continue; // Universal binding: complete.
      final missing = ThemeVariantId.values.toSet().difference(variants);
      if (missing.isNotEmpty) {
        violations.add(
          TokenViolation(
            kind: TokenViolationKind.missingVariant,
            tokenName: name,
            detail: 'missing variants: ${missing.map((v) => v.name).join(',')}',
          ),
        );
      }
    }

    if (violations.isNotEmpty) {
      throw TokenValidationFailure(violations);
    }
  }
}
