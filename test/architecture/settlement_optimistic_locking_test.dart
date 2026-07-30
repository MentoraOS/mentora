import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/domain/infrastructure/'
    'settlement/in_memory_settlement_repository.dart';

import 'package:mentora/core/financial/domain/settlement/'
    'settlements.dart';

void main() {
  group('Settlement optimistic locking', () {
    late InMemorySettlementRepository repository;

    setUp(() {
      repository = InMemorySettlementRepository();
    });

    test('should allow only one worker to update the same version', () async {
      final initialSettlement = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: const [],
      ).markProcessing();

      // First persistence:
      // processing version 1
      await repository.save(initialSettlement, expectedVersion: null);

      final workerASettlement = await repository.findById(
        SettlementId('settlement_001'),
      );

      final workerBSettlement = await repository.findById(
        SettlementId('settlement_001'),
      );

      expect(workerASettlement, isNotNull);
      expect(workerBSettlement, isNotNull);
      expect(workerASettlement!.version, 1);
      expect(workerBSettlement!.version, 1);

      final completedByWorkerA = workerASettlement.markCompleted();

      final failedByWorkerB = workerBSettlement.markFailed(
        reason: 'Worker B simulated failure.',
      );

      // Worker A wins and persists version 2.
      await repository.save(
        completedByWorkerA,
        expectedVersion: workerASettlement.version,
      );

      // Worker B still expects version 1, but version 2
      // is already persisted.
      await expectLater(
        repository.save(
          failedByWorkerB,
          expectedVersion: workerBSettlement.version,
        ),
        throwsA(
          isA<SettlementConcurrencyException>()
              .having((error) => error.expectedVersion, 'expectedVersion', 1)
              .having((error) => error.actualVersion, 'actualVersion', 2)
              .having((error) => error.incomingVersion, 'incomingVersion', 2),
        ),
      );

      final persistedSettlement = await repository.findById(
        SettlementId('settlement_001'),
      );

      expect(persistedSettlement, isNotNull);
      expect(persistedSettlement!.status, SettlementStatus.completed);
      expect(persistedSettlement.version, 2);
    });

    test('should reject creation when the settlement already exists', () async {
      final settlement = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: const [],
      ).markProcessing();

      await repository.save(settlement, expectedVersion: null);

      final conflictingCreation = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: const [],
      ).markProcessing();

      // Exact replay is idempotent and therefore accepted.
      await repository.save(conflictingCreation, expectedVersion: null);

      expect(repository.length, 1);
    });

    test('should reject an invalid incoming version', () async {
      final processingSettlement = ConsultationSettlement(
        id: SettlementId('settlement_001'),
        lines: const [],
      ).markProcessing();

      await repository.save(processingSettlement, expectedVersion: null);

      // Same aggregate version, but not an exact replay.
      final invalidUpdate = ConsultationSettlement(
        id: processingSettlement.id,
        lines: const [],
        status: SettlementStatus.failed,
        version: 1,
      );

      await expectLater(
        repository.save(invalidUpdate, expectedVersion: 1),
        throwsStateError,
      );
    });
  });
}
