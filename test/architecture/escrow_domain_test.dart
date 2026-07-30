import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/escrow/domains/escrow_domain.dart';
import 'package:mentora/core/escrow/models/escrow.dart';
import 'package:mentora/core/escrow/models/escrow_status.dart';
import 'package:mentora/core/escrow/repositories/memory_escrow_repository.dart';

void main() {
  group('Escrow Domain', () {
    test('should lock pending escrow', () async {
      final repository = MemoryEscrowRepository();
      final domain = EscrowDomain(repository: repository);

      const escrow = Escrow(
        id: 'escrow_001',
        paymentId: 'payment_001',
        consultationId: 'consultation_001',
        payerId: 'client_001',
        receiverId: 'expert_001',
        amount: 100,
        currency: 'USD',
        status: EscrowStatus.pending,
      );

      await domain.create(escrow);

      final result = await domain.lock(escrow);

      expect(result.success, isTrue);
      expect(result.escrow?.status, EscrowStatus.locked);
    });

    test('should release locked escrow', () async {
      final repository = MemoryEscrowRepository();
      final domain = EscrowDomain(repository: repository);

      const escrow = Escrow(
        id: 'escrow_002',
        paymentId: 'payment_002',
        consultationId: 'consultation_002',
        payerId: 'client_001',
        receiverId: 'expert_001',
        amount: 100,
        currency: 'USD',
        status: EscrowStatus.locked,
      );

      await domain.create(escrow);

      final result = await domain.release(escrow);

      expect(result.success, isTrue);
      expect(result.escrow?.status, EscrowStatus.released);
    });

    test('should refund locked escrow', () async {
      final repository = MemoryEscrowRepository();
      final domain = EscrowDomain(repository: repository);

      const escrow = Escrow(
        id: 'escrow_003',
        paymentId: 'payment_003',
        consultationId: 'consultation_003',
        payerId: 'client_001',
        receiverId: 'expert_001',
        amount: 100,
        currency: 'USD',
        status: EscrowStatus.locked,
      );

      await domain.create(escrow);

      final result = await domain.refund(escrow);

      expect(result.success, isTrue);
      expect(result.escrow?.status, EscrowStatus.refunded);
    });

    test('should reject released to refunded transition', () async {
      final repository = MemoryEscrowRepository();
      final domain = EscrowDomain(repository: repository);

      const escrow = Escrow(
        id: 'escrow_004',
        paymentId: 'payment_004',
        consultationId: 'consultation_004',
        payerId: 'client_001',
        receiverId: 'expert_001',
        amount: 100,
        currency: 'USD',
        status: EscrowStatus.released,
      );

      await domain.create(escrow);

      final result = await domain.refund(escrow);

      expect(result.success, isFalse);
    });
  });
}
