/// The official contract. Nothing else.
///
/// This file imports NOTHING — not the framework, not the platform,
/// not another layer of the Kit. A contract is a fact of the product,
/// and a fact needs nothing to be true.
library;

/// What an official contract IS.
///
/// A contract is an IDENTITY — which contract this is, stable for as
/// long as the product exists, never a position — its official name,
/// and what completes that name when something must be said.
///
/// It enforces nothing and judges nothing: what a contract SAYS and
/// what is done about it are different questions, and the doing has
/// other owners. A contract cannot change either: two contracts with
/// the same words ARE the same contract, and a contract that moved is
/// a NEW contract, declared whole.
final class MentoraContract {
  /// Which contract this IS — stable forever, never a position.
  final String id;

  /// What it is called. The application owns every string; the Kit
  /// composes none.
  final String name;

  /// What completes the name, when something must be said.
  final String? description;

  const MentoraContract({
    required this.id,
    required this.name,
    this.description,
  });

  /// What a contract refuses — fail closed.
  void verify() {
    if (id.isEmpty) {
      throw StateError('A contract without an identity is not a contract.');
    }
    if (name.isEmpty) {
      throw StateError(
        'A contract without a name binds no one: a person always knows '
        'which contract is spoken of.',
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
    return other is MentoraContract &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(id, name, description);
}
