import 'mentora_navigation_graph.dart';
import 'mentora_route.dart';

/// Where the person currently is in the official graph. Nothing else.
///
/// The boundary is absolute, and it is the whole reason this type
/// exists: the GRAPH describes what is possible, and never knows where
/// the person is; the STATE describes where the person is, and never
/// decides what is possible. Asked what could happen next, the state
/// has no answer to give — that question belongs to the graph, and the
/// state does not repeat its voice.
///
/// It never navigates, never builds and never decides. It remembers no
/// history: where the person WAS is not a fact of where they ARE, and
/// nothing here accumulates. Moving is not a mutation either — the
/// application announces a new state, whole, and the old one never
/// changes.
final class MentoraNavigationState {
  /// The official topology this position is read against.
  final MentoraNavigationGraph graph;

  /// The place the person is in — an identity of the graph, stable
  /// forever, never a position in a list.
  final String activeRouteId;

  const MentoraNavigationState({
    required this.graph,
    required this.activeRouteId,
  });

  /// The place itself, as the product defines it.
  ///
  /// Asking for a place the product does not have is refused: a state
  /// never guesses, and never invents a place to stand in.
  MentoraRoute get activeRoute {
    for (final route in graph.registry.routes) {
      if (route.id == activeRouteId) return route;
    }
    throw StateError(
      '"$activeRouteId" is not a place this product has: a person '
      'cannot be somewhere the product does not go.',
    );
  }

  /// What the state refuses — fail closed.
  ///
  /// The graph verifies what is possible — with its own voice; the
  /// state verifies only what it owns: that the person stands in a
  /// place the product has.
  void verify() {
    graph.verify();

    if (activeRouteId.isEmpty) {
      throw StateError(
        'A person is always somewhere: a state without a place says '
        'nothing, and nothing is not a state.',
      );
    }
    // Resolving the active place refuses an identity the graph does
    // not know — through the one accessor, so the refusal has exactly
    // one voice.
    activeRoute;
  }

  /// Two states are the same position in the same topology.
  ///
  /// A product declares its topology once: two graph objects are two
  /// topologies, and standing in the same-named place of another
  /// topology is not standing in the same place.
  @override
  bool operator ==(Object other) {
    return other is MentoraNavigationState &&
        identical(other.graph, graph) &&
        other.activeRouteId == activeRouteId;
  }

  @override
  int get hashCode => Object.hash(graph, activeRouteId);
}
