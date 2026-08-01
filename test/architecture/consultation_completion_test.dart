import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/consultation_completion_application_service.dart';
import 'package:mentora/application/booking/consultation_completion_failure.dart';
import 'package:mentora/application/notification/booking_notification_application_service.dart';
import 'package:mentora/application/video_session/video_session_application_service.dart';
import 'package:mentora/domain/booking/booking_overview.dart';
import 'package:mentora/domain/booking/consultation_completion_repository.dart';
import 'package:mentora/domain/notification/booking_notification_provider.dart';
import 'package:mentora/infrastructure/notification/simulated_notification_provider.dart';
import 'package:mentora/infrastructure/video_session/livekit_cloud_adapter.dart';
import 'package:mentora/screens/consultation_dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('ConsultationCompletionApplicationService', () {
    test('a participant completes the consultation', () async {
      final repository = _CompletionRepository();
      final service = ConsultationCompletionApplicationService(
        session: _Session('client_1'),
        repository: repository,
      );

      await service.complete('b1');

      expect(repository.calls, [('b1', 'client_1')]);
    });

    test('an unauthenticated session fails typed, nothing reaches the '
        'repository', () async {
      final repository = _CompletionRepository();
      final service = ConsultationCompletionApplicationService(
        session: _Session(null),
        repository: repository,
      );

      await expectLater(
        service.complete('b1'),
        throwsA(isA<ConsultationCompletionUnauthenticatedFailure>()),
      );
      expect(repository.calls, isEmpty);
    });

    test('a foreign or unknown booking fails as not-found', () {
      final service = ConsultationCompletionApplicationService(
        session: _Session('intruder'),
        repository: _CompletionRepository(
          error: const ConsultationCompletionNotFoundException(),
        ),
      );

      expect(
        () => service.complete('b1'),
        throwsA(isA<ConsultationCompletionNotFoundFailure>()),
      );
    });

    test('a non-completable state fails typed with the current status', () {
      final service = ConsultationCompletionApplicationService(
        session: _Session('client_1'),
        repository: _CompletionRepository(
          error: const ConsultationCompletionStateException(
            currentStatus: 'cancelled',
          ),
        ),
      );

      expect(
        () => service.complete('b1'),
        throwsA(
          isA<ConsultationCompletionInvalidStateFailure>().having(
            (failure) => failure.currentStatus,
            'currentStatus',
            'cancelled',
          ),
        ),
      );
    });

    test('infrastructure errors surface as repository failures', () {
      final service = ConsultationCompletionApplicationService(
        session: _Session('client_1'),
        repository: _CompletionRepository(error: StateError('offline')),
      );

      expect(
        () => service.complete('b1'),
        throwsA(isA<ConsultationCompletionRepositoryFailure>()),
      );
    });
  });

  group('Consultation completion — adapter contract', () {
    final source = File(
      'lib/infrastructure/booking/'
      'firestore_consultation_completion_repository.dart',
    ).readAsStringSync();

    test('transactionally completes only confirmed/paid reservations', () {
      expect(source, contains('runTransaction'));
      expect(source, contains("collection('bookings')"));
      expect(source, contains("{'confirmed', 'paid'}"));
      // Foreign users read as not-found, never as a hint.
      expect(
        source,
        contains("data['clientId'] != userId && data['expertId'] != userId"),
      );
    });

    test('writes only the status and the server-side completedAt', () {
      expect(source, contains("'status': 'completed'"));
      expect(source, contains("'completedAt': FieldValue.serverTimestamp()"));
      // The canonical temporal facts are never rewritten by completion.
      expect(source, isNot(contains("'startUtc'")));
      expect(source, isNot(contains("'endUtc'")));
      expect(source, isNot(contains("'expertTimezone'")));
      expect(source, isNot(contains("'bookingDate'")));
      expect(source, isNot(contains("'bookingTime'")));
    });
  });

  group('Consultation dashboard — terminer la consultation', () {
    testWidgets('completing notifies both parties and closes the space', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repository = _CompletionRepository();
      final notifications = SimulatedNotificationProvider();
      await tester.pumpWidget(
        _app(
          _booking(status: 'confirmed'),
          repository: repository,
          notifications: notifications,
        ),
      );

      await tester.ensureVisible(find.text('Terminer la consultation'));
      await tester.tap(find.text('Terminer la consultation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();

      expect(repository.calls, [('b1', 'client_1')]);
      expect(notifications.sent, hasLength(2));
      expect(
        notifications.sent.map((n) => n.event).toSet(),
        {BookingNotificationEvent.bookingCompleted},
      );
      expect(notifications.sent.map((n) => n.recipientId).toSet(), {
        'client_1',
        'expert_1',
      });
      expect(find.text('Consultation terminée.'), findsOneWidget);
      // The action disappears and the badge reflects the closed lifecycle.
      expect(find.text('Terminer la consultation'), findsNothing);
      expect(find.text('Terminée'), findsOneWidget);
    });

    testWidgets('a paid legacy reservation can also be completed', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_app(_booking(status: 'paid')));

      expect(find.text('Terminer la consultation'), findsOneWidget);
    });

    testWidgets('the action never appears outside confirmed/paid', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final status in const ['completed', 'cancelled']) {
        await tester.pumpWidget(_app(_booking(status: status)));
        expect(find.text('Terminer la consultation'), findsNothing);
      }
    });

    testWidgets('dismissing the dialog completes nothing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repository = _CompletionRepository();
      final notifications = SimulatedNotificationProvider();
      await tester.pumpWidget(
        _app(
          _booking(status: 'confirmed'),
          repository: repository,
          notifications: notifications,
        ),
      );

      await tester.ensureVisible(find.text('Terminer la consultation'));
      await tester.tap(find.text('Terminer la consultation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(repository.calls, isEmpty);
      expect(notifications.sent, isEmpty);
      expect(find.text('Terminer la consultation'), findsOneWidget);
    });

    testWidgets('an invalid state surfaces an error and keeps the action', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final notifications = SimulatedNotificationProvider();
      await tester.pumpWidget(
        _app(
          _booking(status: 'confirmed'),
          repository: _CompletionRepository(
            error: const ConsultationCompletionStateException(
              currentStatus: 'cancelled',
            ),
          ),
          notifications: notifications,
        ),
      );

      await tester.ensureVisible(find.text('Terminer la consultation'));
      await tester.tap(find.text('Terminer la consultation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();

      expect(
        find.text('Cette consultation ne peut plus être terminée.'),
        findsOneWidget,
      );
      expect(notifications.sent, isEmpty);
      expect(find.text('Terminer la consultation'), findsOneWidget);
    });
  });
}

BookingOverview _booking({required String status}) {
  return BookingOverview(
    bookingId: 'b1',
    status: status,
    clientId: 'client_1',
    expertId: 'expert_1',
    expertName: 'Awa',
    bookingDate: '2026-08-03',
    bookingTime: '09:00',
    durationMinutes: 60,
    amountMinor: 50000,
    currency: 'XOF',
    expertTimezone: 'Africa/Bamako',
    aiSummary: '',
    raw: const <String, dynamic>{},
  );
}

Widget _app(
  BookingOverview booking, {
  _CompletionRepository? repository,
  SimulatedNotificationProvider? notifications,
}) {
  final session = _Session('client_1');
  return MultiProvider(
    providers: [
      Provider<AuthenticationSession>.value(value: session),
      Provider<ConsultationCompletionApplicationService>.value(
        value: ConsultationCompletionApplicationService(
          session: session,
          repository: repository ?? _CompletionRepository(),
        ),
      ),
      Provider<BookingNotificationApplicationService>.value(
        value: BookingNotificationApplicationService(
          session: session,
          provider: notifications ?? SimulatedNotificationProvider(),
        ),
      ),
      Provider<VideoSessionApplicationService>.value(
        value: VideoSessionApplicationService(
          session: session,
          provider: const LiveKitCloudAdapter(),
        ),
      ),
    ],
    child: MaterialApp(home: ConsultationDashboardScreen(booking: booking)),
  );
}

final class _CompletionRepository implements ConsultationCompletionRepository {
  _CompletionRepository({this.error});

  final Object? error;
  final List<(String, String)> calls = [];

  @override
  Future<void> complete({
    required String bookingId,
    required String userId,
  }) async {
    if (error case final cause?) throw cause;
    calls.add((bookingId, userId));
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isExpert => false;

  @override
  bool get isAuthenticated => currentUserId != null;
}
