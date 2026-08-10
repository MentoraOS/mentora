/// The official state, currently. Nothing else.
///
/// This file imports NOTHING — not the framework, not the platform,
/// not another layer of the Kit. The official state is a fact of the
/// product, and a fact needs nothing to be true.
library;

/// What the official state currently IS.
///
/// A state is one official fact: an IDENTITY — which state this is,
/// stable for as long as the product exists, never a position — and
/// the VALUE that fact holds right now, itself an identity the
/// application declared, never a computation.
///
/// It knows no mutation, no history, no event, no store, no reducer
/// and no machine: how a fact came to be, and what it may become, are
/// other questions with other owners. The state answers one question —
/// "what is official, currently" — and it cannot change: two states
/// with the same words ARE the same state, and a fact that moved is a
/// NEW fact, announced whole.
final class MentoraState {
  /// Which state this IS — stable forever, never a position.
  final String id;

  /// The value the fact holds right now, declared by the application.
  final String value;

  const MentoraState({required this.id, required this.value});

  /// What a state refuses — fail closed.
  void verify() {
    if (id.isEmpty) {
      throw StateError('A state without an identity is not a state.');
    }
    if (value.isEmpty) {
      throw StateError(
        'A state holds a value: without one it states nothing, and '
        'nothing is not a fact.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraState && other.id == id && other.value == value;
  }

  @override
  int get hashCode => Object.hash(id, value);
}
