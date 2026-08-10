/// The official information asked for. Nothing else.
///
/// This file imports NOTHING — a question needs nothing to be asked.
///
/// A query asks BY IDENTITY: which official fact is wanted. It cannot
/// even name the fact type, because the ANSWER does not belong to it:
/// whoever answers holds the facts, and the query only says which one
/// is asked for.
///
/// It computes nothing, filters nothing, sorts nothing and walks
/// nothing: an information demand that worked on the information
/// would already be answering. It caches nothing and remembers
/// nothing: the same question asked twice is the same question, and
/// nothing here has changed in between.
library;

final class MentoraQuery {
  /// Which official fact is asked for — an identity, never a
  /// position, never a computation.
  final String stateId;

  const MentoraQuery({required this.stateId});

  /// What the query refuses — fail closed.
  void verify() {
    if (stateId.isEmpty) {
      throw StateError(
        'A question names the fact it asks for: without an identity it '
        'asks nothing, and nothing is not a question.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraQuery && other.stateId == stateId;
  }

  @override
  int get hashCode => stateId.hashCode;
}
