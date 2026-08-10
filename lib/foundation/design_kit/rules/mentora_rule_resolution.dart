import 'mentora_rule.dart';
import 'mentora_rule_registry.dart';
import 'mentora_rule_request.dart';

/// The rule officially resolved. Nothing else.
///
/// A resolution decides nothing: the deciding has already happened
/// when a resolution is written. It STATES one fact — "this demand
/// was resolved to this rule" — and a fact, once stated, never moves
/// again.
///
/// The demand speaks always before the resolution — with the rule's
/// voice through it. Then the resolution verifies what it owns, and
/// it owns two things here: that the rule resolved IS the rule asked
/// for, word for word — a substitution is refused, no rule of the
/// foundation allows one — and that the rule is one the product
/// DECLARED. The demand is a pure carrier and holds no gathering; the
/// resolution is the first voice that does, so the declaration is
/// answered here, once.
final class MentoraRuleResolution {
  /// The demand this resolution answers.
  final MentoraRuleRequest request;

  /// The rule the demand was resolved to.
  final MentoraRule resolvedRule;

  const MentoraRuleResolution({
    required this.request,
    required this.resolvedRule,
  });

  /// What the resolution refuses — fail closed.
  void verify(MentoraRuleRegistry registry) {
    request.verify();

    if (resolvedRule != request.rule) {
      throw StateError(
        'A resolution answers the demand it was given: resolving '
        '"${resolvedRule.id}" for a demand that asked for '
        '"${request.rule.id}" is a substitution, and no rule of the '
        'foundation allows one.',
      );
    }
    if (!registry.rules.contains(resolvedRule)) {
      throw StateError(
        'A demand can only be resolved to a rule the product declared: '
        '"${resolvedRule.id}" as resolved is not one of them.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraRuleResolution &&
        other.request == request &&
        other.resolvedRule == resolvedRule;
  }

  @override
  int get hashCode => Object.hash(request, resolvedRule);
}
