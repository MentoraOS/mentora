/// The runtime mirror of the Universal Token Registry's identity card
/// (P11.9A §7). Contracts only — no value lives here, ever.
library;

/// The ten official Domains — one per origin of the catalog (§5 of the
/// registry). A new Domain requires the upstream revision first
/// (UTS-02), never a code change alone.
enum TokenDomain {
  color,
  typography,
  spacing,
  elevationSurface,
  iconography,
  illustration,
  component,
  appearance,
  interaction,
  motion,
}

/// The official lifecycle statuses (registry §8). Never deleted:
/// `archived` is the last state, not an erasure (UTL-03).
enum TokenStatus {
  proposed,
  accepted,
  registered,
  used,
  versioned,
  deprecated,
  archived,
}

/// The runtime identity of an admitted Token: the attributes the Kit
/// needs to consume it faithfully. The full eight-attribute card lives
/// in the catalog; the Kit carries what resolution requires.
final class TokenIdentity {
  final String name;
  final TokenDomain domain;
  final String group;
  final TokenStatus status;
  final String version;

  const TokenIdentity({
    required this.name,
    required this.domain,
    required this.group,
    required this.status,
    this.version = '1.0',
  });

  bool get isConsumable =>
      status != TokenStatus.deprecated && status != TokenStatus.archived;
}

/// A typed reference to an admitted Token. A ref carries the identity
/// and the value type its materialization must produce — never the
/// value itself (FDT-01: a component reads a Token, never a value).
final class TokenRef<T> {
  final TokenIdentity identity;

  const TokenRef(this.identity);

  String get name => identity.name;
  TokenDomain get domain => identity.domain;
}
