import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/recording/consultation_recording_application_service.dart';
import 'package:mentora/domain/recording/consultation_recording.dart';
import 'package:mentora/domain/recording/recording_provider.dart';
import 'package:mentora/infrastructure/recording/livekit_recording_provider.dart';
import 'package:mentora/infrastructure/recording/simulated_recording_provider.dart';

void main() {
  group('ConsultationRecordingApplicationService — double consent', () {
    test('no recording ever starts without BOTH consents — fail closed', () async {
      final provider = _RecordingProviderFake();
      final service = _service(provider);

      for (final (client, expert) in const [
        (false, false),
        (true, false),
        (false, true),
      ]) {
        await expectLater(
          service.start(
            bookingId: 'b1',
            clientConsent: client,
            expertConsent: expert,
          ),
          throwsA(isA<RecordingConsentRequiredFailure>()),
          reason: 'client=$client expert=$expert',
        );
      }
      expect(provider.started, isEmpty);
    });

    test('the double consent starts exactly one lifecycle', () async {
      final provider = _RecordingProviderFake();
      final service = _service(provider);

      final session = await service.start(
        bookingId: 'b1',
        clientConsent: true,
        expertConsent: true,
      );

      expect(provider.started, ['b1']);
      expect(session.recording.bookingId, 'b1');
      expect(service.recording().bookingId, 'b1');

      await expectLater(
        service.start(
          bookingId: 'b1',
          clientConsent: true,
          expertConsent: true,
        ),
        throwsA(isA<RecordingAlreadyActiveFailure>()),
      );
    });

    test('an unauthenticated session fails typed before anything', () async {
      final provider = _RecordingProviderFake();
      final service = ConsultationRecordingApplicationService(
        session: _Session(null),
        provider: provider,
      );

      await expectLater(
        service.start(
          bookingId: 'b1',
          clientConsent: true,
          expertConsent: true,
        ),
        throwsA(isA<RecordingUnauthenticatedFailure>()),
      );
      expect(provider.started, isEmpty);
    });

    test('recording and stop without an active session fail closed', () async {
      final service = _service(_RecordingProviderFake());

      expect(
        () => service.recording(),
        throwsA(isA<RecordingUnavailableFailure>()),
      );
      await expectLater(
        service.stop(),
        throwsA(isA<RecordingUnavailableFailure>()),
      );
    });

    test('stop seals the lifecycle and allows a fresh session', () async {
      final service = _service(_RecordingProviderFake());
      await service.start(
        bookingId: 'b1',
        clientConsent: true,
        expertConsent: true,
      );

      final result = await service.stop();

      expect(result.recording.status, RecordingStatus.completed);
      await service.start(
        bookingId: 'b2',
        clientConsent: true,
        expertConsent: true,
      );
    });
  });

  group('SimulatedRecordingProvider — the lifecycle without media', () {
    test('walks STARTING -> RECORDING then STOPPING -> COMPLETED', () async {
      const provider = SimulatedRecordingProvider();

      final session = await provider.start(bookingId: 'b1');
      final transitions = <RecordingStatus>[];
      final subscription = session.updates.listen(
        (recording) => transitions.add(recording.status),
      );

      expect(session.recording.status, RecordingStatus.notStarted);
      await Future<void>.delayed(Duration.zero);
      expect(session.recording.status, RecordingStatus.recording);

      final result = await session.stop();
      await subscription.cancel();

      expect(transitions, [
        RecordingStatus.starting,
        RecordingStatus.recording,
        RecordingStatus.stopping,
        RecordingStatus.completed,
      ]);
      expect(result.recording.status, RecordingStatus.completed);
      expect(result.recording.recordingId, 'simulated_recording_b1');
    });
  });

  group('LiveKitRecordingProvider — fail closed until the backend', () {
    test('unconfigured or unconnected always fails closed, never a fake '
        'recording', () async {
      const unconfigured = LiveKitRecordingProvider(
        configuration: LiveKitRecordingConfiguration(
          egressEndpoint: '',
          apiKey: '',
        ),
      );
      const configured = LiveKitRecordingProvider(
        configuration: LiveKitRecordingConfiguration(
          egressEndpoint: 'injected',
          apiKey: 'injected',
        ),
      );

      await expectLater(
        unconfigured.start(bookingId: 'b1'),
        throwsA(isA<RecordingUnavailableFailure>()),
      );
      await expectLater(
        configured.start(bookingId: 'b1'),
        throwsA(isA<RecordingUnavailableFailure>()),
      );
    });

    test('no key, secret, URL or vendor SDK is hard-coded', () {
      final source = File(
        'lib/infrastructure/recording/livekit_recording_provider.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('String.fromEnvironment')));
      expect(source, isNot(contains('wss://')));
      expect(source, isNot(contains('https://')));
      expect(source, isNot(contains("import 'package:livekit_client")));
      expect(source, contains('required this.egressEndpoint'));
    });
  });

  group('Governance — the recording chain is the only route', () {
    test('a recording carries exactly the four facts and the six '
        'statuses', () {
      final source = File(
        'lib/domain/recording/consultation_recording.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String bookingId;',
        'final String recordingId;',
        'final RecordingStatus status;',
        'final DateTime? createdAt;',
      ]);
      expect(RecordingStatus.values.map((value) => value.name).toList(), [
        'notStarted',
        'starting',
        'recording',
        'stopping',
        'completed',
        'failed',
      ]);
    });

    test('no persistence and no vendor anywhere in the recording layer', () {
      for (final path in const [
        'lib/domain/recording/consultation_recording.dart',
        'lib/domain/recording/recording_provider.dart',
        'lib/application/recording/'
            'consultation_recording_application_service.dart',
        'lib/infrastructure/recording/simulated_recording_provider.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains('Firestore')), reason: path);
        expect(source, isNot(contains('cloud_firestore')), reason: path);
        expect(source, isNot(contains('firebase_storage')), reason: path);
        expect(source, isNot(contains('livekit')), reason: path);
        expect(source, isNot(contains('LiveKit')), reason: path);
      }
    });

    test('the recording surface is confined — no screen, no widget, no '
        'business module', () {
      const allowedSurface = [
        'lib/domain/recording/consultation_recording.dart',
        'lib/domain/recording/recording_provider.dart',
        'lib/application/recording/'
            'consultation_recording_application_service.dart',
        'lib/infrastructure/recording/simulated_recording_provider.dart',
        'lib/infrastructure/recording/livekit_recording_provider.dart',
        'lib/composition/mentora_composition_root.dart',
        'lib/composition/mentora_dependencies.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('RecordingSession') ||
                source.contains('SimulatedRecordingProvider') ||
                source.contains('LiveKitRecordingProvider') ||
                source.contains(
                  'ConsultationRecordingApplicationService',
                )) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

ConsultationRecordingApplicationService _service(
  RecordingProvider provider,
) {
  return ConsultationRecordingApplicationService(
    session: _Session('client_1'),
    provider: provider,
  );
}

final class _RecordingProviderFake implements RecordingProvider {
  final List<String> started = [];

  @override
  Future<RecordingSession> start({required String bookingId}) async {
    started.add(bookingId);
    return _FakeSession(bookingId);
  }
}

final class _FakeSession implements RecordingSession {
  _FakeSession(this.bookingId);

  final String bookingId;

  @override
  ConsultationRecording get recording => ConsultationRecording(
    bookingId: bookingId,
    recordingId: 'rec_$bookingId',
    status: RecordingStatus.recording,
    createdAt: null,
  );

  @override
  Stream<ConsultationRecording> get updates => const Stream.empty();

  @override
  Future<RecordingResult> stop() async {
    return RecordingResult(
      recording: ConsultationRecording(
        bookingId: bookingId,
        recordingId: 'rec_$bookingId',
        status: RecordingStatus.completed,
        createdAt: null,
      ),
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
