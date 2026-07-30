import '../domains/escrow_domain.dart';
import '../models/escrow.dart';
import '../models/escrow_result.dart';

import '../../financial/ledger/posting/services/escrow_posting_service.dart';

class EscrowEngine {
  final EscrowDomain domain;
  final EscrowPostingService postingService;

  const EscrowEngine({required this.domain, required this.postingService});

  Future<EscrowResult> create(Escrow escrow) {
    return domain.create(escrow);
  }

  Future<EscrowResult> lock(
    Escrow escrow, {
    required int amountMinor,
    required DateTime occurredAt,
  }) async {
    final result = await domain.lock(escrow);

    final transitionedEscrow = result.escrow;

    if (!result.success || transitionedEscrow == null) {
      return result;
    }

    await postingService.onLocked(
      escrow: transitionedEscrow,
      amountMinor: amountMinor,
      occurredAt: occurredAt,
    );

    return result;
  }

  Future<EscrowResult> release(
    Escrow escrow, {
    required int amountMinor,
    required DateTime occurredAt,
  }) async {
    final result = await domain.release(escrow);

    final transitionedEscrow = result.escrow;

    if (!result.success || transitionedEscrow == null) {
      return result;
    }

    await postingService.onReleased(
      escrow: transitionedEscrow,
      amountMinor: amountMinor,
      occurredAt: occurredAt,
    );

    return result;
  }

  Future<EscrowResult> refund(
    Escrow escrow, {
    required int amountMinor,
    required DateTime occurredAt,
  }) async {
    final result = await domain.refund(escrow);

    final transitionedEscrow = result.escrow;

    if (!result.success || transitionedEscrow == null) {
      return result;
    }

    await postingService.onRefunded(
      escrow: transitionedEscrow,
      amountMinor: amountMinor,
      occurredAt: occurredAt,
    );

    return result;
  }

  Future<EscrowResult> cancel(
    Escrow escrow, {
    required DateTime occurredAt,
  }) async {
    final result = await domain.cancel(escrow);

    final transitionedEscrow = result.escrow;

    if (!result.success || transitionedEscrow == null) {
      return result;
    }

    await postingService.onCancelled(
      escrow: transitionedEscrow,
      occurredAt: occurredAt,
    );

    return result;
  }

  Future<Escrow?> findById(String escrowId) {
    return domain.findById(escrowId);
  }

  Future<Escrow?> findByPayment(String paymentId) {
    return domain.findByPayment(paymentId);
  }

  Future<Escrow?> findByConsultation(String consultationId) {
    return domain.findByConsultation(consultationId);
  }
}
