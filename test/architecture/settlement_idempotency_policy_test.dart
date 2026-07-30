import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/settlements.dart';

void main() {
  group('SettlementIdempotencyPolicy', () {
    const policy = SettlementIdempotencyPolicy();

    test('should continue processing when no settlement exists', () {
      expect(
        policy.evaluate(null),
        SettlementIdempotencyDecision.continueProcessing,
      );
    });

    test('should resume a pending settlement', () {
      expect(
        policy.evaluate(_buildSettlement(SettlementStatus.pending)),
        SettlementIdempotencyDecision.resume,
      );
    });

    test('should resume a processing settlement', () {
      expect(
        policy.evaluate(_buildSettlement(SettlementStatus.processing)),
        SettlementIdempotencyDecision.resume,
      );
    });

    test('should return alreadyCompleted for a completed settlement', () {
      expect(
        policy.evaluate(_buildSettlement(SettlementStatus.completed)),
        SettlementIdempotencyDecision.alreadyCompleted,
      );
    });

    test('should retry a failed settlement', () {
      expect(
        policy.evaluate(_buildSettlement(SettlementStatus.failed)),
        SettlementIdempotencyDecision.retry,
      );
    });

    test('should reject a cancelled settlement', () {
      expect(
        policy.evaluate(_buildSettlement(SettlementStatus.cancelled)),
        SettlementIdempotencyDecision.reject,
      );
    });

    test('should reject a refunded settlement', () {
      expect(
        policy.evaluate(_buildSettlement(SettlementStatus.refunded)),
        SettlementIdempotencyDecision.reject,
      );
    });
  });
}

ConsultationSettlement _buildSettlement(SettlementStatus status) {
  return ConsultationSettlement(
    id: SettlementId('settlement_001'),
    lines: const [],
    status: status,
  );
}
