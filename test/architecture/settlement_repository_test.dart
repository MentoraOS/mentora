import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/settlement/settlements.dart';
import 'package:mentora/core/financial/domain/infrastructure/settlement/in_memory_settlement_repository.dart';

void main() {
  group('InMemorySettlementRepository', () {
    late InMemorySettlementRepository repository;

    setUp(() {
      repository = InMemorySettlementRepository();
    });

    test('should save and retrieve a settlement', () async {
      final settlement = _buildSettlement('settlement_001');

      await repository.save(settlement);

      final result = await repository.findById(settlement.id);

      expect(result, isNotNull);
      expect(result!.id, settlement.id);
      expect(result.status, SettlementStatus.pending);
    });

    test('should report existence after save', () async {
      final settlement = _buildSettlement('settlement_001');

      expect(await repository.exists(settlement.id), isFalse);

      await repository.save(settlement);

      expect(await repository.exists(settlement.id), isTrue);
    });

    test('should delete a settlement', () async {
      final settlement = _buildSettlement('settlement_001');

      await repository.save(settlement);

      await repository.delete(settlement.id);

      expect(await repository.findById(settlement.id), isNull);
    });

    test(
      'should update an existing settlement with the expected version',
      () async {
        final pendingSettlement = ConsultationSettlement(
          id: SettlementId('settlement_001'),
          lines: const [],
        );

        final processingSettlement = pendingSettlement.markProcessing();

        await repository.save(processingSettlement, expectedVersion: null);

        final completedSettlement = processingSettlement.markCompleted();

        await repository.save(
          completedSettlement,
          expectedVersion: processingSettlement.version,
        );

        final persisted = await repository.findById(
          SettlementId('settlement_001'),
        );

        expect(persisted, isNotNull);
        expect(persisted!.status, SettlementStatus.completed);
        expect(persisted.version, 2);
      },
    );

    test(
      'should reject an existing settlement without expected version',
      () async {
        final firstSettlement = ConsultationSettlement(
          id: SettlementId('settlement_001'),
          lines: const [],
        ).markProcessing();

        await repository.save(firstSettlement, expectedVersion: null);

        final conflictingSettlement = firstSettlement.markCompleted();

        await expectLater(
          repository.save(conflictingSettlement, expectedVersion: null),
          throwsA(isA<SettlementConcurrencyException>()),
        );
      },
    );
  });
}

ConsultationSettlement _buildSettlement(String id) {
  return ConsultationSettlement(id: SettlementId(id), lines: const []);
}
