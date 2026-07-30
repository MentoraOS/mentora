import '../../../../domain/settlement/settlement_repository.dart';
import '../../../../domain/settlement/settlement_status.dart';

import 'finalize_consultation_settlement_context.dart';

/// Persists the failed state of a settlement when finalization is interrupted.
///
/// This handler is not part of the normal linear pipeline. It must be invoked
/// only from the workflow failure path after processing has started.
final class SettlementFailureHandler {
  const SettlementFailureHandler({required SettlementRepository repository})
    : _repository = repository;

  final SettlementRepository _repository;

  Future<void> handle({
    required FinalizeConsultationSettlementContext context,
    required Object error,
  }) async {
    final settlement = context.settlement;

    // No aggregate has been built yet, so there is nothing to compensate.
    if (settlement == null) {
      return;
    }

    // Never overwrite a successful or otherwise terminal settlement.
    if (settlement.status.isFinal) {
      return;
    }

    // A pending settlement has not yet entered the transactional section.
    if (settlement.status == SettlementStatus.pending) {
      return;
    }

    final failedSettlement = settlement.markFailed(
      reason: _failureReason(error),
    );

    await _repository.save(
      failedSettlement,
      expectedVersion: settlement.version,
    );

    context.settlement = failedSettlement;
  }

  String _failureReason(Object error) {
    final normalized = error.toString().trim();

    if (normalized.isEmpty) {
      return 'Unknown settlement processing failure.';
    }

    // Prevent unbounded infrastructure messages from being persisted.
    const maximumLength = 500;

    if (normalized.length <= maximumLength) {
      return normalized;
    }

    return normalized.substring(0, maximumLength);
  }
}
