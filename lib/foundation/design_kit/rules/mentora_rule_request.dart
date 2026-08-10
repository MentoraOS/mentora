import 'mentora_rule.dart';

/// The rule officially asked for. Nothing else.
///
/// A request CARRIES: the rule asked for travels whole and strictly
/// intact, and that is the entirety of what a request does. It
/// decides nothing and computes nothing — what is done with the
/// demand belongs to whoever the application hands it to, later,
/// elsewhere, never here.
///
/// It invents no refusal: what a rule owes, the rule itself refuses,
/// with its own voice. Whether the rule asked for is one the product
/// DECLARED is a question that needs the gathering, and the first
/// voice that holds the gathering is the answer — never the demand.
final class MentoraRuleRequest {
  /// The rule asked for, carried whole — never an address, never a
  /// guess.
  final MentoraRule rule;

  const MentoraRuleRequest({required this.rule});

  /// What the request refuses — fail closed.
  ///
  /// The rule speaks with its own voice; a carrier adds none.
  void verify() {
    rule.verify();
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraRuleRequest && other.rule == rule;
  }

  @override
  int get hashCode => rule.hashCode;
}
