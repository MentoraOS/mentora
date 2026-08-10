import 'mentora_contract.dart';

/// The demand concerning a contract. Nothing else.
///
/// A request CARRIES: the contract asked about travels whole and
/// strictly intact, and that is the entirety of what a request does.
/// It decides nothing and executes nothing — what is done with the
/// demand belongs to whoever the application hands it to, later,
/// elsewhere, never here.
///
/// It invents no refusal: what a contract owes, the contract itself
/// refuses, with its own voice. Whether the contract asked about is
/// one the product DECLARED is a question that needs the gathering,
/// and the first voice that holds the gathering is the answer — never
/// the demand.
final class MentoraContractRequest {
  /// The contract asked about, carried whole — never an address,
  /// never a guess.
  final MentoraContract contract;

  const MentoraContractRequest({required this.contract});

  /// What the request refuses — fail closed.
  ///
  /// The contract speaks with its own voice; a carrier adds none.
  void verify() {
    contract.verify();
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraContractRequest && other.contract == contract;
  }

  @override
  int get hashCode => contract.hashCode;
}
