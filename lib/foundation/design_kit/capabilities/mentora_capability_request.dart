import 'mentora_capability.dart';

/// The capability officially asked for. Nothing else.
///
/// A request CARRIES: the capability asked for travels whole and
/// strictly intact, and that is the entirety of what a request does.
/// It decides nothing and executes nothing — whether the demand is
/// honoured belongs to whoever the application hands it to, later,
/// elsewhere, never here.
///
/// It invents no refusal: what a capability owes, the capability
/// itself refuses, with its own voice. Whether the capability asked
/// for is one the product DECLARED is a question that needs the
/// gathering, and the first voice that holds the gathering is the
/// answer — never the demand.
final class MentoraCapabilityRequest {
  /// The capability asked for, carried whole — never an address,
  /// never a guess.
  final MentoraCapability capability;

  const MentoraCapabilityRequest({required this.capability});

  /// What the request refuses — fail closed.
  ///
  /// The capability speaks with its own voice; a carrier adds none.
  void verify() {
    capability.verify();
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraCapabilityRequest && other.capability == capability;
  }

  @override
  int get hashCode => capability.hashCode;
}
