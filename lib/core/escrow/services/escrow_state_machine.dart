import '../models/escrow_status.dart';

class EscrowStateMachine {
  const EscrowStateMachine();

  bool canTransition({required EscrowStatus from, required EscrowStatus to}) {
    return allowedTransitions[from]?.contains(to) ?? false;
  }

  static const Map<EscrowStatus, List<EscrowStatus>> allowedTransitions = {
    EscrowStatus.pending: [EscrowStatus.locked, EscrowStatus.cancelled],

    EscrowStatus.locked: [
      EscrowStatus.released,
      EscrowStatus.refunded,
      EscrowStatus.cancelled,
    ],

    EscrowStatus.released: [],

    EscrowStatus.refunded: [],

    EscrowStatus.cancelled: [],
  };
}
