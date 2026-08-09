import 'mentora_route.dart';

/// The demand to go to a place. Nothing else.
///
/// A request is not the movement, not the result and not the
/// navigation: it says "someone asks to go here", and it stops there.
/// Whether the demand is honoured belongs to whoever the application
/// hands it to — later, elsewhere, never here.
///
/// It carries the place asked for WHOLE — the official route, as the
/// product declared it — and the type says a demand cannot ask for
/// nothing. It carries no reason: no declarative reason exists in the
/// foundation, and a field nothing defines would be an invention.
///
/// The boundary stands on every side: the request does not know where
/// the person is (that is the state), does not know what is possible
/// (that is the graph), does not know what a context was told (that is
/// the announcement), and does not define the place (that is the
/// route). It asks. That is all it does.
final class MentoraNavigationRequest {
  /// The place asked for, carried whole — never an address, never a
  /// position, never a guess.
  final MentoraRoute route;

  const MentoraNavigationRequest({required this.route});

  /// What the request refuses — fail closed.
  ///
  /// The route speaks first with its own voice; then the demand must
  /// ask for a place the product DECLARED — word for word: a place of
  /// the same name that the product never declared is not a place, it
  /// is a forgery.
  void verify(MentoraRouteRegistry registry) {
    route.verify();

    if (!registry.routes.contains(route)) {
      throw StateError(
        'A person can only ask to go to a place the product declared: '
        '"${route.id}" as asked for is not one of them.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraNavigationRequest && other.route == route;
  }

  @override
  int get hashCode => route.hashCode;
}
