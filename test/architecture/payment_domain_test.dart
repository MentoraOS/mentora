import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/payment/domains/payment_domain.dart';
import 'package:mentora/core/payment/models/payment.dart';
import 'package:mentora/core/payment/models/payment_method.dart';
import 'package:mentora/core/payment/models/payment_status.dart';
import 'package:mentora/core/payment/repositories/memory_payment_repository.dart';

void main() {
  group('Payment Domain', () {
    test('should authorize payment', () async {
      final repository = MemoryPaymentRepository();
      final domain = PaymentDomain(repository: repository);

      const payment = Payment(
        id: 'payment_001',
        consultationId: 'consultation_001',
        payerId: 'client_001',
        receiverId: 'expert_001',
        amount: 100,
        currency: 'USD',
        method: PaymentMethod.wallet,
        status: PaymentStatus.pending,
      );

      await domain.create(payment);

      final result = await domain.authorize(payment);

      expect(result.success, isTrue);
      expect(result.payment?.status, PaymentStatus.authorized);
    });

    test('should move authorized payment to escrow', () async {
      final repository = MemoryPaymentRepository();
      final domain = PaymentDomain(repository: repository);

      const payment = Payment(
        id: 'payment_002',
        consultationId: 'consultation_002',
        payerId: 'client_001',
        receiverId: 'expert_001',
        amount: 100,
        currency: 'USD',
        method: PaymentMethod.wallet,
        status: PaymentStatus.authorized,
      );

      await domain.create(payment);

      final result = await domain.moveToEscrow(payment);

      expect(result.success, isTrue);
      expect(result.payment?.status, PaymentStatus.escrow);
    });

    test('should release escrow payment', () async {
      final repository = MemoryPaymentRepository();
      final domain = PaymentDomain(repository: repository);

      const payment = Payment(
        id: 'payment_003',
        consultationId: 'consultation_003',
        payerId: 'client_001',
        receiverId: 'expert_001',
        amount: 100,
        currency: 'USD',
        method: PaymentMethod.wallet,
        status: PaymentStatus.escrow,
      );

      await domain.create(payment);

      final result = await domain.release(payment);

      expect(result.success, isTrue);
      expect(result.payment?.status, PaymentStatus.released);
    });

    test('should reject invalid transition released to refunded', () async {
      final repository = MemoryPaymentRepository();
      final domain = PaymentDomain(repository: repository);

      const payment = Payment(
        id: 'payment_004',
        consultationId: 'consultation_004',
        payerId: 'client_001',
        receiverId: 'expert_001',
        amount: 100,
        currency: 'USD',
        method: PaymentMethod.wallet,
        status: PaymentStatus.released,
      );

      await domain.create(payment);

      final result = await domain.refund(payment);

      expect(result.success, isFalse);
    });
  });
}
