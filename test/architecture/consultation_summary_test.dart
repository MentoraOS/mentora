import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/application/consultation_summary/consultation_summary_application_service.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/domain/consultation_memory/memory_repository.dart';
import 'package:mentora/domain/consultation_summary/consultation_summary.dart';
import 'package:mentora/domain/consultation_summary/summary_provider.dart';
import 'package:mentora/domain/consultation_summary/summary_repository.dart';
import 'package:mentora/infrastructure/consultation_summary/simulated_summary_provider.dart';

void main() {
  group('ConsultationSummaryApplicationService', () {
    test('generation reads ONLY the memory and persists the lifecycle', () async {
      final memoryRepository = _MemoryRepository();
      final provider = _RecordingProvider();
      final states = _SummaryRepository();
      final service = _service(
        memoryRepository: memoryRepository,
        provider: provider,
        states: states,
      );

      final summary = await service.generate('b1');

      // The single business source: the memory, via its application door.
      expect(memoryRepository.reads, [('b1', 'client_1')]);
      expect(provider.generated.single.$1, 'b1');
      expect(provider.generated.single.$2.bookingId, 'b1');
      // Lifecycle persisted: generating, then the provider's outcome.
      expect(states.saved.map((entry) => entry.$3).toList(), [
        SummaryStatus.generating,
        SummaryStatus.available,
      ]);
      expect(summary.bookingId, 'b1');
      expect(summary.status, SummaryStatus.available);
    });

    test('one summary per reservation: summaryId == bookingId', () async {
      final states = _SummaryRepository();
      final service = _service(states: states);

      await service.generate('b1');

      expect(states.saved.map((entry) => entry.$1).toSet(), {'b1'});
      expect((await service.getSummary('b1')).bookingId, 'b1');
    });

    test('a provider failure is persisted FAILED and surfaces typed — '
        'never a fake success', () async {
      final states = _SummaryRepository();
      final service = _service(
        provider: _RecordingProvider(error: StateError('engine down')),
        states: states,
      );

      await expectLater(
        service.generate('b1'),
        throwsA(isA<SummaryUnavailableFailure>()),
      );
      expect(states.saved.map((entry) => entry.$3).toList(), [
        SummaryStatus.generating,
        SummaryStatus.failed,
      ]);
    });

    test('an unauthenticated session fails before anything', () async {
      final memoryRepository = _MemoryRepository();
      final provider = _RecordingProvider();
      final service = ConsultationSummaryApplicationService(
        session: _Session(null),
        memory: ConsultationMemoryApplicationService(
          session: _Session(null),
          repository: memoryRepository,
        ),
        provider: provider,
        repository: _SummaryRepository(),
      );

      await expectLater(
        service.generate('b1'),
        throwsA(isA<SummaryUnauthenticatedFailure>()),
      );
      expect(memoryRepository.reads, isEmpty);
      expect(provider.generated, isEmpty);
    });

    test('a foreign user or unknown booking fails closed before the '
        'provider', () async {
      final provider = _RecordingProvider();
      final states = _SummaryRepository();
      final service = _service(
        memoryRepository: _MemoryRepository(
          error: const MemoryEntryNotFoundException(),
        ),
        provider: provider,
        states: states,
      );

      await expectLater(
        service.generate('b1'),
        throwsA(isA<SummaryNotFoundFailure>()),
      );
      expect(provider.generated, isEmpty);
      expect(states.saved, isEmpty);
    });

    test('a never-generated summary reads as NOT_GENERATED, not an error', () async {
      final summary = await _service().getSummary('b1');

      expect(summary.status, SummaryStatus.notGenerated);
      expect(summary.createdAt, isNull);
    });
  });

  group('SimulatedSummaryProvider', () {
    test('reports AVAILABLE without producing any content', () async {
      const provider = SimulatedSummaryProvider();

      final status = await provider.generate(
        bookingId: 'b1',
        memory: ConsultationMemory(
          bookingId: 'b1',
          entries: const [],
          createdAt: null,
        ),
      );

      expect(status, SummaryStatus.available);
      expect(await provider.health(), isTrue);
    });
  });

  group('Summary — adapter contract', () {
    final source = File(
      'lib/infrastructure/consultation_summary/firestore_summary_repository.dart',
    ).readAsStringSync();

    test('dedicated collection keyed by booking, metadata only', () {
      expect(source, contains("collection('consultation_summaries')"));
      expect(source, contains('_summaries.doc(bookingId)'));
      expect(source, contains('runTransaction'));
      expect(
        source,
        contains("data['clientId'] != userId && data['expertId'] != userId"),
      );
      // Metadata only — never any generated content.
      expect(source, contains("'status': status.name,"));
      expect(source, contains("'updatedAt': FieldValue.serverTimestamp()"));
      expect(source, isNot(contains("'text'")));
      expect(source, isNot(contains("'content'")));
      expect(source, isNot(contains("'summary':")));
      // The booking is read for the guard, never written.
      expect(source, isNot(contains('transaction.update')));
    });
  });

  group('ARC-SUM01 — the memory is the only business source', () {
    test('the summary service reads business data through the memory door '
        'exclusively', () {
      final source = File(
        'lib/application/consultation_summary/'
        'consultation_summary_application_service.dart',
      ).readAsStringSync();

      expect(source, contains('ConsultationMemoryApplicationService'));
      // No direct read of any other module, ever.
      for (final forbidden in const [
        'conversation',
        'booking_overview',
        'consultation_brief',
        'consultation_notes',
        'consultation_documents',
        'review',
        'cloud_firestore',
      ]) {
        expect(
          source.toLowerCase(),
          isNot(contains(forbidden)),
          reason: 'summary service must not touch $forbidden',
        );
      }
    });

    test('the summary surface is confined and names no vendor', () {
      const allowedSurface = [
        'lib/domain/consultation_summary/consultation_summary.dart',
        'lib/domain/consultation_summary/summary_provider.dart',
        'lib/domain/consultation_summary/summary_repository.dart',
        'lib/application/consultation_summary/'
            'consultation_summary_application_service.dart',
        'lib/infrastructure/consultation_summary/simulated_summary_provider.dart',
        'lib/infrastructure/consultation_summary/firestore_summary_repository.dart',
        'lib/composition/mentora_composition_root.dart',
        'lib/composition/mentora_dependencies.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        // Exact identifiers: the legacy 'postConsultationSummary' string
        // field must not match.
        if ((source.contains('SummaryProvider') ||
                source.contains('SummaryRepository') ||
                source.contains('ConsultationSummaryApplicationService')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);

      for (final path in allowedSurface.take(6)) {
        final source = File(path).readAsStringSync().toLowerCase();
        for (final vendor in const [
          'openai',
          'gemini',
          'claude',
          'anthropic',
          'deepgram',
          'markdown',
        ]) {
          expect(source, isNot(contains(vendor)), reason: '$path: $vendor');
        }
      }
    });
  });
}

ConsultationSummaryApplicationService _service({
  _MemoryRepository? memoryRepository,
  _RecordingProvider? provider,
  _SummaryRepository? states,
}) {
  final session = _Session('client_1');
  return ConsultationSummaryApplicationService(
    session: session,
    memory: ConsultationMemoryApplicationService(
      session: session,
      repository: memoryRepository ?? _MemoryRepository(),
    ),
    provider: provider ?? _RecordingProvider(),
    repository: states ?? _SummaryRepository(),
  );
}

final class _MemoryRepository implements MemoryRepository {
  _MemoryRepository({this.error});

  final Object? error;
  final List<(String, String)> reads = [];

  @override
  Future<void> record({
    required String bookingId,
    required String userId,
    required MemoryEntryType type,
    required Map<String, Object?> payload,
  }) async {}

  @override
  Future<ConsultationMemory> read({
    required String bookingId,
    required String userId,
  }) async {
    if (error case final cause?) throw cause;
    reads.add((bookingId, userId));
    return ConsultationMemory(
      bookingId: bookingId,
      entries: const [],
      createdAt: null,
    );
  }
}

final class _RecordingProvider implements SummaryProvider {
  _RecordingProvider({this.error});

  final Object? error;
  final List<(String, ConsultationMemory)> generated = [];

  @override
  Future<SummaryStatus> generate({
    required String bookingId,
    required ConsultationMemory memory,
  }) async {
    if (error case final cause?) throw cause;
    generated.add((bookingId, memory));
    return SummaryStatus.available;
  }

  @override
  Future<bool> health() async => true;
}

final class _SummaryRepository implements SummaryRepository {
  final List<(String, String, SummaryStatus)> saved = [];

  @override
  Future<void> saveStatus({
    required String bookingId,
    required String userId,
    required SummaryStatus status,
  }) async {
    saved.add((bookingId, userId, status));
  }

  @override
  Future<ConsultationSummary?> findByBookingId({
    required String bookingId,
    required String userId,
  }) async {
    if (saved.isEmpty) return null;
    return ConsultationSummary(
      bookingId: bookingId,
      status: saved.last.$3,
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 1),
    );
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
