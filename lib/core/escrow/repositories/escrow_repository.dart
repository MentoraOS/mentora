import '../models/escrow.dart';
import '../models/escrow_result.dart';

abstract class EscrowRepository {
  Future<EscrowResult> create(Escrow escrow);

  Future<EscrowResult> update(Escrow escrow);

  Future<Escrow?> findById(String escrowId);

  Future<Escrow?> findByPayment(String paymentId);

  Future<Escrow?> findByConsultation(String consultationId);
}
