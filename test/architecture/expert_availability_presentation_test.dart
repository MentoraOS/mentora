import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/expert_availability/expert_availability_application_service.dart';
import 'package:mentora/domain/expert_availability/expert_availability.dart';
import 'package:mentora/domain/expert_availability/expert_availability_repository.dart';
import 'package:mentora/domain/session/session_model.dart';
import 'package:mentora/screens/expert_agenda_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('ExpertAgendaScreen', () {
    testWidgets('loads current Expert availability through Application', (
      tester,
    ) async {
      final repository = _AgendaRepository(
        loaded: ExpertAvailability(
          slotsByDay: const {
            'Lundi': ['08:00'],
          },
          revision: '1:2',
        ),
      );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(repository.loadedExpertIds, ['expert_1']);
      expect(find.text('Agenda expert'), findsOneWidget);
      expect(find.text('Enregistrer l’agenda'), findsOneWidget);
    });

    testWidgets('uses the revision returned by the previous save', (
      tester,
    ) async {
      final repository = _AgendaRepository(
        loaded: _availability(revision: '1:2'),
        revisionsAfterSave: <String>['3:4', '5:6'],
      );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      await _scrollToSave(tester);
      await tester.tap(find.text('Enregistrer l’agenda'));
      await tester.pumpAndSettle();
      await _scrollToSave(tester);
      await tester.tap(find.text('Enregistrer l’agenda'));
      await tester.pumpAndSettle();

      expect(repository.savedRevisions, ['1:2', '3:4']);
      expect(repository.savedExpertIds, ['expert_1', 'expert_1']);
    });

    testWidgets('shows a conflict and offers a reload action', (tester) async {
      final repository = _AgendaRepository(
        loaded: _availability(revision: '1:2'),
        conflict: true,
      );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      await _scrollToSave(tester);
      await tester.tap(find.text('Enregistrer l’agenda'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'La disponibilité a été modifiée depuis un autre appareil.',
        ),
        findsWidgets,
      );
      expect(find.text('Recharger'), findsOneWidget);

      await tester.ensureVisible(find.text('Recharger'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recharger'));
      await tester.pumpAndSettle();

      expect(repository.loadedExpertIds, ['expert_1', 'expert_1']);
      expect(find.text('Enregistrer l’agenda'), findsOneWidget);
    });
  });
}

Future<void> _scrollToSave(WidgetTester tester) {
  return tester.scrollUntilVisible(
    find.text('Enregistrer l’agenda'),
    500,
    scrollable: find.byType(Scrollable).first,
  );
}

Widget _app(_AgendaRepository repository) {
  final service = ExpertAvailabilityApplicationService(
    session: _ExpertSession(),
    repository: repository,
  );

  return Provider<ExpertAvailabilityApplicationService>.value(
    value: service,
    child: const MaterialApp(home: ExpertAgendaScreen()),
  );
}

ExpertAvailability _availability({required String revision}) {
  return ExpertAvailability(
    slotsByDay: const <String, List<String>>{},
    revision: revision,
  );
}

final class _AgendaRepository implements ExpertAvailabilityRepository {
  _AgendaRepository({
    required this.loaded,
    this.revisionsAfterSave = const <String>[],
    this.conflict = false,
  });

  final ExpertAvailability loaded;
  final List<String> revisionsAfterSave;
  final bool conflict;
  final List<String> loadedExpertIds = <String>[];
  final List<String> savedExpertIds = <String>[];
  final List<String?> savedRevisions = <String?>[];
  var _saveCount = 0;

  @override
  Future<ExpertAvailability> loadByExpertId(String expertId) async {
    loadedExpertIds.add(expertId);
    return loaded;
  }

  @override
  Future<ExpertAvailability> saveByExpertId({
    required String expertId,
    required ExpertAvailability availability,
  }) async {
    savedExpertIds.add(expertId);
    savedRevisions.add(availability.revision);

    if (conflict) {
      throw ExpertAvailabilityConcurrencyException(
        expectedRevision: availability.revision,
        actualRevision: '9:10',
      );
    }

    final revision = revisionsAfterSave[_saveCount++];
    return ExpertAvailability(
      slotsByDay: availability.slotsByDay,
      revision: revision,
    );
  }
}

final class _ExpertSession implements AuthenticationSession {
  @override
  final SessionModel current = SessionModel(
    id: 'expert_1',
    email: 'expert@mentora.test',
    name: 'Expert',
    photoUrl: '',
    countryCode: 'ML',
    currency: 'XOF',
    language: 'fr',
    roles: const ['expert'],
    permissions: const [],
    isActive: true,
    isVerified: true,
    isPremium: false,
  );

  @override
  String get currentUserId => current.id;

  @override
  bool get isAuthenticated => true;

  @override
  bool get isExpert => true;

  @override
  AuthenticationSessionStatus get status =>
      AuthenticationSessionStatus.authenticated;

  @override
  Object? get error => null;

  @override
  String get currentEmail => current.email;

  @override
  String get currentName => current.name;

  @override
  List<String> get currentRoles => current.roles;

  @override
  List<String> get currentPermissions => current.permissions;

  @override
  bool get isActive => true;

  @override
  bool get isAdmin => false;

  @override
  bool get isClient => false;

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
