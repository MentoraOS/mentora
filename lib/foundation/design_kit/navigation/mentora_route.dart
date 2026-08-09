/// The official definition of a place in Mentora.
///
/// This file imports NOTHING — not the framework, not the platform,
/// not another layer of the Kit. A place is a fact of the product, and
/// a fact needs nothing to be true.
library;

/// The official natures a place can have.
///
/// The registry is CLOSED: a product never invents a nature, and an
/// unknown one cannot exist — the compiler refuses it before any code
/// runs. Adding a nature is a deliberate act of the Design System,
/// never a local decision of a screen.
enum MentoraRouteNature {
  /// A place reached BEFORE the working context exists: where a person
  /// enters, proves who they are, or is welcomed.
  entry,

  /// A place of the principal level: reachable from the way through
  /// the product itself.
  principal,

  /// A place reached from WITHIN another place: the detail of an
  /// entity, a step of a work, a page of a section.
  interior,
}

/// A place where a person can go. Nothing else.
///
/// A route DEFINES the place: its identity — stable for as long as the
/// product exists, never a position, never an address — its official
/// name, what completes that name when something must be said, and its
/// official nature. That nature is the only metadata navigation needs
/// today; a metadata nothing consumes would be dead weight, and none
/// is invented here.
///
/// A route never navigates, never builds, and knows no framework, no
/// platform, no backend and no screen. It carries no state and cannot
/// change: two routes with the same words ARE the same route, wherever
/// and whenever they were written.
final class MentoraRoute {
  /// What this place IS — stable forever, never a position.
  final String id;

  /// What it is called. The application owns every string
  /// (Localization Engine); the Kit composes none.
  final String name;

  /// What completes the name, when something must be said.
  final String? description;

  /// Which official nature this place has.
  final MentoraRouteNature nature;

  const MentoraRoute({
    required this.id,
    required this.name,
    required this.nature,
    this.description,
  });

  /// What a route refuses — fail closed.
  ///
  /// A refusal is verified where routes are gathered, so that no place
  /// of the product can exist half-defined.
  void verify() {
    if (id.isEmpty) {
      throw StateError('A place without an identity is not a place.');
    }
    if (name.isEmpty) {
      throw StateError(
        'A place without a name cannot be offered: a person always '
        'knows where they are going.',
      );
    }
    if (description != null && description!.isEmpty) {
      throw StateError(
        'A completion is said or it is not: an empty description is '
        'an ambiguity, and an ambiguity is refused.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraRoute &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.nature == nature;
  }

  @override
  int get hashCode => Object.hash(id, name, description, nature);
}

/// The one gathering of the places of the product.
///
/// A registry is where duplication becomes checkable: a single route
/// cannot know its neighbours, so the promise "two places never share
/// one identity" is kept here — once, for the whole product.
final class MentoraRouteRegistry {
  /// The places, in the order the product declares them.
  final List<MentoraRoute> routes;

  const MentoraRouteRegistry({required this.routes});

  /// What the registry refuses — fail closed.
  void verify() {
    if (routes.isEmpty) {
      throw StateError(
        'A product without a place has nowhere for a person to go: an '
        'empty registry is refused.',
      );
    }
    final identities = <String>{};
    for (final route in routes) {
      route.verify();
      if (!identities.add(route.id)) {
        throw StateError('Two places never share one identity.');
      }
    }
  }
}
