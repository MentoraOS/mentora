import 'mentora_capability_registry.dart';
import 'mentora_capability_request.dart';
import 'mentora_capability_resolution.dart';

/// The order in which the truths of the capabilities talk to one
/// another. Nothing else.
///
/// The coordinator is NOT a machine. It decides nothing and produces
/// no effect. Every truth it composes already exists, whole, before
/// the coordinator is written — what it owns is the DIALOGUE: which
/// voice speaks first, and what must agree between them for the whole
/// to stand.
///
/// The official order is the order of the questions themselves: what
/// the product is able to do, what is asked of it, what was resolved.
/// The coordinator invents no refusal: it adds only the agreement no
/// single voice can see — that the answer of this dialogue answers
/// THIS dialogue's demand.
final class MentoraCapabilityCoordinator {
  /// The one gathering of the product's capabilities.
  final MentoraCapabilityRegistry registry;

  /// What is asked.
  final MentoraCapabilityRequest request;

  /// What was resolved.
  final MentoraCapabilityResolution resolution;

  const MentoraCapabilityCoordinator({
    required this.registry,
    required this.request,
    required this.resolution,
  });

  /// What the dialogue refuses — fail closed, in the official order.
  void verify() {
    // 1 — what the product is able to do: the gathering's own chain
    // of voices.
    registry.verify();

    // 2 — what is asked of it: the carrier, with the capability's
    // voice through it.
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
  /// A product declares its capabilities once: two registry objects
  /// are two products, and a dialogue happens in exactly one.
  @override
  bool operator ==(Object other) {
    return other is MentoraCapabilityCoordinator &&
        identical(other.registry, registry) &&
        other.request == request &&
        other.resolution == resolution;
  }

  @override
  int get hashCode => Object.hash(registry, request, resolution);
}
