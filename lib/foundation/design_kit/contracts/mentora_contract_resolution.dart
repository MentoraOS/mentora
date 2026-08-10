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
/// It answers THE demand it was given: resolving a different contract
/// than the one asked about is not answering, it is substituting —
/// and no rule of the foundation allows a demand to be answered with
/// another contract.
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
  ///
  /// The demand speaks first with its own voice — and through it, the
  /// contract and the gathering with theirs. Then the resolution
  /// verifies the only thing it owns: that the contract resolved IS
  /// the contract asked about, word for word.
  void verify(MentoraContractRegistry registry) {
    request.verify(registry);

    if (resolvedContract != request.contract) {
      throw StateError(
        'A resolution answers the demand it was given: resolving '
        '"${resolvedContract.id}" for a demand that asked about '
        '"${request.contract.id}" is a substitution, and no rule of '
        'the foundation allows one.',
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
