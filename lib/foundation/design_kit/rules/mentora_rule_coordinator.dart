import 'mentora_rule_registry.dart';
import 'mentora_rule_request.dart';
import 'mentora_rule_resolution.dart';

/// The order in which the truths of the rules talk to one another.
/// Nothing else.
///
/// The coordinator is NOT a machine. It enforces nothing, decides
/// nothing and produces no effect. Every truth it composes already
/// exists, whole, before the coordinator is written — what it owns is
/// the DIALOGUE: which voice speaks first, and what must agree
/// between them for the whole to stand.
///
/// The official order is the order of the questions themselves: what
/// governs the product, what is asked of it, what was resolved. The
/// coordinator invents no refusal: it adds only the agreement no
/// single voice can see — that the answer of this dialogue answers
/// THIS dialogue's demand.
final class MentoraRuleCoordinator {
  /// The one gathering of the product's rules.
  final MentoraRuleRegistry registry;

  /// What is asked.
  final MentoraRuleRequest request;

  /// What was resolved.
  final MentoraRuleResolution resolution;

  const MentoraRuleCoordinator({
    required this.registry,
    required this.request,
    required this.resolution,
  });

  /// What the dialogue refuses — fail closed, in the official order.
  void verify() {
    // 1 — what governs the product: the gathering's own chain of
    // voices.
    registry.verify();

    // 2 — what is asked of it: the carrier, with the rule's voice
    // through it.
    request.verify();

    // 3 — what was resolved, and the agreement: the answer of this
    // dialogue answers THIS dialogue's demand.
    resolution.verify(registry);
    if (resolution.request != request) {
      throw StateError(
        'The resolution of this dialogue answers another demand: a '
        'dialogue has one demand, and its answer is the answer to it.',
      );
    }
  }

  /// Two dialogues are the same words over the same gathering.
  ///
  /// A product declares its rules once: two registry objects are two
  /// products, and a dialogue happens in exactly one.
  @override
  bool operator ==(Object other) {
    return other is MentoraRuleCoordinator &&
        identical(other.registry, registry) &&
        other.request == request &&
        other.resolution == resolution;
  }

  @override
  int get hashCode => Object.hash(registry, request, resolution);
}
