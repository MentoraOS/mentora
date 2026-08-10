/// The official capability. Nothing else.
///
/// This file imports NOTHING — not the framework, not the platform,
/// not another foundation of the Kit. A capability is a fact of the
/// product, and a fact needs nothing to be true.
library;

/// What an official capability IS.
///
/// A capability is an IDENTITY — which capability this is, stable for
/// as long as the product exists, never a position — its official
/// name, and what completes that name when something must be said.
///
/// It describes what the product is able to do, and only that: it is
/// not a module, not an implementation, not an interface to anything,
/// and not a decision — whether the ability is exercised, and by
/// whom, are other questions with other owners. A capability cannot
/// change either: two capabilities with the same words ARE the same
/// capability, and one that moved is a NEW capability, declared
/// whole.
final class MentoraCapability {
  /// Which capability this IS — stable forever, never a position.
  final String id;

  /// What it is called. The application owns every string; the Kit
  /// composes none.
  final String name;

  /// What completes the name, when something must be said.
  final String? description;

  const MentoraCapability({
    required this.id,
    required this.name,
    this.description,
  });

  /// What a capability refuses — fail closed.
  void verify() {
    if (id.isEmpty) {
      throw StateError('A capability without an identity is not a capability.');
    }
    if (name.isEmpty) {
      throw StateError(
        'A capability without a name offers nothing: a person always '
        'knows what the product is able to do.',
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
    return other is MentoraCapability &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(id, name, description);
}
