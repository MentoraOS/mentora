import 'mentora_contract_registry.dart';
import 'mentora_contract_request.dart';
import 'mentora_contract_resolution.dart';

/// The order in which the truths of the contracts talk to one
/// another. Nothing else.
///
/// The coordinator is NOT a machine. It enforces nothing, decides
/// nothing and produces no effect. Every truth it composes already
/// exists, whole, before the coordinator is written — what it owns is
/// the DIALOGUE: which voice speaks first, and what must agree
/// between them for the whole to stand.
///
/// The official order is the order of the questions themselves: what
/// the product declares, what is asked about it, what was answered.
/// The coordinator adds only the agreement no single voice can see:
/// that the answer of this dialogue answers THIS dialogue's demand.
final class MentoraContractCoordinator {
  /// The one gathering of the product's contracts.
  final MentoraContractRegistry registry;

  /// What is asked.
  final MentoraContractRequest request;

  /// What was answered.
  final MentoraContractResolution resolution;

  const MentoraContractCoordinator({
    required this.registry,
    required this.request,
    required this.resolution,
  });

  /// What the dialogue refuses — fail closed, in the official order.
  ///
  /// Each voice speaks for itself, in the order of the questions; the
  /// coordinator adds only the agreement between them.
  void verify() {
    // 1 — what the product declares: the gathering's own chain of
    // voices.
    registry.verify();

    // 2 — what is asked about it.
    request.verify(registry);

    // 3 — what was answered, and the agreement: the answer of this
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
  /// A product declares its contracts once: two registry objects are
  /// two products, and a dialogue happens in exactly one.
  @override
  bool operator ==(Object other) {
    return other is MentoraContractCoordinator &&
        identical(other.registry, registry) &&
        other.request == request &&
        other.resolution == resolution;
  }

  @override
  int get hashCode => Object.hash(registry, request, resolution);
}
