import 'mentora_contract.dart';

/// The official set of the contracts. Nothing else.
///
/// A registry is where duplication becomes checkable: a single
/// contract cannot know its neighbours, so the promise "two contracts
/// never share one identity" is kept here — once, for the whole
/// product.
///
/// A registry is declared once: like the product's topology and the
/// place its state lives, the set of its contracts is not a value
/// that varies — two gatherings are two products.
final class MentoraContractRegistry {
  /// The contracts, in the order the product declares them.
  final List<MentoraContract> contracts;

  const MentoraContractRegistry({required this.contracts});

  /// What the registry refuses — fail closed.
  void verify() {
    if (contracts.isEmpty) {
      throw StateError(
        'A product without a contract promises nothing: an empty '
        'registry is refused.',
      );
    }
    final identities = <String>{};
    for (final contract in contracts) {
      contract.verify();
      if (!identities.add(contract.id)) {
        throw StateError('Two contracts never share one identity.');
      }
    }
  }
}
