import 'mentora_navigation_announcement.dart';
import 'mentora_navigation_graph.dart';
import 'mentora_navigation_request.dart';
import 'mentora_navigation_resolution.dart';
import 'mentora_navigation_state.dart';
import 'mentora_route.dart';

/// The order in which the truths of navigation talk to one another.
/// Nothing else.
///
/// The coordinator is NOT a machine. It moves no one, decides nothing,
/// changes no state and produces no effect. Every truth it composes
/// already exists, whole, before the coordinator is written — what the
/// coordinator owns is the DIALOGUE: which voice speaks first, and
/// what must agree between them for the whole to stand.
///
/// The official order is the order of the questions themselves:
///
///  1. what exists, and where          — the registry, through the
///  2. what is possible                  graph and the state
///  3. where the person is
///  4. what is asked                   — the request
///  5. what was resolved               — the resolution
///  6. what the workspace is told      — the announcement
///
/// The coordinator never answers in another voice's place. It does not
/// know why a demand was made, does not rule on whether the passage
/// asked for is open — that answer belongs to the graph, given to
/// whoever decides, later, elsewhere — and it does not resolve a
/// place in the state's stead. What it verifies of its own is only
/// what no single voice can see: that the answer of this dialogue
/// answers THIS dialogue's demand, and that the echo repeats the
/// truth, word for word.
final class MentoraNavigationCoordinator {
  /// Where the person is — which carries the one topology, which
  /// carries the one gathering: one holder at every level.
  final MentoraNavigationState state;

  /// What is asked.
  final MentoraNavigationRequest request;

  /// What was resolved.
  final MentoraNavigationResolution resolution;

  /// What the workspace is told.
  final MentoraNavigationAnnouncement announcement;

  const MentoraNavigationCoordinator({
    required this.state,
    required this.request,
    required this.resolution,
    required this.announcement,
  });

  /// The one topology of the dialogue — an alias over the one holder,
  /// never a second field.
  MentoraNavigationGraph get graph => state.graph;

  /// The one gathering of the dialogue — an alias over the one
  /// holder, never a second field.
  MentoraRouteRegistry get registry => state.graph.registry;

  /// What the dialogue refuses — fail closed, in the official order.
  ///
  /// Each voice speaks for itself, in the order of the questions; the
  /// coordinator adds only the agreements between them.
  void verify() {
    // 1..3 — what exists, what is possible, where the person is: the
    // state's chain of voices, each its own.
    state.verify();

    // 4 — what is asked.
    request.verify(registry);

    // 5 — what was resolved, and the first agreement: the answer of
    // this dialogue answers THIS dialogue's demand.
    resolution.verify(registry);
    if (resolution.request != request) {
      throw StateError(
        'The resolution of this dialogue answers another demand: a '
        'dialogue has one demand, and its answer is the answer to it.',
      );
    }

    // 6 — what the workspace is told, and the second agreement: the
    // echo repeats the truth, word for word.
    if (announcement.destinationId.isEmpty) {
      throw StateError(
        'An announcement without an identity tells a context nothing, '
        'and nothing is not an announcement.',
      );
    }
    if (announcement.destinationId != state.activeRouteId) {
      throw StateError(
        'The echo repeats the truth, word for word: announcing '
        '"${announcement.destinationId}" while the person is in '
        '"${state.activeRouteId}" makes the echo a second truth, and '
        'there is no second truth.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraNavigationCoordinator &&
        other.state == state &&
        other.request == request &&
        other.resolution == resolution &&
        other.announcement == announcement;
  }

  @override
  int get hashCode => Object.hash(state, request, resolution, announcement);
}
