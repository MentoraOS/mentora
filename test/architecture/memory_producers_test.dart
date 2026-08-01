import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_cancellation_application_service.dart';
import 'package:mentora/application/booking/booking_confirmation_application_service.dart';
import 'package:mentora/application/booking/booking_reschedule_application_service.dart';
import 'package:mentora/application/booking/consultation_completion_application_service.dart';
import 'package:mentora/application/consultation_brief/consultation_brief_application_service.dart';
import 'package:mentora/application/consultation_documents/consultation_document_application_service.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/application/consultation_notes/consultation_private_notes_application_service.dart';
import 'package:mentora/application/conversation/conversation_application_service.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/review/review_application_service.dart';
import 'package:mentora/domain/booking/booking_cancellation_repository.dart';
import 'package:mentora/domain/booking/booking_confirmation_repository.dart';
import 'package:mentora/domain/booking/booking_reschedule_repository.dart';
import 'package:mentora/domain/booking/consultation_completion_repository.dart';
import 'package:mentora/domain/consultation_brief/consultation_brief.dart';
import 'package:mentora/domain/consultation_documents/consultation_shared_document.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/domain/consultation_memory/memory_repository.dart';
import 'package:mentora/domain/consultation_notes/consultation_private_notes_repository.dart';
import 'package:mentora/domain/conversation/conversation_repository.dart';
import 'package:mentora/domain/conversation/conversation.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/domain/review/consultation_review.dart';
import 'package:mentora/domain/review/consultation_review_repository.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_interpretation_adapter.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import 'package:mentora/infrastructure/scheduling/launch_market_timezone_resolver.dart';

void main() {
  group('Memory producers — each success records exactly one fact', () {
    test('chat message -> CHAT_MESSAGE with verbatim content', () async {
      final memory = _Memory();
      final service = ConversationApplicationService(
        session: _Session('client_1'),
        repository: _Chat(),
        memory: _door(memory),
      );

      await service.sendMessage(bookingId: 'b1', content: '  Bonjour !  ');

      final entry = memory.entries.single;
      expect(entry.$1, 'b1');
      expect(entry.$2, 'client_1');
      expect(entry.$3, MemoryEntryType.chatMessage);
      expect(entry.$4, {'content': 'Bonjour !'});
    });

    test('brief -> CONSULTATION_BRIEF with verbatim fields', () async {
      final memory = _Memory();
      final service = ConsultationBriefApplicationService(
        session: _Session('client_1'),
        repository: _Brief(),
        memory: _door(memory),
      );

      await service.save(
        bookingId: 'b1',
        objective: 'Objectif',
        description: 'Description',
        questions: 'Questions',
        expectedOutcome: 'Résultat',
      );

      final entry = memory.entries.single;
      expect(entry.$3, MemoryEntryType.consultationBrief);
      expect(entry.$4, {
        'objective': 'Objectif',
        'description': 'Description',
        'questions': 'Questions',
        'expectedOutcome': 'Résultat',
      });
    });

    test('private note -> PRIVATE_NOTE as a fact WITHOUT the content', () async {
      final memory = _Memory();
      final service = ConsultationPrivateNotesApplicationService(
        session: _Session('expert_1', isExpert: true),
        repository: _Notes(),
        memory: _door(memory, userId: 'expert_1'),
      );

      await service.save(bookingId: 'b1', notes: 'Contenu strictement privé');

      final entry = memory.entries.single;
      expect(entry.$3, MemoryEntryType.privateNote);
      // The client can read the memory; the note text must never enter it.
      expect(entry.$4, isEmpty);
    });

    test('document upload -> SHARED_DOCUMENT fact, never the file', () async {
      final memory = _Memory();
      final service = ConsultationDocumentApplicationService(
        session: _Session('client_1'),
        repository: _Documents(),
        memory: _door(memory),
      );

      await service.upload(
        bookingId: 'b1',
        fileName: ' plan.pdf ',
        bytes: List.filled(2048, 1),
      );

      final entry = memory.entries.single;
      expect(entry.$3, MemoryEntryType.sharedDocument);
      expect(entry.$4, {'fileName': 'plan.pdf', 'fileSize': 2048});
    });

    test('confirmation -> BOOKING_CONFIRMED', () async {
      final memory = _Memory();
      final service = BookingConfirmationApplicationService(
        session: _Session('client_1'),
        repository: _Confirmation(),
        memory: _door(memory),
      );

      await service.confirmPaid('b1');

      expect(memory.entries.single.$3, MemoryEntryType.bookingConfirmed);
    });

    test('cancellation -> BOOKING_CANCELLED', () async {
      final memory = _Memory();
      final service = BookingCancellationApplicationService(
        session: _Session('client_1'),
        repository: _Cancellation(),
        memory: _door(memory),
      );

      await service.cancel('b1');

      expect(memory.entries.single.$3, MemoryEntryType.bookingCancelled);
    });

    test('reschedule -> BOOKING_RESCHEDULED with the new civil values', () async {
      final memory = _Memory();
      final service = BookingRescheduleApplicationService(
        session: _Session('client_1'),
        repository: _Reschedule(),
        expertCatalog: ExpertCatalogApplicationService(
          repository: const _Catalog(),
        ),
        materialization: const CivilOccurrenceMaterializationAdapter(),
        interpretation: const CivilOccurrenceInterpretationAdapter(
          resolver: LaunchMarketTimezoneResolver(),
        ),
        memory: _door(memory),
      );

      // Monday 2026-08-03 09:00 belongs to the expert's recurring offer.
      await service.reschedule(
        bookingId: 'b1',
        expertId: 'expert_1',
        durationMinutes: 60,
        year: 2026,
        month: 8,
        day: 3,
        hour: 9,
        minute: 0,
      );

      final entry = memory.entries.single;
      expect(entry.$3, MemoryEntryType.bookingRescheduled);
      expect(entry.$4, {'bookingDate': '2026-08-03', 'bookingTime': '09:00'});
    });

    test('completion -> CONSULTATION_COMPLETED', () async {
      final memory = _Memory();
      final service = ConsultationCompletionApplicationService(
        session: _Session('client_1'),
        repository: _Completion(),
        memory: _door(memory),
      );

      await service.complete('b1');

      expect(memory.entries.single.$3, MemoryEntryType.consultationCompleted);
    });

    test('review -> REVIEW_CREATED with verbatim rating and comment', () async {
      final memory = _Memory();
      final service = ReviewApplicationService(
        session: _Session('client_1'),
        repository: _Reviews(),
        memory: _door(memory),
      );

      await service.submitReview(
        bookingId: 'b1',
        rating: 5,
        comment: ' Très utile. ',
      );

      final entry = memory.entries.single;
      expect(entry.$3, MemoryEntryType.reviewCreated);
      expect(entry.$4, {'rating': 5, 'comment': 'Très utile.'});
    });
  });

  group('Memory producers — resilience and fail closed', () {
    test('a memory failure never fails the business flow', () async {
      final memory = _Memory(error: StateError('memory down'));
      final chat = _Chat();
      final service = ConversationApplicationService(
        session: _Session('client_1'),
        repository: chat,
        memory: _door(memory),
      );

      await service.sendMessage(bookingId: 'b1', content: 'Bonjour');

      expect(chat.sent, hasLength(1));
      expect(memory.entries, isEmpty);
    });

    test('a failed business operation records nothing', () async {
      final memory = _Memory();
      final service = BookingConfirmationApplicationService(
        session: _Session('client_1'),
        repository: _Confirmation(
          error: const BookingConfirmationNotFoundException(),
        ),
        memory: _door(memory),
      );

      await expectLater(service.confirmPaid('b1'), throwsA(anything));
      expect(memory.entries, isEmpty);
    });

    test('a service without memory wiring still works unchanged', () async {
      final chat = _Chat();
      final service = ConversationApplicationService(
        session: _Session('client_1'),
        repository: chat,
      );

      await service.sendMessage(bookingId: 'b1', content: 'Bonjour');

      expect(chat.sent, hasLength(1));
    });
  });
}

ConsultationMemoryApplicationService _door(
  _Memory memory, {
  String userId = 'client_1',
}) {
  return ConsultationMemoryApplicationService(
    session: _Session(userId),
    repository: memory,
  );
}

final class _Memory implements MemoryRepository {
  _Memory({this.error});

  final Object? error;
  final List<(String, String, MemoryEntryType, Map<String, Object?>)>
  entries = [];

  @override
  Future<void> record({
    required String bookingId,
    required String userId,
    required MemoryEntryType type,
    required Map<String, Object?> payload,
  }) async {
    if (error case final cause?) throw cause;
    entries.add((bookingId, userId, type, payload));
  }

  @override
  Future<ConsultationMemory> read({
    required String bookingId,
    required String userId,
  }) async {
    return ConsultationMemory(
      bookingId: bookingId,
      entries: const [],
      createdAt: null,
    );
  }
}

final class _Chat implements ConversationRepository {
  final List<String> sent = [];

  @override
  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String content,
  }) async {
    sent.add(content);
  }

  @override
  Stream<List<Message>> watchMessages({
    required String bookingId,
    required String userId,
  }) {
    return const Stream.empty();
  }
}

final class _Brief implements ConsultationBriefRepository {
  @override
  Future<void> save({
    required String bookingId,
    required String clientId,
    required ConsultationBrief brief,
  }) async {}

  @override
  Future<ConsultationBrief?> loadByBookingId(String bookingId) async => null;
}

final class _Notes implements ConsultationPrivateNotesRepository {
  @override
  Future<void> save({
    required String bookingId,
    required String expertId,
    required String notes,
  }) async {}

  @override
  Future<String?> loadByBookingId({
    required String bookingId,
    required String expertId,
  }) async => null;
}

final class _Documents implements ConsultationSharedDocumentRepository {
  @override
  Future<void> upload({
    required String bookingId,
    required String userId,
    required String fileName,
    required List<int> bytes,
  }) async {}

  @override
  Future<List<ConsultationSharedDocument>> listByBookingId({
    required String bookingId,
    required String userId,
  }) async => const [];
}

final class _Confirmation implements BookingConfirmationRepository {
  _Confirmation({this.error});

  final Object? error;

  @override
  Future<void> confirmPaid({
    required String bookingId,
    required String clientId,
  }) async {
    if (error case final cause?) throw cause;
  }
}

final class _Cancellation implements BookingCancellationRepository {
  @override
  Future<void> cancel({
    required String bookingId,
    required String clientId,
  }) async {}
}

final class _Reschedule implements BookingRescheduleRepository {
  @override
  Future<void> reschedule({
    required String bookingId,
    required String clientId,
    required BookingRescheduleUpdate update,
  }) async {}
}

final class _Completion implements ConsultationCompletionRepository {
  @override
  Future<void> complete({
    required String bookingId,
    required String userId,
  }) async {}
}

final class _Reviews implements ConsultationReviewRepository {
  @override
  Future<void> submit({
    required String bookingId,
    required String clientId,
    required int rating,
    required String comment,
  }) async {}

  @override
  Future<ConsultationReview?> findByBookingId(String bookingId) async => null;

  @override
  Future<List<ConsultationReview>> listByExpertId(String expertId) async =>
      const [];
}

final class _Catalog implements ExpertCatalogRepository {
  const _Catalog();

  static final ExpertCatalogEntry _expert = ExpertCatalogEntry(
    id: 'expert_1',
    name: 'Awa',
    job: 'Coach',
    country: 'ML',
    rating: '5',
    online: true,
    availability: const {
      'Lundi': ['09:00'],
    },
    expertTimezone: 'Africa/Bamako',
  );

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() => Stream.value([_expert]);

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    return _expert.id == expertId ? _expert : null;
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId, {this.isExpert = false});

  @override
  final String? currentUserId;

  @override
  final bool isExpert;

  @override
  bool get isAuthenticated => currentUserId != null;
}
