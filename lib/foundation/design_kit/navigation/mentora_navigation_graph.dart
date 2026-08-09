import 'mentora_route.dart';

/// One allowed passage between two places.
///
/// A transition says one thing: FROM this place, a person may go TO
/// that place. It carries identities and nothing else — no gesture, no
/// movement, no animation, no history. How the passage happens is not
/// a fact of the topology, and it does not live here.
///
/// A place never leads to itself: being somewhere is not a way of
/// going there, so a self-referring passage is refused by the graph.
final class MentoraTransition {
  /// The place the passage starts from.
  final String fromRouteId;

  /// The place the passage leads to.
  final String toRouteId;

  const MentoraTransition({required this.fromRouteId, required this.toRouteId});

  @override
  bool operator ==(Object other) {
    return other is MentoraTransition &&
        other.fromRouteId == fromRouteId &&
        other.toRouteId == toRouteId;
  }

  @override
  int get hashCode => Object.hash(fromRouteId, toRouteId);
}

/// The official topology of navigation: which places can lead to
/// which other places. Nothing else.
///
/// The graph does not gather the places — the registry is the one
/// gathering of the product, and the graph COMPOSES it. What the
/// graph adds is the topology alone: the one place a person enters
/// by, and the passages the product allows.
///
/// It never navigates, never builds and never decides: it does not
/// know where a person is, remembers nothing of where they have been,
/// and holds no way of moving anyone. Asked what a place leads to, it
/// answers with what was declared — exactly that, every time.
///
/// The entry is ONE place, and the type says so: a second entry
/// cannot be written, because there is nowhere to write it.
final class MentoraNavigationGraph {
  /// The one gathering of the places of the product.
  final MentoraRouteRegistry registry;

  /// The place a person enters the product by.
  final String entryRouteId;

  /// The passages the product allows, each declared once.
  final List<MentoraTransition> transitions;

  const MentoraNavigationGraph({
    required this.registry,
    required this.entryRouteId,
    required this.transitions,
  });

  /// What the graph refuses — fail closed.
  ///
  /// The registry verifies the places; the graph verifies only what
  /// it owns: the entry, the passages, and the promise that no place
  /// of the product is out of reach.
  void verify() {
    registry.verify();

    if (entryRouteId.isEmpty) {
      throw StateError(
        'A product is entered somewhere: a graph without an entry '
        'leads a person nowhere.',
      );
    }
    final identities = {for (final route in registry.routes) route.id};
    if (!identities.contains(entryRouteId)) {
      throw StateError(
        'The entry is not a place this product has: a graph never '
        'guesses where a person comes in.',
      );
    }

    final declared = <MentoraTransition>{};
    for (final transition in transitions) {
      if (!identities.contains(transition.fromRouteId)) {
        throw StateError(
          'A passage from a place this product does not have leads '
          'from nowhere: "${transition.fromRouteId}" is not a place.',
        );
      }
      if (!identities.contains(transition.toRouteId)) {
        throw StateError(
          'A passage to a place this product does not have leads '
          'nowhere: "${transition.toRouteId}" is not a place.',
        );
      }
      if (transition.fromRouteId == transition.toRouteId) {
        throw StateError(
          'A place never leads to itself: being somewhere is not a '
          'way of going there.',
        );
      }
      if (!declared.add(transition)) {
        throw StateError('A passage is declared once, never twice.');
      }
    }

    // Every place of the product can be reached from the entry: a
    // place no path leads to is not a place a person can go, and a
    // topology that promises one is refused.
    final reached = <String>{entryRouteId};
    final frontier = <String>[entryRouteId];
    while (frontier.isNotEmpty) {
      final from = frontier.removeLast();
      for (final transition in transitions) {
        if (transition.fromRouteId == from &&
            reached.add(transition.toRouteId)) {
          frontier.add(transition.toRouteId);
        }
      }
    }
    for (final route in registry.routes) {
      if (!reached.contains(route.id)) {
        throw StateError(
          'No path leads to "${route.id}": a place a person cannot '
          'reach is a promise the product does not keep.',
        );
      }
    }
  }

  /// The places one may go to from [routeId] — exactly what was
  /// declared, never computed, never completed.
  ///
  /// Asking about a place the product does not have is refused: the
  /// topology describes the product, and never guesses beyond it.
  Set<String> reachableFrom(String routeId) {
    if (!registry.routes.any((route) => route.id == routeId)) {
      throw StateError(
        '"$routeId" is not a place this product has: the topology '
        'never guesses.',
      );
    }
    return {
      for (final transition in transitions)
        if (transition.fromRouteId == routeId) transition.toRouteId,
    };
  }

  /// Whether the passage from one place to another was declared.
  bool allows({required String fromRouteId, required String toRouteId}) {
    return transitions.contains(
      MentoraTransition(fromRouteId: fromRouteId, toRouteId: toRouteId),
    );
  }
}
