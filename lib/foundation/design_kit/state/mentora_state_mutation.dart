import 'mentora_state.dart';

/// The transformation asked of one state. Nothing else.
///
/// A mutation DESCRIBES: from this official fact, this value is asked
/// for. It does not execute the change, does not touch the state it
/// starts from, and does not produce the next one — its source cannot
/// even build a state, and a scan holds it. Whether the demand is
/// honoured, and what fact becomes official then, belongs to whoever
/// the application hands the description to — later, elsewhere, never
/// here.
///
/// A transformation that demands nothing is not a transformation:
/// asking a fact to become what it already is describes no change,
/// and it is refused.
final class MentoraStateMutation {
  /// The official fact the transformation starts from — whole, and
  /// strictly intact.
  final MentoraState from;

  /// The value asked for, declared by whoever asks.
  final String requestedValue;

  const MentoraStateMutation({
    required this.from,
    required this.requestedValue,
  });

  /// What the mutation refuses — fail closed.
  ///
  /// The fact speaks first with its own voice; then the mutation
  /// verifies only what it owns: that a change is actually described.
  void verify() {
    from.verify();

    if (requestedValue.isEmpty) {
      throw StateError(
        'A transformation asks for a value: without one it asks '
        'nothing, and nothing is not a transformation.',
      );
    }
    if (requestedValue == from.value) {
      throw StateError(
        'A transformation that demands nothing is not a '
        'transformation: "${from.id}" already holds that value.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraStateMutation &&
        other.from == from &&
        other.requestedValue == requestedValue;
  }

  @override
  int get hashCode => Object.hash(from, requestedValue);
}
