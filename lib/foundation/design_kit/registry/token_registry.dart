import 'token_identity.dart';

/// The runtime registry: the Kit-side mirror of the Token Registry
/// Catalog. It RECEIVES admitted identities — it never creates one
/// (UTN-01: "Un Token n'est jamais créé. Il est enregistré.").
///
/// Fail closed everywhere: duplicates refused, unknown lookups refused.
final class DesignTokenRegistry {
  final Map<String, TokenIdentity> _identities = {};

  /// Receives an identity admitted by the catalog. A duplicate name is
  /// a violation (UTT-01/UTC-02) — refused, never overwritten.
  void receive(TokenIdentity identity) {
    if (_identities.containsKey(identity.name)) {
      throw StateError(
        'Token "${identity.name}" is already registered — a name is '
        'unique forever (UTC-02).',
      );
    }
    _identities[identity.name] = identity;
  }

  /// Resolves an identity by name. Unknown is refused — never null,
  /// never a default (fail closed).
  TokenIdentity identityOf(String name) {
    final identity = _identities[name];
    if (identity == null) {
      throw StateError(
        'Unknown token "$name" — nothing exists outside the registry '
        '(TRC-07).',
      );
    }
    return identity;
  }

  bool contains(String name) => _identities.containsKey(name);

  Iterable<TokenIdentity> get identities => _identities.values;
}
