import 'mentora_capability.dart';

/// The official set of the capabilities. Nothing else.
///
/// A registry is where duplication becomes checkable: a single
/// capability cannot know its neighbours, so the promise "two
/// capabilities never share one identity" is kept here — once, for
/// the whole product.
///
/// A registry is declared once: what a product is able to do is not a
/// value that varies — two gatherings are two products.
final class MentoraCapabilityRegistry {
  /// The capabilities, in the order the product declares them.
  final List<MentoraCapability> capabilities;

  const MentoraCapabilityRegistry({required this.capabilities});

  /// What the registry refuses — fail closed.
  void verify() {
    if (capabilities.isEmpty) {
      throw StateError(
        'A product without a capability is able to do nothing: an '
        'empty registry is refused.',
      );
    }
    final identities = <String>{};
    for (final capability in capabilities) {
      capability.verify();
      if (!identities.add(capability.id)) {
        throw StateError('Two capabilities never share one identity.');
      }
    }
  }
}
