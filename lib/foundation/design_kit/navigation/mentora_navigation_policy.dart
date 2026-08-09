import 'mentora_navigation_graph.dart';
import 'mentora_navigation_request.dart';
import 'mentora_route.dart';

/// The official authority of the rules of navigation. Nothing else.
///
/// The policy answers ONE question — "does this demand respect the
/// rules of the product?" — and it answers it with a yes or a no.
/// A no is an ANSWER, not a refusal: a well-formed demand that the
/// rules do not authorise is answered, calmly, with false. A refusal
/// is for malformed things only, and it fails closed.
///
/// It never navigates, never orchestrates and never decides the
/// movement: whether anyone GOES anywhere after the answer belongs to
/// whoever asked — later, elsewhere, never here. Pronouncing the rules
/// moves no one.
///
/// It composes the topology — and through it, the one gathering — and
/// it consults their voices, never repeats them: the graph states
/// which passages the product declared; the policy pronounces the
/// authority over a demand. The one rule the product declares today
/// is that what is authorised is what was declared — no other rule
/// exists in the foundation, and none is invented here.
///
/// It does not know where the person is: the origin of a demand
/// arrives as an IDENTITY, handed by whoever asks. The truth of the
/// person's position has one owner, and the policy is not it.
final class MentoraNavigationPolicy {
  /// The one topology the authority pronounces over — which carries
  /// the one gathering: one holder at every level.
  final MentoraNavigationGraph graph;

  const MentoraNavigationPolicy({required this.graph});

  /// The one gathering of the product — an alias over the one holder,
  /// never a second field.
  MentoraRouteRegistry get registry => graph.registry;

  /// What the authority refuses of itself — fail closed.
  ///
  /// An authority over an invalid product pronounces nothing: the
  /// topology speaks first, with its own voice, and the gathering
  /// through it.
  void verify() {
    graph.verify();
  }

  /// Does the demand respect the rules of the product, asked from
  /// [fromRouteId]?
  ///
  /// Malformed inputs are refused — the demand with its own voice,
  /// and an origin that is not a place of the product with the
  /// policy's. What remains is the answer itself: yes when the
  /// product declared the passage, no when it did not — and a no is
  /// an answer, never an error.
  bool permits({
    required String fromRouteId,
    required MentoraNavigationRequest request,
  }) {
    request.verify(registry);

    if (!registry.routes.any((route) => route.id == fromRouteId)) {
      throw StateError(
        'A demand is judged from a place the product has: '
        '"$fromRouteId" is not one, and an authority never guesses '
        'where a demand was made from.',
      );
    }

    return graph.allows(fromRouteId: fromRouteId, toRouteId: request.route.id);
  }

  /// Two policies are the same authority over the same topology.
  ///
  /// A product declares its topology once: two graph objects are two
  /// topologies, and an authority pronounces over exactly one.
  @override
  bool operator ==(Object other) {
    return other is MentoraNavigationPolicy && identical(other.graph, graph);
  }

  @override
  int get hashCode => graph.hashCode;
}
