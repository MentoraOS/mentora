/// The official rule. Nothing else.
///
/// This file imports NOTHING — not the framework, not the platform,
/// not another foundation of the Kit. A rule is a fact of the
/// product, and a fact needs nothing to be true.
library;

/// What an official rule IS.
///
/// A rule is an IDENTITY — which rule this is, stable for as long as
/// the product exists, never a position — its official name, and what
/// completes that name when something must be said.
///
/// It enforces nothing and judges no one: what a rule SAYS, whether
/// it is honoured, and what happens when it is not, are different
/// questions with other owners. A rule cannot change either: two
/// rules with the same words ARE the same rule, and a rule that moved
/// is a NEW rule, declared whole.
final class MentoraRule {
  /// Which rule this IS — stable forever, never a position.
  final String id;

  /// What it is called. The application owns every string; the Kit
  /// composes none.
  final String name;

  /// What completes the name, when something must be said.
  final String? description;

  const MentoraRule({required this.id, required this.name, this.description});

  /// What a rule refuses — fail closed.
  void verify() {
    if (id.isEmpty) {
      throw StateError('A rule without an identity is not a rule.');
    }
    if (name.isEmpty) {
      throw StateError(
        'A rule without a name governs nothing: a person always knows '
        'which rule is spoken of.',
      );
    }
    if (description != null && description!.isEmpty) {
      throw StateError(
        'A completion is said or it is not: an empty description is an '
        'ambiguity, and an ambiguity is refused.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraRule &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(id, name, description);
}
