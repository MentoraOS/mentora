/// The validation contracts of the Design Kit.
///
/// The Kit carries the STATE of a validation, its MESSAGE and its
/// PHASE — never a rule. What makes a value acceptable belongs to the
/// business, upstream and outside: no rule, no regular expression, no
/// threshold, no format will ever live here.
library;

/// What a validation says about a value. `pristine` is the honest
/// third state: nothing has been judged yet — never a silent "valid".
enum MentoraValidationState { pristine, valid, invalid }

/// One validation verdict: a state and, when the verdict deserves an
/// explanation, a message composed by the business (the Localization
/// Engine owns every string — the Kit composes none).
final class MentoraValidation {
  final MentoraValidationState state;
  final String? message;

  const MentoraValidation({required this.state, this.message});

  static const MentoraValidation pristine = MentoraValidation(
    state: MentoraValidationState.pristine,
  );

  const MentoraValidation.valid({this.message})
    : state = MentoraValidationState.valid;

  const MentoraValidation.invalid({required String this.message})
    : state = MentoraValidationState.invalid;

  bool get isInvalid => state == MentoraValidationState.invalid;

  @override
  bool operator ==(Object other) =>
      other is MentoraValidation &&
      other.state == state &&
      other.message == message;

  @override
  int get hashCode => Object.hash(state, message);
}

/// The port through which the business judges a value. The Kit calls
/// it; it never implements it — an implementation carries a rule, and
/// a rule is business.
abstract interface class MentoraInputValidator {
  MentoraValidation validate(String value);
}
