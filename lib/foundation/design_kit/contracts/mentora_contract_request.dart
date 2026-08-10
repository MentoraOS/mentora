import 'mentora_contract.dart';
import 'mentora_contract_registry.dart';

/// The demand concerning a contract. Nothing else.
///
/// A request says "someone asks about this contract", and it stops
/// there. What is done with the demand belongs to whoever the
/// application hands it to — later, elsewhere, never here.
///
/// It carries the contract asked about WHOLE — as the product
/// declared it — and the type says a demand cannot ask about nothing.
/// The demand must concern a contract the product DECLARED, word for
/// word: a contract of the same name the product never declared is
/// not a contract, it is a forgery.
final class MentoraContractRequest {
  /// The contract asked about, carried whole — never an address,
  /// never a guess.
  final MentoraContract contract;

  const MentoraContractRequest({required this.contract});

  /// What the request refuses — fail closed.
  ///
  /// The contract speaks first with its own voice; then the demand
  /// must concern a contract the product declared.
  void verify(MentoraContractRegistry registry) {
    contract.verify();

    if (!registry.contracts.contains(contract)) {
      throw StateError(
        'A person can only ask about a contract the product declared: '
        '"${contract.id}" as asked about is not one of them.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraContractRequest && other.contract == contract;
  }

  @override
  int get hashCode => contract.hashCode;
}
