import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/recording/consultation_recording.dart';
import 'package:mentora/domain/recording/recording_provider.dart';
import 'package:mentora/widgets/recording_consent_controller.dart';
import 'package:mentora/widgets/recording_consent_overlay.dart';

void main() {
  group('RecordingConsentController', () {
    test('each participant decides independently', () {
      final controller = RecordingConsentController();
      addTearDown(controller.dispose);

      controller.acceptExpert();

      expect(controller.expertDecision, ConsentDecision.accepted);
      expect(controller.clientDecision, ConsentDecision.pending);
      expect(controller.outcome, ConsentOutcome.waiting);
    });

    test('both accepted authorizes the recording', () {
      final controller = RecordingConsentController();
      addTearDown(controller.dispose);

      controller.acceptExpert();
      controller.acceptClient();

      expect(controller.outcome, ConsentOutcome.authorized);
    });

    test('ONE refusal makes the recording unavailable — immediately and '
        'finally', () {
      final controller = RecordingConsentController();
      addTearDown(controller.dispose);

      controller.acceptExpert();
      controller.refuseClient();
      expect(controller.outcome, ConsentOutcome.unavailable);

      // No renegotiation, no pressure: the decision is final.
      controller.acceptClient();
      expect(controller.clientDecision, ConsentDecision.refused);
      expect(controller.outcome, ConsentOutcome.unavailable);
    });

    test('follows ONLY the RecordingSession lifecycle when one exists', () async {
      final session = _FakeRecordingSession();
      final controller = RecordingConsentController(session: session);
      addTearDown(controller.dispose);

      session.push(RecordingStatus.recording);
      await Future<void>.delayed(Duration.zero);

      expect(controller.recordingStatus, RecordingStatus.recording);
    });
  });

  group('RecordingConsentOverlay', () {
    testWidgets('shows exactly both consents and the global status', (
      tester,
    ) async {
      final controller = RecordingConsentController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));

      expect(find.text('Consentement Expert'), findsOneWidget);
      expect(find.text('Consentement Client'), findsOneWidget);
      expect(find.text('En attente'), findsNWidgets(2));
      expect(find.text('En attente des consentements'), findsOneWidget);
      // Exactly accept/refuse per pending participant, nothing else.
      expect(find.byTooltip('Accepter — Consentement Expert'), findsOneWidget);
      expect(find.byTooltip('Refuser — Consentement Expert'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('both accepting shows "Enregistrement autorisé"', (
      tester,
    ) async {
      final controller = RecordingConsentController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      await tester.tap(find.byTooltip('Accepter — Consentement Expert'));
      await tester.pump();
      await tester.tap(find.byTooltip('Accepter — Consentement Client'));
      await tester.pump();

      expect(find.text('Enregistrement autorisé'), findsOneWidget);
      expect(find.text('Accepté'), findsNWidgets(2));
    });

    testWidgets('one refusal shows "Enregistrement indisponible" and is '
        'respected', (tester) async {
      final controller = RecordingConsentController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      await tester.tap(find.byTooltip('Refuser — Consentement Client'));
      await tester.pump();

      expect(find.text('Enregistrement indisponible'), findsOneWidget);
      expect(find.text('Refusé'), findsOneWidget);
      // The refusal removes the choice — no re-ask, no pressure.
      expect(
        find.byTooltip('Accepter — Consentement Client'),
        findsNothing,
      );
    });

    testWidgets('the overlay retracts and the video underneath keeps '
        'receiving taps', (tester) async {
      final controller = RecordingConsentController();
      addTearDown(controller.dispose);
      var tapped = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => tapped++,
                    child: const ColoredBox(color: Colors.black),
                  ),
                ),
                Positioned.fill(
                  child: RecordingConsentOverlay(controller: controller),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Enregistrement'));
      await tester.pump();
      expect(find.text('Consentement Expert'), findsNothing);

      await tester.tapAt(const Offset(400, 300));
      expect(tapped, 1);
    });
  });

  group('Governance — consent is a projection, never a pipeline', () {
    test('the consent components know only the recording session '
        'contract', () {
      for (final path in const [
        'lib/widgets/recording_consent_controller.dart',
        'lib/widgets/recording_consent_card.dart',
        'lib/widgets/recording_consent_overlay.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'RecordingProvider ',
          'LiveKitRecordingProvider',
          'livekit',
          'LiveKit',
          'cloud_firestore',
          'Firestore',
          'firebase_storage',
          'Storage',
          'HttpClient',
          'AIGateway',
          'showDialog',
          'ConsultationRecordingApplicationService',
        ]) {
          expect(
            source,
            isNot(contains(forbidden)),
            reason: '$path must not know $forbidden',
          );
        }
      }
      final controller = File(
        'lib/widgets/recording_consent_controller.dart',
      ).readAsStringSync();
      expect(controller, contains('RecordingSession'));
    });

    test('the consent surface in the live screen is opt-in and passive', () {
      final source = File(
        'lib/screens/live_consultation_screen.dart',
      ).readAsStringSync();

      expect(source, contains('recordingConsent = false'));
      expect(source, contains('RecordingConsentOverlay'));
    });
  });
}

Widget _app(RecordingConsentController controller) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.black)),
          Positioned.fill(
            child: RecordingConsentOverlay(controller: controller),
          ),
        ],
      ),
    ),
  );
}

final class _FakeRecordingSession implements RecordingSession {
  final StreamController<ConsultationRecording> _updates =
      StreamController<ConsultationRecording>.broadcast(sync: true);

  void push(RecordingStatus status) {
    _updates.add(
      ConsultationRecording(
        bookingId: 'b1',
        recordingId: 'rec_b1',
        status: status,
        createdAt: DateTime.utc(2026, 8, 1),
      ),
    );
  }

  @override
  ConsultationRecording get recording => ConsultationRecording(
    bookingId: 'b1',
    recordingId: 'rec_b1',
    status: RecordingStatus.recording,
    createdAt: DateTime.utc(2026, 8, 1),
  );

  @override
  Stream<ConsultationRecording> get updates => _updates.stream;

  @override
  Future<RecordingResult> stop() async {
    return RecordingResult(
      recording: ConsultationRecording(
        bookingId: 'b1',
        recordingId: 'rec_b1',
        status: RecordingStatus.completed,
        createdAt: DateTime.utc(2026, 8, 1),
      ),
    );
  }
}
