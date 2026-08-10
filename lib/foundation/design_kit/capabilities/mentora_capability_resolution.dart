import 'mentora_capability.dart';
import 'mentora_capability_registry.dart';
import 'mentora_capability_request.dart';

/// The capability officially resolved. Nothing else.
///
/// A resolution decides nothing: the deciding has already happened
/// when a resolution is written. It STATES one fact — "this demand
/// was resolved to this capability" — and a fact, once stated, never
/// moves again.
///
/// The demand speaks always before the resolution — with the
/// capability's voice through it. Then the resolution verifies what
/// it owns, and it owns two things here: that the capability resolved
/// IS the capability asked for, word for word — a substitution is
/// refused, no rule of the foundation allows one — and that the
/// capability is one the product DECLARED. The demand is a pure
/// carrier and holds no gathering; the resolution is the first voice
/// that does, so the declaration is answered here, once.
final class MentoraCapabilityResolution {
  /// The demand this resolution answers.
  final MentoraCapabilityRequest request;

  /// The capability the demand was resolved to.
  final MentoraCapability resolvedCapability;

  const MentoraCapabilityResolution({
    required this.request,
    required this.resolvedCapability,
  });

  /// What the resolution refuses — fail closed.
  void verify(MentoraCapabilityRegistry registry) {
    request.verify();

    if (resolvedCapability != request.capability) {
      throw StateError(
        'A resolution answers the demand it was given: resolving '
        '"${resolvedCapability.id}" for a demand that asked for '
        '"${request.capability.id}" is a substitution, and no rule of '
        'the foundation allows one.',
      );
    }
    if (!registry.capabilities.contains(resolvedCapability)) {
      throw StateError(
        'A demand can only be resolved to a capability the product '
        'declared: "${resolvedCapability.id}" as resolved is not one '
        'of them.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraCapabilityResolution &&
        other.request == request &&
        other.resolvedCapability == resolvedCapability;
  }

  @override
  int get hashCode => Object.hash(request, resolvedCapability);
}
