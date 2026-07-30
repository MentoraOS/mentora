import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/expert_availability/expert_availability_application_service.dart';
import 'package:mentora/application/expert_availability/expert_availability_failure.dart';
import 'package:mentora/domain/expert_availability/expert_availability.dart';
import 'package:mentora/domain/expert_availability/expert_availability_repository.dart';
import 'package:mentora/domain/session/session_model.dart';

void main() {
  group('ExpertAvailabilityApplicationService', () {
    test('loads availability for the authenticated Expert', () async {
      final expected = ExpertAvailability(
        slotsByDay: const {
          'Lundi': ['08:00'],
        },
        revision: '1:2',
      );
      final repository = _FakeRepository(loaded: expected);
      final service = _service(repository: repository);

      final result = await service.loadCurrentAvailability();

      expect(result, expected);
      expect(repository.loadedExpertId, 'expert_1');
    });

    test('saves availability for the authenticated Expert', () async {
      final input = ExpertAvailability(
        slotsByDay: const {
          'Mardi': ['14:00'],
        },
        revision: '1:2',
      );
      final saved = ExpertAvailability(
        slotsByDay: input.slotsByDay,
        revision: '3:4',
      );
      final repository = _FakeRepository(saved: saved);
      final service = _service(repository: repository);

      final result = await service.saveCurrentAvailability(input);

      expect(result, saved);
      expect(result.revision, '3:4');
      expect(repository.savedExpertId, 'expert_1');
      expect(repository.savedAvailability, input);
    });

    test('rejects unauthenticated load', () {
      final service = _service(
        repository: _FakeRepository(),
        session: _FakeSession(),
      );

      expect(
        service.loadCurrentAvailability,
        throwsA(isA<ExpertAvailabilityUnauthenticatedFailure>()),
      );
    });

    test('rejects unauthenticated save', () {
      final service = _service(
        repository: _FakeRepository(),
        session: _FakeSession(),
      );

      expect(
        () => service.saveCurrentAvailability(_empty()),
        throwsA(isA<ExpertAvailabilityUnauthenticatedFailure>()),
      );
    });

    test('rejects an authenticated non-Expert', () {
      final service = _service(
        repository: _FakeRepository(),
        session: _FakeSession(userId: 'client_1', expert: false),
      );

      expect(
        service.loadCurrentAvailability,
        throwsA(isA<ExpertAvailabilityForbiddenFailure>()),
      );
    });

    test('maps repository read failure', () async {
      final cause = StateError('offline');
      final service = _service(repository: _FakeRepository(loadError: cause));

      await expectLater(
        service.loadCurrentAvailability(),
        throwsA(
          isA<ExpertAvailabilityRepositoryFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });

    test('maps repository write failure', () async {
      final cause = StateError('offline');
      final service = _service(repository: _FakeRepository(saveError: cause));

      await expectLater(
        service.saveCurrentAvailability(_empty()),
        throwsA(
          isA<ExpertAvailabilityRepositoryFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });

    test('maps malformed repository data explicitly', () async {
      final cause = FormatException('invalid availability');
      final service = _service(
        repository: _FakeRepository(loadError: cause, malformed: true),
      );

      await expectLater(
        service.loadCurrentAvailability(),
        throwsA(
          isA<ExpertAvailabilityMalformedDataFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });

    test('maps optimistic concurrency conflict explicitly', () async {
      final service = _service(
        repository: _FakeRepository(
          concurrencyError: const ExpertAvailabilityConcurrencyException(
            expectedRevision: '1:2',
            actualRevision: '3:4',
          ),
        ),
      );

      await expectLater(
        service.saveCurrentAvailability(_empty(revision: '1:2')),
        throwsA(
          isA<ExpertAvailabilityConcurrencyConflictFailure>()
              .having(
                (failure) => failure.expectedRevision,
                'expectedRevision',
                '1:2',
              )
              .having(
                (failure) => failure.actualRevision,
                'actualRevision',
                '3:4',
              ),
        ),
      );
    });

    test('preserves empty availability', () async {
      final empty = _empty(revision: '1:2');
      final service = _service(repository: _FakeRepository(loaded: empty));

      expect(await service.loadCurrentAvailability(), empty);
    });
  });
}

ExpertAvailabilityApplicationService _service({
  required _FakeRepository repository,
  _FakeSession? session,
}) {
  return ExpertAvailabilityApplicationService(
    session: session ?? _FakeSession(userId: 'expert_1', expert: true),
    repository: repository,
  );
}

ExpertAvailability _empty({String? revision}) {
  return ExpertAvailability(
    slotsByDay: const <String, List<String>>{},
    revision: revision,
  );
}

final class _FakeRepository implements ExpertAvailabilityRepository {
  _FakeRepository({
    this.loaded,
    this.saved,
    this.loadError,
    this.saveError,
    this.concurrencyError,
    this.malformed = false,
  });

  final ExpertAvailability? loaded;
  final ExpertAvailability? saved;
  final Object? loadError;
  final Object? saveError;
  final ExpertAvailabilityConcurrencyException? concurrencyError;
  final bool malformed;

  String? loadedExpertId;
  String? savedExpertId;
  ExpertAvailability? savedAvailability;

  @override
  Future<ExpertAvailability> loadByExpertId(String expertId) async {
    loadedExpertId = expertId;
    if (loadError case final error?) {
      throw ExpertAvailabilityRepositoryException(
        cause: error,
        malformedData: malformed,
      );
    }
    return loaded ?? _empty();
  }

  @override
  Future<ExpertAvailability> saveByExpertId({
    required String expertId,
    required ExpertAvailability availability,
  }) async {
    savedExpertId = expertId;
    savedAvailability = availability;
    if (concurrencyError case final error?) throw error;
    if (saveError case final error?) {
      throw ExpertAvailabilityRepositoryException(cause: error);
    }
    return saved ?? availability;
  }
}

final class _FakeSession implements AuthenticationSession {
  _FakeSession({String? userId, this.expert = false})
    : current = userId == null ? null : _session(userId, expert);

  final bool expert;

  @override
  final SessionModel? current;

  @override
  String? get currentUserId => current?.id;

  @override
  bool get isAuthenticated => current != null;

  @override
  bool get isExpert => isAuthenticated && expert;

  @override
  AuthenticationSessionStatus get status => isAuthenticated
      ? AuthenticationSessionStatus.authenticated
      : AuthenticationSessionStatus.unauthenticated;

  @override
  Object? get error => null;

  @override
  String? get currentEmail => current?.email;

  @override
  String get currentName => current?.name ?? '';

  @override
  List<String> get currentRoles => current?.roles ?? const [];

  @override
  List<String> get currentPermissions => const [];

  @override
  bool get isActive => isAuthenticated;

  @override
  bool get isAdmin => false;

  @override
  bool get isClient => isAuthenticated && !expert;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<String> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async => 'client_1';

  @override
  Future<void> signOut() async {}

  @override
  void addListener(AuthenticationSessionListener listener) {}

  @override
  void removeListener(AuthenticationSessionListener listener) {}
}

SessionModel _session(String userId, bool expert) {
  return SessionModel(
    id: userId,
    email: 'user@mentora.test',
    name: 'User',
    photoUrl: '',
    countryCode: 'ML',
    currency: 'XOF',
    language: 'fr',
    roles: [expert ? 'expert' : 'client'],
    permissions: const [],
    isActive: true,
    isVerified: true,
    isPremium: false,
  );
}
