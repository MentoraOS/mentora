import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/profile/profile_application_service.dart';
import 'package:mentora/application/profile/profile_failure.dart';
import 'package:mentora/domain/profile/profile.dart';
import 'package:mentora/domain/profile/profile_repository.dart';
import 'package:mentora/domain/session/session_model.dart';

void main() {
  group('ProfileApplicationService', () {
    test('reads the authenticated current user profile', () async {
      final repository = _FakeProfileRepository(
        profile: const Profile(id: 'user_1', firstName: 'Awa'),
      );
      final service = ProfileApplicationService(
        session: _FakeAuthenticationSession(userId: 'user_1'),
        repository: repository,
      );

      final profile = await service.getCurrentProfile();

      expect(profile.id, 'user_1');
      expect(repository.lastReadUserId, 'user_1');
    });

    test('reports profile not found explicitly', () async {
      final service = ProfileApplicationService(
        session: _FakeAuthenticationSession(userId: 'user_1'),
        repository: _FakeProfileRepository(),
      );

      expect(service.getCurrentProfile, throwsA(isA<ProfileNotFoundFailure>()));
    });

    test('rejects an unauthenticated request', () {
      final service = ProfileApplicationService(
        session: _FakeAuthenticationSession(),
        repository: _FakeProfileRepository(),
      );

      expect(
        service.getCurrentProfile,
        throwsA(isA<ProfileUnauthenticatedFailure>()),
      );
      expect(
        service.observeCurrentProfile,
        throwsA(isA<ProfileUnauthenticatedFailure>()),
      );
    });

    test('updates the authenticated current user profile', () async {
      final repository = _FakeProfileRepository();
      final service = ProfileApplicationService(
        session: _FakeAuthenticationSession(userId: 'user_1'),
        repository: repository,
      );

      await service.updateCurrentProfile(
        firstName: ' Awa ',
        lastName: ' Diallo ',
        phone: ' 123 ',
      );

      expect(repository.lastUpdatedUserId, 'user_1');
      expect(repository.lastFirstName, ' Awa ');
      expect(repository.lastLastName, ' Diallo ');
      expect(repository.lastPhone, ' 123 ');
    });

    test('observes the authenticated current user profile', () async {
      final repository = _FakeProfileRepository(
        profile: const Profile(id: 'user_1', firstName: 'Awa'),
      );
      final service = ProfileApplicationService(
        session: _FakeAuthenticationSession(userId: 'user_1'),
        repository: repository,
      );

      final profile = await service.observeCurrentProfile().first;

      expect(profile.id, 'user_1');
    });

    test('maps repository failures without exposing infrastructure', () async {
      final cause = StateError('offline');
      final service = ProfileApplicationService(
        session: _FakeAuthenticationSession(userId: 'user_1'),
        repository: _FakeProfileRepository(error: cause),
      );

      await expectLater(
        service.getCurrentProfile(),
        throwsA(
          isA<ProfileInfrastructureFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });

    test('maps update repository failures explicitly', () async {
      final cause = StateError('offline');
      final service = ProfileApplicationService(
        session: _FakeAuthenticationSession(userId: 'user_1'),
        repository: _FakeProfileRepository(error: cause),
      );

      await expectLater(
        service.updateCurrentProfile(
          firstName: 'Awa',
          lastName: 'Diallo',
          phone: '123',
        ),
        throwsA(
          isA<ProfileInfrastructureFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });
  });
}

final class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.profile, this.error});

  final Profile? profile;
  final Object? error;
  String? lastReadUserId;
  String? lastUpdatedUserId;
  String? lastFirstName;
  String? lastLastName;
  String? lastPhone;

  @override
  Future<Profile?> findByUserId(String userId) async {
    lastReadUserId = userId;
    if (error case final error?) {
      throw ProfileRepositoryException(cause: error);
    }
    return profile;
  }

  @override
  Stream<Profile?> observeByUserId(String userId) {
    if (error case final error?) {
      return Stream.error(ProfileRepositoryException(cause: error));
    }
    return Stream.value(profile);
  }

  @override
  Future<void> update({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    lastUpdatedUserId = userId;
    lastFirstName = firstName;
    lastLastName = lastName;
    lastPhone = phone;
    if (error case final error?) {
      throw ProfileRepositoryException(cause: error);
    }
  }
}

final class _FakeAuthenticationSession implements AuthenticationSession {
  _FakeAuthenticationSession({String? userId})
    : current = userId == null ? null : _session(userId);

  @override
  final SessionModel? current;

  @override
  String? get currentUserId => current?.id;

  @override
  String? get currentEmail => current?.email;

  @override
  bool get isAuthenticated => current != null;

  @override
  AuthenticationSessionStatus get status => isAuthenticated
      ? AuthenticationSessionStatus.authenticated
      : AuthenticationSessionStatus.unauthenticated;

  @override
  Object? get error => null;

  @override
  String get currentName => current?.name ?? '';

  @override
  List<String> get currentPermissions => const [];

  @override
  List<String> get currentRoles => const [];

  @override
  bool get isActive => isAuthenticated;

  @override
  bool get isAdmin => false;

  @override
  bool get isClient => isAuthenticated;

  @override
  bool get isExpert => false;

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
  }) async => 'user_1';

  @override
  Future<void> signOut() async {}

  @override
  void addListener(AuthenticationSessionListener listener) {}

  @override
  void removeListener(AuthenticationSessionListener listener) {}
}

SessionModel _session(String userId) {
  return SessionModel(
    id: userId,
    email: 'user@mentora.test',
    name: 'User',
    photoUrl: '',
    countryCode: 'ML',
    currency: 'XOF',
    language: 'fr',
    roles: const ['client'],
    permissions: const [],
    isActive: true,
    isVerified: true,
    isPremium: false,
  );
}
