import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/transcript/realtime_transcript_application_service.dart';
import 'package:mentora/domain/ai_gateway/ai_gateway.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';
import 'package:mentora/domain/transcript/consultation_audio_stream.dart';
import 'package:mentora/domain/transcript/transcript_chunk.dart';
import 'package:mentora/domain/transcript/transcript_provider.dart';
import 'package:mentora/infrastructure/ai_gateway/deepgram_adapter.dart';
import 'package:mentora/infrastructure/transcript/ai_transcript_provider.dart';

void main() {
  group('RealtimeTranscriptApplicationService', () {
    test('start attaches one living stream through the provider port', () async {
      final provider = _RecordingProvider();
      final service = _service(provider);
      final audio = _AudioStream();

      final stream = await service.start(
        sessionId: 'mentora_consultation_b1',
        audio: audio,
      );

      expect(provider.started, [('mentora_consultation_b1', audio)]);
      expect(stream.status, TranscriptStatus.transcribing);
      expect(service.chunks(), isNotNull);
    });

    test('one live transcription at a time — fail closed', () async {
      final service = _service(_RecordingProvider());
      await service.start(sessionId: 's1', audio: _AudioStream());

      await expectLater(
        service.start(sessionId: 's2', audio: _AudioStream()),
        throwsA(isA<TranscriptAlreadyActiveFailure>()),
      );
    });

    test('stop seals the flux and allows a fresh session', () async {
      final service = _service(_RecordingProvider());
      await service.start(sessionId: 's1', audio: _AudioStream());

      final result = await service.stop();

      expect(result.sessionId, 's1');
      expect(result.status, TranscriptStatus.stopped);
      // A new session can start again.
      await service.start(sessionId: 's2', audio: _AudioStream());
    });

    test('an unauthenticated session fails typed before the provider', () async {
      final provider = _RecordingProvider();
      final service = RealtimeTranscriptApplicationService(
        session: _Session(null),
        provider: provider,
      );

      await expectLater(
        service.start(sessionId: 's1', audio: _AudioStream()),
        throwsA(isA<TranscriptUnauthenticatedFailure>()),
      );
      expect(provider.started, isEmpty);
    });

    test('chunks and stop without an active session fail closed', () async {
      final service = _service(_RecordingProvider());

      expect(
        () => service.chunks(),
        throwsA(isA<TranscriptUnavailableFailure>()),
      );
      await expectLater(
        service.stop(),
        throwsA(isA<TranscriptUnavailableFailure>()),
      );
    });
  });

  group('AITranscriptProvider — the governed flux', () {
    test('every audio frame routes through the gateway with '
        'AITask.transcription and becomes a chunk', () async {
      final gateway = _RecordingGateway(
        answers: ['Bonjour docteur.', 'Bonjour, comment allez-vous ?'],
      );
      final audio = _AudioStream();
      final provider = AITranscriptProvider(gateway: gateway);
      final live = await provider.start(sessionId: 's1', audio: audio);
      final chunks = <TranscriptChunk>[];
      final subscription = live.chunks.listen(chunks.add);

      audio.push(_frame(participant: 'b1_client_userA'));
      audio.push(_frame(participant: 'b1_expert_userB'));
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      final requests = gateway.executed;
      expect(requests, hasLength(2));
      expect(requests.map((request) => request.task).toSet(), {
        AITask.transcription,
      });
      expect(requests.first.context['sessionId'], 's1');
      expect(requests.first.context['participantIdentity'], 'b1_client_userA');

      expect(chunks.map((chunk) => chunk.text).toList(), [
        'Bonjour docteur.',
        'Bonjour, comment allez-vous ?',
      ]);
      expect(chunks.first.sessionId, 's1');
      expect(chunks.first.participantIdentity, 'b1_client_userA');
      expect(chunks.last.participantIdentity, 'b1_expert_userB');
      expect(chunks.every((chunk) => chunk.isFinal), isTrue);
      expect(live.status, TranscriptStatus.transcribing);
    });

    test('silence produces no chunk and no error', () async {
      final gateway = _RecordingGateway(answers: ['   ']);
      final audio = _AudioStream();
      final live = await AITranscriptProvider(gateway: gateway)
          .start(sessionId: 's1', audio: audio);
      final chunks = <TranscriptChunk>[];
      final subscription = live.chunks.listen(chunks.add);

      audio.push(_frame());
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(chunks, isEmpty);
      expect(live.status, TranscriptStatus.transcribing);
    });

    test('an engine failure marks the flux failed — never a fake chunk', () async {
      final gateway = _RecordingGateway(error: StateError('engine down'));
      final audio = _AudioStream();
      final live = await AITranscriptProvider(gateway: gateway)
          .start(sessionId: 's1', audio: audio);
      final errors = <Object>[];
      final subscription = live.chunks.listen((_) {}, onError: errors.add);

      audio.push(_frame());
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(errors, hasLength(1));
      expect(live.status, TranscriptStatus.failed);
    });

    test('stopping detaches from the audio and seals the result', () async {
      final gateway = _RecordingGateway(answers: ['Un.']);
      final audio = _AudioStream();
      final live = await AITranscriptProvider(gateway: gateway)
          .start(sessionId: 's1', audio: audio);

      final result = await live.stop();
      audio.push(_frame());
      await Future<void>.delayed(Duration.zero);

      expect(result.status, TranscriptStatus.stopped);
      expect(gateway.executed, isEmpty);
    });
  });

  group('DeepgramAdapter — configuration and fail closed', () {
    test('an unconfigured engine fails closed before any network call', () async {
      const adapter = DeepgramAdapter(
        configuration: DeepgramConfiguration(apiKey: ''),
      );

      await expectLater(
        adapter.execute(
          AIRequest(requestId: 'r1', audio: const [1, 2, 3]),
        ),
        throwsA(isA<AIUnavailableFailure>()),
      );
      expect(await adapter.health(), isFalse);
    });

    test('a non-byte audio payload is refused, never guessed', () {
      const adapter = DeepgramAdapter(
        configuration: DeepgramConfiguration(apiKey: 'injected'),
      );

      expect(
        () => adapter.execute(
          AIRequest(requestId: 'r1', audio: 'a_vendor_track_handle'),
        ),
        throwsA(isA<AIUnavailableFailure>()),
      );
    });

    test('no key, secret, URL or business module is hard-coded outside '
        'the injectable configuration', () {
      final source = File(
        'lib/infrastructure/ai_gateway/deepgram_adapter.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('String.fromEnvironment')));
      expect(source, contains('required this.apiKey'));
      expect(source, isNot(contains('consultation_memory')));
      expect(source, isNot(contains('cloud_firestore')));
      expect(source, contains('AIProviderType.deepgram'));
    });
  });

  group('Governance — the transcription chain is the only route', () {
    test('the application service knows only the provider port', () {
      final source = File(
        'lib/application/transcript/'
        'realtime_transcript_application_service.dart',
      ).readAsStringSync();

      expect(source, contains('TranscriptProvider'));
      for (final forbidden in const [
        'AIGateway',
        'Deepgram',
        'deepgram',
        'HttpClient',
        'cloud_firestore',
        'livekit',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the transcript service must not know $forbidden',
        );
      }
    });

    test('the transcript provider uses the gateway ONLY', () {
      final source = File(
        'lib/infrastructure/transcript/ai_transcript_provider.dart',
      ).readAsStringSync();

      expect(source, contains('AIGateway'));
      expect(source, contains('AITask.transcription'));
      for (final forbidden in const [
        'Deepgram',
        'deepgram',
        'HttpClient',
        'cloud_firestore',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the transcript provider must not know $forbidden',
        );
      }
    });

    test('Deepgram is invisible outside its single Infrastructure adapter', () {
      const allowed = [
        'lib/infrastructure/ai_gateway/deepgram_adapter.dart',
        'lib/composition/mentora_composition_root.dart',
        // The provider-type enum names engine KINDS only.
        'lib/domain/ai_gateway/ai_provider.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        if (entity.readAsStringSync().toLowerCase().contains('deepgram') &&
            !allowed.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the transcript stays a living stream — no persistence anywhere', () {
      for (final path in const [
        'lib/domain/transcript/transcript_chunk.dart',
        'lib/domain/transcript/transcript_provider.dart',
        'lib/domain/transcript/consultation_audio_stream.dart',
        'lib/application/transcript/'
            'realtime_transcript_application_service.dart',
        'lib/infrastructure/transcript/ai_transcript_provider.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains('cloud_firestore')), reason: path);
        expect(source, isNot(contains('Firestore')), reason: path);
      }
    });

    test('a chunk carries exactly the five authorized facts', () {
      final source = File(
        'lib/domain/transcript/transcript_chunk.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String sessionId;',
        'final String participantIdentity;',
        'final String text;',
        'final bool isFinal;',
        'final DateTime createdAt;',
      ]);
    });
  });
}

ConsultationAudioFrame _frame({String participant = 'b1_client_userA'}) {
  return ConsultationAudioFrame(
    sessionId: 's1',
    participantIdentity: participant,
    payload: const [1, 2, 3],
  );
}

RealtimeTranscriptApplicationService _service(TranscriptProvider provider) {
  return RealtimeTranscriptApplicationService(
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
  final List<(String, ConsultationAudioStream)> started = [];

  @override
  Future<TranscriptStream> start({
    required String sessionId,
    required ConsultationAudioStream audio,
  }) async {
    started.add((sessionId, audio));
    return _FakeStream(sessionId);
  }
}

final class _FakeStream implements TranscriptStream {
  _FakeStream(this.sessionId);

  @override
  final String sessionId;

  @override
  TranscriptStatus get status => TranscriptStatus.transcribing;

  @override
  Stream<TranscriptChunk> get chunks => const Stream.empty();

  @override
  Future<TranscriptResult> stop() async {
    return TranscriptResult(
      sessionId: sessionId,
      status: TranscriptStatus.stopped,
    );
  }
}

final class _RecordingGateway implements AIGateway {
  _RecordingGateway({this.answers = const [], this.error});

  final List<String> answers;
  final Object? error;
  final List<AIRequest> executed = [];

  @override
  Future<AIResponse> execute(AIRequest request) async {
    if (error case final cause?) throw cause;
    executed.add(request);
    final answer = answers.length >= executed.length
        ? answers[executed.length - 1]
        : '';
    return AIResponse(
      providerType: AIProviderType.deepgram,
      responseId: 'r_${executed.length}',
      status: AIResponseStatus.accepted,
      text: answer,
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
