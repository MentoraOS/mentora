import 'mentora_state.dart';

/// The official fact just announced. Nothing else.
///
/// An event STATES that a fact now exists: the fact announced travels
/// whole and strictly intact, and that is the entirety of what an
/// event does. It is not the photograph of a state a person chose to
/// take — it is the announcement that this fact just became official.
///
/// It produces no new state, modifies nothing anywhere, triggers no
/// work of any kind, and tells no one: notifying, broadcasting and
/// publishing are machines, and an announcement is not a machine —
/// who hears it, and what they do then, belongs to whoever the
/// application hands it to.
///
/// It invents no refusal either: what a fact owes, the fact itself
/// refuses, with its own voice. An announcement of a malformed fact
/// fails because the FACT fails.
final class MentoraEvent {
  /// The fact announced — whole, and strictly intact.
  final MentoraState fact;

  const MentoraEvent({required this.fact});

  /// What the event refuses — fail closed.
  ///
  /// The fact speaks with its own voice; an announcement adds none.
  void verify() {
    fact.verify();
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraEvent && other.fact == fact;
  }

  @override
  int get hashCode => fact.hashCode;
}
