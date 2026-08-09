import 'mentora_navigation_request.dart';
import 'mentora_route.dart';

/// The official answer given to a navigation request. Nothing else.
///
/// A resolution decides nothing: the deciding, whoever does it, has
/// already happened when a resolution is written. It executes nothing,
/// navigates nowhere, changes no state and produces no effect. It
/// STATES one fact — "this demand corresponds to this place" — and a
/// fact, once stated, never moves again.
///
/// It knows the demand it answers and the place that answered it, and
/// nothing else. And it answers THE demand it was given: resolving a
/// different place than the one asked for is not answering, it is
/// substituting — and a substitution is refused, because no rule of
/// the foundation allows a demand to be answered with another place.
final class MentoraNavigationResolution {
  /// The demand this resolution answers.
  final MentoraNavigationRequest request;

  /// The place the demand was resolved to.
  final MentoraRoute resolvedRoute;

  const MentoraNavigationResolution({
    required this.request,
    required this.resolvedRoute,
  });

  /// What the resolution refuses — fail closed.
  ///
  /// The demand speaks first with its own voice — and through it, the
  /// route and the gathering with theirs. Then the resolution verifies
  /// the only thing it owns: that the place resolved IS the place
  /// asked for, word for word. Once that holds, an unknown resolved
  /// place cannot exist — the demand already proved the place is the
  /// product's.
  void verify(MentoraRouteRegistry registry) {
    request.verify(registry);

    if (resolvedRoute != request.route) {
      throw StateError(
        'A resolution answers the demand it was given: resolving '
        '"${resolvedRoute.id}" for a demand that asked for '
        '"${request.route.id}" is a substitution, and no rule of the '
        'foundation allows one.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraNavigationResolution &&
        other.request == request &&
        other.resolvedRoute == resolvedRoute;
  }

  @override
  int get hashCode => Object.hash(request, resolvedRoute);
}
