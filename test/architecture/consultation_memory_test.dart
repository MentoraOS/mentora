import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/domain/consultation_memory/memory_repository.dart';

void main() {
  group('ConsultationMemoryApplicationService', () {
    test('a participant records a business fact opaquely', () async {
      final repository = _MemoryRepository();
      final service = _service(repository);

      await service.record(
        bookingId: 'b1',
        type: MemoryEntryType.chatMessage,
        payload: const {'content': 'Bonjour', 'senderRole': 'client'},
      );

      final recorded = repository.recorded.single;
      expect(recorded.$1, 'b1');
      expect(recorded.$2, 'client_1');
      expect(recorded.$3, MemoryEntryType.chatMessage);
      expect(recorded.$4, {'content': 'Bonjour', 'senderRole': 'client'});
    });

    test('reading returns the reservation single memory, oldest first', () async {
      final repository = _MemoryRepository(
        memory: ConsultationMemory(
          bookingId: 'b1',
          entries: [
            _entry(id: 'e1', type: MemoryEntryType.bookingConfirmed),
            _entry(id: 'e2', type: MemoryEntryType.consultationCompleted),
          ],
          createdAt: DateTime.utc(2026, 8, 1),
        ),
      );

      final memory = await _service(repository).read('b1');

      expect(memory.bookingId, 'b1');
      expect(memory.entries.map((entry) => entry.id).toList(), ['e1', 'e2']);
      // The memory is a sealed record of facts.
      expect(
        () => memory.entries.add(_entry(id: 'x', type: MemoryEntryType.chatMessage)),
        throwsUnsupportedError,
      );
    });

    test('an unauthenticated session fails typed, nothing recorded', () async {
      final repository = _MemoryRepository();
      final service = ConsultationMemoryApplicationService(
        session: _Session(null),
        repository: repository,
      );

      await expectLater(
        service.record(bookingId: 'b1', type: MemoryEntryType.chatMessage),
        throwsA(isA<MemoryUnauthenticatedFailure>()),
      );
      await expectLater(
        service.read('b1'),
        throwsA(isA<MemoryUnauthenticatedFailure>()),
      );
      expect(repository.recorded, isEmpty);
    });

    test('a foreign user or unknown booking fails closed as not-found', () async {
      final service = _service(
        _MemoryRepository(error: const MemoryEntryNotFoundException()),
      );

      await expectLater(
        service.record(bookingId: 'b1', type: MemoryEntryType.privateNote),
        throwsA(isA<MemoryNotFoundFailure>()),
      );
      await expectLater(
        service.read('b1'),
        throwsA(isA<MemoryNotFoundFailure>()),
      );
    });

    test('infrastructure errors surface as typed failures', () {
      final service = _service(_MemoryRepository(error: StateError('down')));

      expect(
        () => service.record(bookingId: 'b1', type: MemoryEntryType.chatMessage),
        throwsA(isA<MemoryUnavailableFailure>()),
      );
    });
  });

  group('MemoryEntry — the authorized facts', () {
    test('exactly the ten authorized fact types exist', () {
      expect(MemoryEntryType.values.map((type) => type.name).toList(), [
        'chatMessage',
        'consultationBrief',
        'privateNote',
        'sharedDocument',
        'consultationStarted',
        'consultationCompleted',
        'bookingConfirmed',
        'bookingRescheduled',
        'bookingCancelled',
        'reviewCreated',
      ]);
    });

    test('the payload stays opaque and sealed', () {
      final entry = _entry(
        id: 'e1',
        type: MemoryEntryType.sharedDocument,
        payload: const {'fileName': 'plan.pdf', 'fileSize': 1024},
      );

      expect(entry.payload['fileName'], 'plan.pdf');
      expect(() => entry.payload['x'] = 1, throwsUnsupportedError);
      expect(() => _entry(id: 'e2', type: MemoryEntryType.chatMessage, bookingId: ' '),
          throwsArgumentError);
    });
  });

  group('Memory — adapter contract', () {
    final source = File(
      'lib/infrastructure/consultation_memory/firestore_memory_repository.dart',
    ).readAsStringSync();

    test('one memory per reservation in a dedicated collection', () {
      expect(source, contains("collection('consultation_memories')"));
      expect(source, contains('_memories.doc(bookingId)'));
      expect(source, contains('runTransaction'));
      expect(
        source,
        contains("data['clientId'] != userId && data['expertId'] != userId"),
      );
      expect(source, contains("'createdAt': FieldValue.serverTimestamp()"));
      // The booking is read for the guard, never written.
      expect(source, isNot(contains('transaction.update')));
    });

    test('payloads are stored verbatim — nothing parsed or interpreted', () {
      expect(source, contains("'payload': payload,"));
      expect(source, isNot(contains('jsonDecode')));
      expect(source, isNot(contains('jsonEncode')));
    });
  });

  group('ARC-MEM01 — no AI engine writes the memory directly', () {
    test('the AI gateway and the memory are strictly independent', () {
      const gatewayFiles = [
        'lib/domain/ai_gateway/ai_gateway.dart',
        'lib/domain/ai_gateway/ai_provider.dart',
        'lib/application/ai_gateway/ai_gateway_application_service.dart',
        'lib/infrastructure/ai_gateway/simulated_ai_provider.dart',
      ];
      const memoryFiles = [
        'lib/domain/consultation_memory/consultation_memory.dart',
        'lib/domain/consultation_memory/memory_repository.dart',
        'lib/application/consultation_memory/'
            'consultation_memory_application_service.dart',
        'lib/infrastructure/consultation_memory/firestore_memory_repository.dart',
      ];

      for (final path in gatewayFiles) {
        final source = File(path).readAsStringSync();
        for (final identifier in const [
          'MemoryRepository',
          'ConsultationMemory',
          'MemoryEntry',
        ]) {
          expect(
            source,
            isNot(contains(identifier)),
            reason: '$path must not reference $identifier',
          );
        }
      }
      for (final path in memoryFiles) {
        final source = File(path).readAsStringSync();
        for (final identifier in const ['AIGateway', 'AIProvider', 'AIRequest']) {
          expect(
            source,
            isNot(contains(identifier)),
            reason: '$path must not reference $identifier',
          );
        }
      }
    });

    test('memory writes are confined to the single application door', () {
      const allowedSurface = [
        'lib/domain/consultation_memory/consultation_memory.dart',
        'lib/domain/consultation_memory/memory_repository.dart',
        'lib/application/consultation_memory/'
            'consultation_memory_application_service.dart',
        'lib/infrastructure/consultation_memory/firestore_memory_repository.dart',
        'lib/composition/mentora_composition_root.dart',
        'lib/composition/mentora_dependencies.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('MemoryRepository') ||
                source.contains('ConsultationMemoryApplicationService')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }

      expect(offenders, isEmpty);
    });

    test('the memory layer holds business facts only — no engine, no '
        'vendor, ever', () {
      for (final path in const [
        'lib/domain/consultation_memory/consultation_memory.dart',
        'lib/domain/consultation_memory/memory_repository.dart',
        'lib/application/consultation_memory/'
            'consultation_memory_application_service.dart',
        'lib/infrastructure/consultation_memory/firestore_memory_repository.dart',
      ]) {
        final source = File(path).readAsStringSync().toLowerCase();
        for (final vendor in const [
          'gpt',
          'gemini',
          'claude',
          'openai',
          'anthropic',
          'deepgram',
          'deepseek',
          'embedding',
          'vector',
        ]) {
          expect(source, isNot(contains(vendor)), reason: '$path: $vendor');
        }
      }
    });
  });
}

MemoryEntry _entry({
  required String id,
  required MemoryEntryType type,
  String bookingId = 'b1',
  Map<String, Object?> payload = const {},
}) {
  return MemoryEntry(
    id: id,
    bookingId: bookingId,
    type: type,
    createdAt: DateTime.utc(2026, 8, 1, 9),
    payload: payload,
  );
}

ConsultationMemoryApplicationService _service(_MemoryRepository repository) {
  return ConsultationMemoryApplicationService(
    session: _Session('client_1'),
    repository: repository,
  );
}

final class _MemoryRepository implements MemoryRepository {
  _MemoryRepository({this.error, this.memory});

  final Object? error;
  final ConsultationMemory? memory;
  final List<(String, String, MemoryEntryType, Map<String, Object?>)>
  recorded = [];

  @override
  Future<void> record({
    required String bookingId,
    required String userId,
    required MemoryEntryType type,
    required Map<String, Object?> payload,
  }) async {
    if (error case final cause?) throw cause;
    recorded.add((bookingId, userId, type, payload));
  }

  @override
  Future<ConsultationMemory> read({
    required String bookingId,
    required String userId,
  }) async {
    if (error case final cause?) throw cause;
    return memory ??
        ConsultationMemory(bookingId: bookingId, entries: const [], createdAt: null);
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
