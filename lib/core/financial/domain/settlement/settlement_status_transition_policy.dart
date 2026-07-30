import 'settlement_exception.dart';
import 'settlement_status.dart';

/// Defines the valid lifecycle transitions of a financial settlement.
///
/// This policy protects the settlement aggregate from invalid state changes
/// and keeps transition rules centralized in the domain layer.
final class SettlementStatusTransitionPolicy {
  const SettlementStatusTransitionPolicy._();

  static bool canTransition({
    required SettlementStatus from,
    required SettlementStatus to,
  }) {
    if (from == to) {
      return true;
    }

    return switch (from) {
      SettlementStatus.pending =>
        to == SettlementStatus.processing ||
            to == SettlementStatus.cancelled ||
            to == SettlementStatus.failed,

      SettlementStatus.processing =>
        to == SettlementStatus.completed ||
            to == SettlementStatus.failed ||
            to == SettlementStatus.cancelled,

      SettlementStatus.completed => to == SettlementStatus.refunded,

      SettlementStatus.failed =>
        to == SettlementStatus.processing || to == SettlementStatus.cancelled,

      SettlementStatus.cancelled => false,

      SettlementStatus.refunded => false,
    };
  }

  static void ensureCanTransition({
    required SettlementStatus from,
    required SettlementStatus to,
  }) {
    if (canTransition(from: from, to: to)) {
      return;
    }

    throw SettlementException(
      'Invalid settlement status transition: '
      '${from.name} -> ${to.name}.',
    );
  }
}
