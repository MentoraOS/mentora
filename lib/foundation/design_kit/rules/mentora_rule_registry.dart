import 'mentora_rule.dart';

/// The official set of the rules. Nothing else.
///
/// A registry is where duplication becomes checkable: a single rule
/// cannot know its neighbours, so the promise "two rules never share
/// one identity" is kept here — once, for the whole product.
///
/// A registry is declared once: what governs a product is not a value
/// that varies — two gatherings are two products.
final class MentoraRuleRegistry {
  /// The rules, in the order the product declares them.
  final List<MentoraRule> rules;

  const MentoraRuleRegistry({required this.rules});

  /// What the registry refuses — fail closed.
  void verify() {
    if (rules.isEmpty) {
      throw StateError(
        'A product without a rule is governed by nothing: an empty '
        'registry is refused.',
      );
    }
    final identities = <String>{};
    for (final rule in rules) {
      rule.verify();
      if (!identities.add(rule.id)) {
        throw StateError('Two rules never share one identity.');
      }
    }
  }
}
