import 'mentora_state.dart';

/// An exact photograph of one state. Nothing else.
///
/// A snapshot RECORDS: it holds the state it photographed, whole and
/// strictly intact, and that is the entirety of what it does. It
/// modifies nothing, remembers nothing beyond its one photograph,
/// compares nothing, restores nothing and merges nothing — a
/// photograph that edited its subject would not be a photograph.
///
/// It invents no refusal either: what a state owes, the state itself
/// refuses, with its own voice. A snapshot of a malformed fact fails
/// because the FACT fails.
final class MentoraStateSnapshot {
  /// The state photographed — whole, and strictly intact.
  final MentoraState state;

  const MentoraStateSnapshot({required this.state});

  /// What the snapshot refuses — fail closed.
  ///
  /// The state speaks with its own voice; a photograph adds none.
  void verify() {
    state.verify();
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraStateSnapshot && other.state == state;
  }

  @override
  int get hashCode => state.hashCode;
}
