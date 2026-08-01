import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/expert_timezone/expert_timezone_application_service.dart';
import 'package:mentora/application/expert_timezone/expert_timezone_failure.dart';
import 'package:mentora/domain/expert_timezone/expert_timezone_declaration_repository.dart';

void main() {
  group('AD-022 Clarification A — expert timezone declaration', () {
    test('records the explicit confirmation verbatim', () async {
      final repository = _Repository();
      final service = _service(repository);

      await service.declareTimezone('Africa/Bamako');

      expect(repository.saved, [('expert_1', 'Africa/Bamako')]);
    });

    test('offers exactly the launch-market identities', () {
      expect(ExpertTimezoneApplicationService.supportedTimezones, [
        'Africa/Bamako',
        'Africa/Dakar',
        'Africa/Abidjan',
      ]);
    });

    test('an unsupported identity fails closed, nothing is persisted', () {
      final repository = _Repository();
      final service = _service(repository);

      for (final unsupported in const [
        'Europe/Paris',
        'UTC+1',
        '+00:00',
        'Bamako',
        '',
      ]) {
        expect(
          () => service.declareTimezone(unsupported),
          throwsA(isA<ExpertTimezoneUnsupportedFailure>()),
          reason: unsupported,
        );
      }
      expect(repository.saved, isEmpty);
    });

    test('loads the current declaration, null when absent', () async {
      expect(
        await _service(
          _Repository(stored: 'Africa/Dakar'),
        ).loadCurrentTimezone(),
        'Africa/Dakar',
      );
      expect(await _service(_Repository()).loadCurrentTimezone(), isNull);
    });

    test('an unauthenticated session is rejected', () {
      final service = _service(_Repository(), userId: null);

      expect(
        () => service.declareTimezone('Africa/Bamako'),
        throwsA(isA<ExpertTimezoneUnauthenticatedFailure>()),
      );
    });

    test('a non-expert session is rejected', () {
      final service = _service(_Repository(), isExpert: false);

      expect(
        () => service.declareTimezone('Africa/Bamako'),
        throwsA(isA<ExpertTimezoneForbiddenFailure>()),
      );
    });

    test('repository failures stay typed', () async {
      final service = _service(_Repository(error: StateError('offline')));

      await expectLater(
        service.loadCurrentTimezone(),
        throwsA(isA<ExpertTimezoneRepositoryFailure>()),
      );
    });
  });
}

ExpertTimezoneApplicationService _service(
  _Repository repository, {
  String? userId = 'expert_1',
  bool isExpert = true,
}) {
  return ExpertTimezoneApplicationService(
    session: _Session(userId, isExpert: isExpert),
    repository: repository,
  );
}

final class _Repository implements ExpertTimezoneDeclarationRepository {
  _Repository({this.stored, this.error});

  final String? stored;
  final Object? error;
  final List<(String, String)> saved = [];

  @override
  Future<String?> loadByExpertId(String expertId) async {
    if (error case final cause?) {
      throw ExpertTimezoneRepositoryException(cause: cause);
    }
    return stored;
  }

  @override
  Future<void> saveByExpertId({
    required String expertId,
    required String timezone,
  }) async {
    if (error case final cause?) {
      throw ExpertTimezoneRepositoryException(cause: cause);
    }
    saved.add((expertId, timezone));
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId, {required this.isExpert});

  @override
  final String? currentUserId;

  @override
  final bool isExpert;

  @override
  bool get isAuthenticated => currentUserId != null;
}
