import '../models/escrow.dart';
import '../models/escrow_result.dart';
import '../models/escrow_status.dart';
import '../repositories/escrow_repository.dart';
import '../services/escrow_state_machine.dart';

class EscrowDomain {
  final EscrowRepository repository;
  final EscrowStateMachine stateMachine;

  const EscrowDomain({
    required this.repository,
    this.stateMachine = const EscrowStateMachine(),
  });

  Future<EscrowResult> create(Escrow escrow) {
    return repository.create(escrow);
  }

  Future<Escrow?> findById(String escrowId) {
    return repository.findById(escrowId);
  }

  Future<Escrow?> findByPayment(String paymentId) {
    return repository.findByPayment(paymentId);
  }

  Future<Escrow?> findByConsultation(String consultationId) {
    return repository.findByConsultation(consultationId);
  }

  Future<EscrowResult> lock(Escrow escrow) {
    return transitionTo(escrow, EscrowStatus.locked);
  }

  Future<EscrowResult> release(Escrow escrow) {
    return transitionTo(escrow, EscrowStatus.released);
  }

  Future<EscrowResult> refund(Escrow escrow) {
    return transitionTo(escrow, EscrowStatus.refunded);
  }

  Future<EscrowResult> cancel(Escrow escrow) {
    return transitionTo(escrow, EscrowStatus.cancelled);
  }

  Future<EscrowResult> transitionTo(Escrow escrow, EscrowStatus nextStatus) {
    final canMove = stateMachine.canTransition(
      from: escrow.status,
      to: nextStatus,
    );

    if (!canMove) {
      return Future.value(
        EscrowResult(
          success: false,
          message: 'Invalid escrow transition',
          escrow: escrow,
        ),
      );
    }

    return repository.update(escrow.copyWith(status: nextStatus));
  }
}
