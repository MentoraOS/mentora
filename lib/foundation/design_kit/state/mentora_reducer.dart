import 'mentora_state.dart';
import 'mentora_state_mutation.dart';

/// How a mutation officially transforms a state. Nothing else.
///
/// The reducer is the ONE place in the whole layer where a next fact
/// may be born: everywhere else, describing a change and producing its
/// outcome are kept apart by scans — here, and only here, the two
/// meet. The official reduction is exactly what the mutation already
/// described: the same identity, holding the requested value. Nothing
/// is decided, because everything was already said.
///
/// It stores nothing and remembers nothing: the reducer has no state
/// of its own — not one field — so every reducer IS the one official
/// reduction, and reducing twice gives the same fact twice. It
/// notifies no one and broadcasts nothing: who learns of the new fact
/// belongs to whoever the application tells.
///
/// It does not touch what it was given: the fact the mutation starts
/// from remains exactly what it was — a fact that moved is a NEW fact,
/// and this is where new facts are announced from.
final class MentoraReducer {
  const MentoraReducer();

  /// The official reduction: the fact the mutation described, born
  /// whole.
  ///
  /// The mutation speaks first with its own voice — and the fact it
  /// starts from with its. What remains cannot fail: a verified
  /// mutation describes a whole fact, and the reducer adds nothing to
  /// what was described.
  MentoraState reduce(MentoraStateMutation mutation) {
    mutation.verify();

    return MentoraState(id: mutation.from.id, value: mutation.requestedValue);
  }

  /// Every reducer is the one official reduction: there is nothing
  /// two reducers could differ by.
  @override
  bool operator ==(Object other) => other is MentoraReducer;

  @override
  int get hashCode => (MentoraReducer).hashCode;
}
