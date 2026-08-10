import 'mentora_contract.dart';
import 'mentora_contract_registry.dart';
import 'mentora_contract_request.dart';

/// The official answer given to a contract request. Nothing else.
///
/// A resolution decides nothing: the deciding has already happened
/// when a resolution is written. It STATES one fact — "this demand
/// concerns this contract" — and a fact, once stated, never moves
/// again.
///
/// The demand speaks always before the resolution — with the
/// contract's voice through it. Then the resolution verifies what it
/// owns, and it owns two things here: that the contract resolved IS
/// the contract asked about, word for word — a substitution is
/// refused, no rule of the foundation allows one — and that the
/// contract is one the product DECLARED. The demand is a pure carrier
/// and holds no gathering; the resolution is the first voice that
/// does, so the declaration is answered here, once.
final class MentoraContractResolution {
  /// The demand this resolution answers.
  final MentoraContractRequest request;

  /// The contract the demand was resolved to.
  final MentoraContract resolvedContract;

  const MentoraContractResolution({
    required this.request,
    required this.resolvedContract,
  });

  /// What the resolution refuses — fail closed.
  void verify(MentoraContractRegistry registry) {
    request.verify();

    if (resolvedContract != request.contract) {
      throw StateError(
        'A resolution answers the demand it was given: resolving '
        '"${resolvedContract.id}" for a demand that asked about '
        '"${request.contract.id}" is a substitution, and no rule of '
        'the foundation allows one.',
      );
    }
    if (!registry.contracts.contains(resolvedContract)) {
      throw StateError(
        'A demand can only be resolved to a contract the product '
        'declared: "${resolvedContract.id}" as resolved is not one of '
        'them.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraContractResolution &&
        other.request == request &&
        other.resolvedContract == resolvedContract;
  }

  @override
  int get hashCode => Object.hash(request, resolvedContract);
}
