import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/translation/realtime_translation_application_service.dart';
import 'package:mentora/domain/ai_gateway/ai_gateway.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';
import 'package:mentora/domain/transcript/transcript_chunk.dart';
import 'package:mentora/domain/translation/translated_transcript_chunk.dart';
import 'package:mentora/domain/translation/translation_provider.dart';
import 'package:mentora/infrastructure/ai_gateway/gemini_adapter.dart';
import 'package:mentora/infrastructure/translation/ai_translation_provider.dart';

void main() {
  group('RealtimeTranslationApplicationService', () {
    test('start attaches one living projection through the provider port', () async {
      final provider = _RecordingProvider();
      final service = _service(provider);

      final stream = await service.start(
        transcript: const Stream.empty(),
        sourceLanguage: ' fr ',
        targetLanguage: ' en ',
      );

      expect(provider.started.single, ('fr', 'en'));
      expect(stream.status, TranslationStatus.translating);
      expect(service.chunks(), isNotNull);
    });

    test('languages are injected values — empty ones fail closed', () async {
      final provider = _RecordingProvider();
      final service = _service(provider);

      for (final (source, target) in const [('', 'en'), ('fr', '  ')]) {
        await expectLater(
          service.start(
            transcript: const Stream.empty(),
            sourceLanguage: source,
            targetLanguage: target,
          ),
          throwsA(isA<TranslationInvalidLanguagesFailure>()),
        );
      }
      expect(provider.started, isEmpty);
    });

    test('one live translation at a time — fail closed', () async {
      final service = _service(_RecordingProvider());
      await service.start(
        transcript: const Stream.empty(),
        sourceLanguage: 'fr',
        targetLanguage: 'en',
      );

      await expectLater(
        service.start(
          transcript: const Stream.empty(),
          sourceLanguage: 'bm',
          targetLanguage: 'th',
        ),
        throwsA(isA<TranslationAlreadyActiveFailure>()),
      );
    });

    test('stop seals the projection and allows a fresh pair', () async {
      final service = _service(_RecordingProvider());
      await service.start(
        transcript: const Stream.empty(),
        sourceLanguage: 'fr',
        targetLanguage: 'en',
      );

      final result = await service.stop();

      expect(result.status, TranslationStatus.stopped);
      // A new pair can start — mid-consultation language change.
      await service.start(
        transcript: const Stream.empty(),
        sourceLanguage: 'bm',
        targetLanguage: 'th',
      );
    });

    test('an unauthenticated session fails typed before the provider', () async {
      final provider = _RecordingProvider();
      final service = RealtimeTranslationApplicationService(
        session: _Session(null),
        provider: provider,
      );

      await expectLater(
        service.start(
          transcript: const Stream.empty(),
          sourceLanguage: 'fr',
          targetLanguage: 'en',
        ),
        throwsA(isA<TranslationUnauthenticatedFailure>()),
      );
      expect(provider.started, isEmpty);
    });
  });

  group('AITranslationProvider — the governed projection', () {
    test('every transcript chunk routes through the gateway with '
        'AITask.translation and becomes at most one projection', () async {
      final gateway = _RecordingGateway(answers: ['Hello doctor.']);
      final transcript = StreamController<TranscriptChunk>.broadcast(
        sync: true,
      );
      final provider = AITranslationProvider(gateway: gateway);
      final projection = await provider.start(
        transcript: transcript.stream,
        sourceLanguage: 'fr',
        targetLanguage: 'en',
      );
      final chunks = <TranslatedTranscriptChunk>[];
      final subscription = projection.chunks.listen(chunks.add);

      final original = _chunk('Bonjour docteur.');
      transcript.add(original);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      final request = gateway.executed.single;
      expect(request.task, AITask.translation);
      expect(request.text, contains('Bonjour docteur.'));
      expect(request.context['sourceLanguage'], 'fr');
      expect(request.context['targetLanguage'], 'en');

      final translated = chunks.single;
      // The transcript is the truth, carried verbatim — never modified.
      expect(original.text, 'Bonjour docteur.');
      expect(translated.originalText, 'Bonjour docteur.');
      expect(translated.translatedText, 'Hello doctor.');
      expect(translated.sourceLanguage, 'fr');
      expect(translated.targetLanguage, 'en');
      expect(translated.sessionId, 's1');
      expect(translated.participantIdentity, 'b1_client_userA');
      expect(translated.isFinal, isTrue);
    });

    test('an engine failure marks the projection failed — never a fake '
        'translation', () async {
      final gateway = _RecordingGateway(error: StateError('engine down'));
      final transcript = StreamController<TranscriptChunk>.broadcast(
        sync: true,
      );
      final projection = await AITranslationProvider(gateway: gateway).start(
        transcript: transcript.stream,
        sourceLanguage: 'fr',
        targetLanguage: 'en',
      );
      final errors = <Object>[];
      final subscription = projection.chunks.listen(
        (_) {},
        onError: errors.add,
      );

      transcript.add(_chunk('Bonjour.'));
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(errors, hasLength(1));
      expect(projection.status, TranslationStatus.failed);
    });

    test('stopping detaches from the transcript and seals the result', () async {
      final gateway = _RecordingGateway(answers: ['One.']);
      final transcript = StreamController<TranscriptChunk>.broadcast(
        sync: true,
      );
      final projection = await AITranslationProvider(gateway: gateway).start(
        transcript: transcript.stream,
        sourceLanguage: 'fr',
        targetLanguage: 'en',
      );

      final result = await projection.stop();
      transcript.add(_chunk('Trop tard.'));
      await Future<void>.delayed(Duration.zero);

      expect(result.status, TranslationStatus.stopped);
      expect(gateway.executed, isEmpty);
    });
  });

  group('GeminiAdapter — configuration and fail closed', () {
    test('an unconfigured engine fails closed before any network call', () async {
      const adapter = GeminiAdapter(
        configuration: GeminiConfiguration(apiKey: ''),
      );

      await expectLater(
        adapter.execute(AIRequest(requestId: 'r1', text: 'prompt')),
        throwsA(isA<AIUnavailableFailure>()),
      );
      expect(await adapter.health(), isFalse);
    });

    test('no key, secret, URL or business module is hard-coded outside '
        'the injectable configuration', () {
      final source = File(
        'lib/infrastructure/ai_gateway/gemini_adapter.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('String.fromEnvironment')));
      expect(source, contains('required this.apiKey'));
      expect(source, isNot(contains('consultation_memory')));
      expect(source, isNot(contains('cloud_firestore')));
      expect(source, contains('AIProviderType.gemini'));
    });
  });

  group('Governance — the translation chain is the only route', () {
    test('the application service knows only the provider port', () {
      final source = File(
        'lib/application/translation/'
        'realtime_translation_application_service.dart',
      ).readAsStringSync();

      expect(source, contains('TranslationProvider'));
      for (final forbidden in const [
        'AIGateway',
        'Gemini',
        'gemini',
        'HttpClient',
        'cloud_firestore',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the translation service must not know $forbidden',
        );
      }
    });

    test('the translation provider uses the gateway ONLY', () {
      final source = File(
        'lib/infrastructure/translation/ai_translation_provider.dart',
      ).readAsStringSync();

      expect(source, contains('AIGateway'));
      expect(source, contains('AITask.translation'));
      for (final forbidden in const [
        'Gemini',
        'gemini',
        'HttpClient',
        'cloud_firestore',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the translation provider must not know $forbidden',
        );
      }
    });

    test('Gemini is invisible outside its single Infrastructure adapter', () {
      const allowed = [
        'lib/infrastructure/ai_gateway/gemini_adapter.dart',
        'lib/composition/mentora_composition_root.dart',
        // The provider-type enum names engine KINDS only.
        'lib/domain/ai_gateway/ai_provider.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        if (entity.readAsStringSync().toLowerCase().contains('gemini') &&
            !allowed.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the translation stays a living stream — no persistence, no '
        'hard-coded language list', () {
      for (final path in const [
        'lib/domain/translation/translated_transcript_chunk.dart',
        'lib/domain/translation/translation_provider.dart',
        'lib/application/translation/'
            'realtime_translation_application_service.dart',
        'lib/infrastructure/translation/ai_translation_provider.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains('Firestore')), reason: path);
        expect(source, isNot(contains('cloud_firestore')), reason: path);
        // No language list is ever hard-coded.
        expect(source, isNot(contains("['fr'")), reason: path);
        expect(source, isNot(contains("'fr',")), reason: path);
      }
    });

    test('a projection carries exactly the eight authorized facts', () {
      final source = File(
        'lib/domain/translation/translated_transcript_chunk.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String sessionId;',
        'final String participantIdentity;',
        'final String originalText;',
        'final String translatedText;',
        'final String sourceLanguage;',
        'final String targetLanguage;',
        'final bool isFinal;',
        'final DateTime createdAt;',
      ]);
    });
  });
}

TranscriptChunk _chunk(String text) {
  return TranscriptChunk(
    sessionId: 's1',
    participantIdentity: 'b1_client_userA',
    text: text,
    isFinal: true,
    createdAt: DateTime.utc(2026, 8, 1, 9),
  );
}

RealtimeTranslationApplicationService _service(TranslationProvider provider) {
  return RealtimeTranslationApplicationService(
    session: _Session('client_1'),
    provider: provider,
  );
}

final class _RecordingProvider implements TranslationProvider {
  final List<(String, String)> started = [];

  @override
  Future<TranslationStream> start({
    required Stream<TranscriptChunk> transcript,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    started.add((sourceLanguage, targetLanguage));
    return _FakeStream();
  }
}

final class _FakeStream implements TranslationStream {
  @override
  TranslationStatus get status => TranslationStatus.translating;

  @override
  Stream<TranslatedTranscriptChunk> get chunks => const Stream.empty();

  @override
  Future<TranslationResult> stop() async {
    return const TranslationResult(status: TranslationStatus.stopped);
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
      providerType: AIProviderType.gemini,
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
