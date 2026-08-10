import 'mentora_state.dart';

/// Where the official state lives. Nothing else.
///
/// A store CARRIES the official facts of the product — each one whole,
/// each one declared once. It is the one gathering: the promise "two
/// facts never share one identity" is kept here, once, for the whole
/// product, because a single fact cannot know its neighbours.
///
/// It decides nothing, reduces nothing, projects nothing, reads
/// nothing, notifies no one and broadcasts nothing. It knows no
/// command and no event — what is asked of the state, and what was
/// announced about it, are other questions with other owners. The
/// store holds; that is all it does.
///
/// A store is declared once: like the product's topology, the place
/// its state lives is not a value that varies — two gatherings are
/// two products.
final class MentoraStore {
  /// The official facts, in the order the product declares them.
  final List<MentoraState> facts;

  const MentoraStore({required this.facts});

  /// What the store refuses — fail closed.
  void verify() {
    if (facts.isEmpty) {
      throw StateError(
        'A store holds the official facts: without one it holds '
        'nothing, and nothing is not a state that lives anywhere.',
      );
    }
    final identities = <String>{};
    for (final fact in facts) {
      fact.verify();
      if (!identities.add(fact.id)) {
        throw StateError('Two facts never share one identity.');
      }
    }
  }
}
