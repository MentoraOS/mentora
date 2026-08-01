import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/transcript/transcript_application_service.dart';
import 'package:mentora/domain/transcript/consultation_audio_stream.dart';
import 'package:mentora/domain/transcript/transcript_provider.dart';
import 'package:mentora/infrastructure/transcript/simulated_transcript_provider.dart';

void main() {
  group('TranscriptApplicationService', () {
    test('start and stop delegate to the provider behind the port', () async {
      final provider = _RecordingProvider();
      final service = _service(provider);
      final audio = _AudioStream();

      await service.start(sessionId: 'mentora_consultation_b1', audio: audio);
      await service.stop();

      expect(provider.started, [('mentora_consultation_b1', audio)]);
      expect(provider.stopped, 1);
    });

    test('an unauthenticated session fails typed before the provider', () async {
      final provider = _RecordingProvider();
      final service = TranscriptApplicationService(
        session: _Session(null),
        provider: provider,
      );

      await expectLater(
        service.start(sessionId: 's1', audio: _AudioStream()),
        throwsA(isA<TranscriptUnauthenticatedFailure>()),
      );
      expect(() => service.events(), throwsA(isA<TranscriptFailure>()));
      expect(provider.started, isEmpty);
    });

    test('provider errors surface as typed transcript failures', () async {
      final service = _service(_RecordingProvider(error: StateError('down')));

      await expectLater(
        service.start(sessionId: 's1', audio: _AudioStream()),
        throwsA(isA<TranscriptUnavailableFailure>()),
      );
    });

    test('typed provider failures pass through unchanged', () {
      final service = _service(
        _RecordingProvider(error: const TranscriptAlreadyActiveFailure()),
      );

      expect(
        () => service.start(sessionId: 's1', audio: _AudioStream()),
        throwsA(isA<TranscriptAlreadyActiveFailure>()),
      );
    });
  });

  group('SimulatedTranscriptProvider', () {
    test('the opaque audio flow produces lifecycle events only', () async {
      final provider = SimulatedTranscriptProvider();
      final audio = _AudioStream();
      final events = <TranscriptEvent>[];
      final subscription = provider.stream().listen(events.add);

      await provider.start(sessionId: 's1', audio: audio);
      audio.push(const ConsultationAudioFrame(
        sessionId: 's1',
        participantIdentity: 'b1_client_userA',
        payload: 'opaque_audio_handle',
      ));
      await Future<void>.delayed(Duration.zero);
      await provider.stop();
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(events.map((event) => event.kind).toList(), [
        TranscriptEventKind.started,
        TranscriptEventKind.audioReceived,
        TranscriptEventKind.stopped,
      ]);
      expect(events.map((event) => event.sessionId).toSet(), {'s1'});
    });

    test('a second start fails closed while a session is active', () async {
      final provider = SimulatedTranscriptProvider();
      await provider.start(sessionId: 's1', audio: _AudioStream());

      await expectLater(
        provider.start(sessionId: 's2', audio: _AudioStream()),
        throwsA(isA<TranscriptAlreadyActiveFailure>()),
      );
    });

    test('stopping detaches from the audio and is idempotent', () async {
      final provider = SimulatedTranscriptProvider();
      final audio = _AudioStream();
      final events = <TranscriptEvent>[];
      final subscription = provider.stream().listen(events.add);

      await provider.start(sessionId: 's1', audio: audio);
      await provider.stop();
      await provider.stop();
      // Audio after stop never produces an event.
      audio.push(const ConsultationAudioFrame(
        sessionId: 's1',
        participantIdentity: 'x',
        payload: 'opaque',
      ));
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(events.map((event) => event.kind).toList(), [
        TranscriptEventKind.started,
        TranscriptEventKind.stopped,
      ]);
    });
  });

  group('Transcript foundation — governance', () {
    test('no AI vendor exists anywhere in the transcript layer', () {
      const files = [
        'lib/domain/transcript/consultation_audio_stream.dart',
        'lib/domain/transcript/transcript_provider.dart',
        'lib/application/transcript/transcript_application_service.dart',
        'lib/infrastructure/transcript/livekit_audio_stream_adapter.dart',
        'lib/infrastructure/transcript/simulated_transcript_provider.dart',
      ];
      for (final path in files) {
        final source = File(path).readAsStringSync().toLowerCase();
        for (final vendor in const [
          'openai',
          'deepgram',
          'google speech',
          'assemblyai',
          'azure',
        ]) {
          expect(source, isNot(contains(vendor)), reason: '$path: $vendor');
        }
      }
    });

    test('the domain audio contract is pure and the events carry no '
        'transcription content', () {
      final audio = File(
        'lib/domain/transcript/consultation_audio_stream.dart',
      ).readAsStringSync();
      final provider = File(
        'lib/domain/transcript/transcript_provider.dart',
      ).readAsStringSync();

      expect(audio, isNot(contains('import ')));
      // Lifecycle only: sessionId + kind, no transcription payload fields.
      expect(provider, contains('final String sessionId;'));
      expect(provider, contains('final TranscriptEventKind kind;'));
      expect(provider, isNot(contains('String transcript')));
      expect(provider, isNot(contains('String content')));
    });

    test('the LiveKit audio bridge forwards opaque handles only', () {
      final source = File(
        'lib/infrastructure/transcript/livekit_audio_stream_adapter.dart',
      ).readAsStringSync();

      expect(source, contains("import 'package:livekit_client/"));
      expect(source, contains('AudioTrack'));
      expect(source, contains('TrackSubscribedEvent'));
      // Transport only: nothing is decoded, interpreted or stored.
      expect(source, isNot(contains('decode')));
      expect(source, isNot(contains('Firestore')));
      expect(source, isNot(contains('http')));
    });
  });
}

TranscriptApplicationService _service(TranscriptProvider provider) {
  return TranscriptApplicationService(
    session: _Session('client_1'),
    provider: provider,
  );
}

final class _AudioStream implements ConsultationAudioStream {
  final StreamController<ConsultationAudioFrame> _frames =
      StreamController<ConsultationAudioFrame>.broadcast(sync: true);

  void push(ConsultationAudioFrame frame) => _frames.add(frame);

  @override
  Stream<ConsultationAudioFrame> get frames => _frames.stream;
}

final class _RecordingProvider implements TranscriptProvider {
  _RecordingProvider({this.error});

  final Object? error;
  final List<(String, ConsultationAudioStream)> started = [];
  int stopped = 0;

  @override
  Future<void> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  }) async {
    if (error case final cause?) throw cause;
    started.add((sessionId, audio));
  }

  @override
  Future<void> stop() async {
    stopped += 1;
  }

  @override
  Stream<TranscriptEvent> stream() => const Stream.empty();
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
