import '../models/escrow.dart';
import '../models/escrow_result.dart';
import 'escrow_repository.dart';

class MemoryEscrowRepository implements EscrowRepository {
  final Map<String, Escrow> _escrows = {};

  @override
  Future<EscrowResult> create(Escrow escrow) async {
    _escrows[escrow.id] = escrow;

    return EscrowResult(success: true, escrow: escrow);
  }

  @override
  Future<EscrowResult> update(Escrow escrow) async {
    _escrows[escrow.id] = escrow;

    return EscrowResult(success: true, escrow: escrow);
  }

  @override
  Future<Escrow?> findById(String escrowId) async {
    return _escrows[escrowId];
  }

  @override
  Future<Escrow?> findByPayment(String paymentId) async {
    for (final escrow in _escrows.values) {
      if (escrow.paymentId == paymentId) {
        return escrow;
      }
    }

    return null;
  }

  @override
  Future<Escrow?> findByConsultation(String consultationId) async {
    for (final escrow in _escrows.values) {
      if (escrow.consultationId == consultationId) {
        return escrow;
      }
    }

    return null;
  }
}
