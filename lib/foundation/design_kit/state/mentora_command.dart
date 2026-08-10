import 'mentora_state_mutation.dart';

/// The change officially asked for. Nothing else.
///
/// A command CARRIES: the transformation described by its one owner —
/// the mutation — travels whole and strictly intact, raised to an
/// official demand. That is the entirety of what a command does.
///
/// It decides nothing and executes nothing: it does not touch the
/// state, does not produce an event, and knows no store, no reducer
/// and no next fact — whether the demand is honoured belongs to
/// whoever the application hands it to, later, elsewhere, never here.
///
/// It invents no refusal either: what a transformation owes, the
/// mutation itself refuses, with its own voice — and through it the
/// fact with its. A command of a malformed change fails because the
/// CHANGE fails.
///
/// And it never travels with an information demand: asking for a
/// change and asking for a fact are two questions, and no object of
/// the foundation answers both.
final class MentoraCommand {
  /// The transformation asked — whole, and strictly intact.
  final MentoraStateMutation mutation;

  const MentoraCommand({required this.mutation});

  /// What the command refuses — fail closed.
  ///
  /// The change speaks with its own voice; a carrier adds none.
  void verify() {
    mutation.verify();
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraCommand && other.mutation == mutation;
  }

  @override
  int get hashCode => mutation.hashCode;
}
