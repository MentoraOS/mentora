import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/timer/domains/timer_domain.dart';
import 'package:mentora/core/timer/models/timer_session.dart';
import 'package:mentora/core/timer/models/timer_status.dart';
import 'package:mentora/core/timer/repositories/memory_timer_repository.dart';

void main() {
  group('Timer Domain', () {
    test('should create timer session', () async {
      final repository = MemoryTimerRepository();
      final domain = TimerDomain(repository: repository);

      final session = TimerSession(
        id: 'timer_001',
        consultationId: 'consultation_001',
        totalDuration: const Duration(minutes: 30),
      );

      final result = await domain.create(session);

      expect(result.success, isTrue);
      expect(result.session?.id, 'timer_001');
    });

    test('should start timer session', () async {
      final repository = MemoryTimerRepository();
      final domain = TimerDomain(repository: repository);

      final session = TimerSession(
        id: 'timer_002',
        consultationId: 'consultation_002',
        totalDuration: const Duration(minutes: 30),
      );

      await domain.create(session);

      final result = await domain.start(session);

      expect(result.success, isTrue);
      expect(result.session?.status, TimerStatus.running);
      expect(result.session?.startedAt, isNotNull);
    });

    test('should pause timer session', () async {
      final repository = MemoryTimerRepository();
      final domain = TimerDomain(repository: repository);

      final session = TimerSession(
        id: 'timer_003',
        consultationId: 'consultation_003',
        totalDuration: const Duration(minutes: 30),
        startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        status: TimerStatus.running,
      );

      await domain.create(session);

      final result = await domain.pause(session);

      expect(result.success, isTrue);
      expect(result.session?.status, TimerStatus.paused);
      expect(result.session, isNotNull);
      expect(result.session!.elapsedDuration.inMinutes >= 5, isTrue);
    });

    test('should resume timer session', () async {
      final repository = MemoryTimerRepository();
      final domain = TimerDomain(repository: repository);

      final session = TimerSession(
        id: 'timer_004',
        consultationId: 'consultation_004',
        totalDuration: const Duration(minutes: 30),
        elapsedDuration: const Duration(minutes: 10),
        status: TimerStatus.paused,
      );

      await domain.create(session);

      final result = await domain.resume(session);

      expect(result.success, isTrue);
      expect(result.session?.status, TimerStatus.running);
      expect(result.session?.startedAt, isNotNull);
    });

    test('should reject pause from idle', () async {
      final repository = MemoryTimerRepository();
      final domain = TimerDomain(repository: repository);

      final session = TimerSession(
        id: 'timer_invalid_001',
        consultationId: 'consultation_invalid_001',
        totalDuration: const Duration(minutes: 30),
        status: TimerStatus.idle,
      );

      await domain.create(session);

      final result = await domain.pause(session);

      expect(result.success, isFalse);
    });

    test('should stop timer session', () async {
      final repository = MemoryTimerRepository();
      final domain = TimerDomain(repository: repository);

      final session = TimerSession(
        id: 'timer_005',
        consultationId: 'consultation_005',
        totalDuration: const Duration(minutes: 30),
        startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        status: TimerStatus.running,
      );

      await domain.create(session);

      final result = await domain.stop(session);

      expect(result.success, isTrue);
      expect(result.session?.status, TimerStatus.stopped);
      expect(result.session?.stoppedAt, isNotNull);
    });
  });
}
