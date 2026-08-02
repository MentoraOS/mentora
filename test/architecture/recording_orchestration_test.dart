import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/recording/consultation_recording_application_service.dart';
import 'package:mentora/application/recording/recording_orchestrator.dart';
import 'package:mentora/domain/recording/consultation_recording.dart';
import 'package:mentora/domain/recording/recording_provider.dart';
import 'package:mentora/widgets/recording_indicator.dart';

void main() {
  group('RecordingOrchestrator — coordinator, never a decision-maker', () {
    test('nothing starts before the double agreement', () async {
      final provider = _RecordingProviderFake();
      final orchestrator = _orchestrator(provider);
      addTearDown(orchestrator.dispose);

      await orchestrator.onConsents(
        clientConsent: true,
        expertConsent: false,
      );
      await orchestrator.onConsents(
        clientConsent: false,
        expertConsent: true,
      );

      expect(provider.started, isEmpty);
      expect(orchestrator.session, isNull);
    });

    test('the double agreement starts EXACTLY once', () async {
      final provider = _RecordingProviderFake();
      final orchestrator = _orchestrator(provider);
      addTearDown(orchestrator.dispose);

      await orchestrator.onConsents(clientConsent: true, expertConsent: true);
      await orchestrator.onConsents(clientConsent: true, expertConsent: true);

      expect(provider.started, ['b1']);
      expect(orchestrator.session, isNotNull);
    });

    test('the session lifecycle is relayed verbatim', () async {
      final provider = _RecordingProviderFake();
      final orchestrator = _orchestrator(provider);
      addTearDown(orchestrator.dispose);

      await orchestrator.onConsents(clientConsent: true, expertConsent: true);
      final relayed = <RecordingStatus>[];
      final subscription = orchestrator.updates.listen(
        (recording) => relayed.add(recording.status),
      );

      provider.sessions.single.push(RecordingStatus.recording);
      provider.sessions.single.push(RecordingStatus.stopping);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(relayed, [RecordingStatus.recording, RecordingStatus.stopping]);
    });

    test('a start failure is relayed, never swallowed, and a later '
        'agreement can try again', () async {
      final provider = _RecordingProviderFake(error: StateError('down'));
      final orchestrator = _orchestrator(provider);
      addTearDown(orchestrator.dispose);
      final errors = <Object>[];
      final subscription = orchestrator.updates.listen(
        (_) {},
        onError: errors.add,
      );

      await orchestrator.onConsents(clientConsent: true, expertConsent: true);
      await Future<void>.delayed(Duration.zero);

      expect(errors, hasLength(1));
      expect(orchestrator.session, isNull);

      provider.error = null;
      await orchestrator.onConsents(clientConsent: true, expertConsent: true);
      expect(orchestrator.session, isNotNull);
      await subscription.cancel();
    });

    test('the service remains the enforcer — the orchestrator passes the '
        'consents verbatim', () async {
      final provider = _RecordingProviderFake();
      final orchestrator = _orchestrator(provider);
      addTearDown(orchestrator.dispose);

      await orchestrator.onConsents(clientConsent: true, expertConsent: true);

      // The real service received both TRUE consents (anything else would
      // have failed closed inside it).
      expect(provider.started, ['b1']);
    });
  });

  group('RecordingIndicator — follows only the relayed session', () {
    testWidgets('renders each lifecycle state exactly', (tester) async {
      final provider = _RecordingProviderFake();
      final orchestrator = _orchestrator(provider);
      addTearDown(orchestrator.dispose);
      await orchestrator.onConsents(clientConsent: true, expertConsent: true);
      final session = provider.sessions.single;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingIndicator(orchestrator: orchestrator),
          ),
        ),
      );

      // NOT_STARTED: no indicator at all.
      expect(find.text('REC'), findsNothing);

      Future<void> transition(RecordingStatus status) async {
        session.push(status);
        // Broadcast delivery is asynchronous: settle before asserting.
        await tester.pump();
        await tester.pump();
      }

      await transition(RecordingStatus.starting);
      expect(find.text('REC...'), findsOneWidget);

      await transition(RecordingStatus.recording);
      expect(find.text('REC'), findsOneWidget);

      await transition(RecordingStatus.stopping);
      expect(find.text('Fin...'), findsOneWidget);

      await transition(RecordingStatus.completed);
      expect(find.text('REC'), findsNothing);
      expect(find.text('Fin...'), findsNothing);

      await transition(RecordingStatus.failed);
      expect(find.text('REC indisponible'), findsOneWidget);
    });
  });

  group('Governance — the orchestration is a connection, nothing more', () {
    test('the orchestrator knows only the recording service and the '
        'session contract', () {
      final source = File(
        'lib/application/recording/recording_orchestrator.dart',
      ).readAsStringSync();

      expect(source, contains('ConsultationRecordingApplicationService'));
      expect(source, contains('RecordingSession'));
      for (final forbidden in const [
        'livekit',
        'LiveKit',
        'cloud_firestore',
        'Firestore',
        'firebase_storage',
        'HttpClient',
        'AIGateway',
        'ConsentDecision',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the orchestrator must not know $forbidden',
        );
      }
    });

    test('the indicator knows only the relayed lifecycle', () {
      final source = File(
        'lib/widgets/recording_indicator.dart',
      ).readAsStringSync();

      expect(source, contains('RecordingOrchestrator'));
      for (final forbidden in const [
        'livekit',
        'LiveKit',
        'cloud_firestore',
        'Firestore',
        'firebase_storage',
        'HttpClient',
        'AIGateway',
        'showDialog',
        'RecordingConsent',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the indicator must not know $forbidden',
        );
      }
    });

    test('the live screen only CONNECTS consent to the coordinator', () {
      final source = File(
        'lib/screens/live_consultation_screen.dart',
      ).readAsStringSync();

      expect(source, contains('recordingOrchestrator'));
      expect(source, contains('onConsents'));
      expect(source, contains('RecordingIndicator'));
      // No business rule duplicated: the screen never starts a recording
      // itself and never touches the service.
      expect(
        source,
        isNot(contains('ConsultationRecordingApplicationService')),
      );
    });
  });
}

RecordingOrchestrator _orchestrator(_RecordingProviderFake provider) {
  return RecordingOrchestrator(
    recording: ConsultationRecordingApplicationService(
      session: _Session('client_1'),
      provider: provider,
    ),
    bookingId: 'b1',
  );
}

final class _RecordingProviderFake implements RecordingProvider {
  _RecordingProviderFake({this.error});

  Object? error;
  final List<String> started = [];
  final List<_FakeSession> sessions = [];

  @override
  Future<RecordingSession> start({required String bookingId}) async {
    if (error case final cause?) throw cause;
    started.add(bookingId);
    final session = _FakeSession(bookingId);
    sessions.add(session);
    return session;
  }
}

final class _FakeSession implements RecordingSession {
  _FakeSession(this.bookingId);

  final String bookingId;
  final StreamController<ConsultationRecording> _updates =
      StreamController<ConsultationRecording>.broadcast(sync: true);

  RecordingStatus _status = RecordingStatus.notStarted;

  void push(RecordingStatus status) {
    _status = status;
    _updates.add(recording);
  }

  @override
  ConsultationRecording get recording => ConsultationRecording(
    bookingId: bookingId,
    recordingId: 'rec_$bookingId',
    status: _status,
    createdAt: DateTime.utc(2026, 8, 1),
  );

  @override
  Stream<ConsultationRecording> get updates => _updates.stream;

  @override
  Future<RecordingResult> stop() async {
    return RecordingResult(recording: recording);
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
