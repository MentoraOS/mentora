import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/ai_gateway/ai_gateway_application_service.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/domain/ai_gateway/ai_gateway.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';
import 'package:mentora/infrastructure/ai_gateway/simulated_ai_provider.dart';

void main() {
  group('AIGatewayApplicationService', () {
    test('a request travels through the gateway to the provider', () async {
      final provider = _RecordingProvider();
      final AIGateway gateway = _gateway(provider);

      final response = await gateway.execute(
        AIRequest(requestId: 'r1', text: 'transport only'),
      );

      expect(provider.executed.single.requestId, 'r1');
      expect(response.providerType, AIProviderType.simulated);
      expect(response.status, AIResponseStatus.accepted);
    });

    test('an unauthenticated caller fails typed before the provider', () async {
      final provider = _RecordingProvider();
      final gateway = AIGatewayApplicationService(
        session: _Session(null),
        provider: provider,
      );

      await expectLater(
        gateway.execute(AIRequest(requestId: 'r1', text: 'x')),
        throwsA(isA<AIUnauthenticatedFailure>()),
      );
      expect(provider.executed, isEmpty);
    });

    test('an empty envelope is refused before any provider', () async {
      final provider = _RecordingProvider();
      final gateway = _gateway(provider);

      await expectLater(
        gateway.execute(AIRequest(requestId: 'r1')),
        throwsA(isA<AIInvalidRequestFailure>()),
      );
      expect(provider.executed, isEmpty);
    });

    test('provider errors surface as typed AI failures', () {
      final gateway = _gateway(_RecordingProvider(error: StateError('down')));

      expect(
        () => gateway.execute(AIRequest(requestId: 'r1', text: 'x')),
        throwsA(isA<AIUnavailableFailure>()),
      );
    });

    test('health fails closed when the provider is unreachable', () async {
      expect(await _gateway(_RecordingProvider()).health(), isTrue);
      expect(
        await _gateway(
          _RecordingProvider(healthError: StateError('down')),
        ).health(),
        isFalse,
      );
    });
  });

  group('SimulatedAIProvider', () {
    test('acknowledges deterministically with zero generated content', () async {
      const provider = SimulatedAIProvider();

      final response = await provider.execute(
        AIRequest(requestId: 'r42', conversation: const ['opaque']),
      );

      expect(provider.providerType, AIProviderType.simulated);
      expect(response.responseId, 'simulated_r42');
      expect(response.status, AIResponseStatus.accepted);
      expect(await provider.health(), isTrue);
    });
  });

  group('AIRequest — opaque transport envelope', () {
    test('carries text, conversation, audio, documents and context', () {
      final request = AIRequest(
        requestId: 'r1',
        text: 'plain',
        conversation: const ['m1', 'm2'],
        audio: 'opaque_audio_handle',
        documents: const ['doc1'],
        context: const {'bookingId': 'b1'},
      );

      expect(request.isEmpty, isFalse);
      expect(request.conversation, hasLength(2));
      // Payloads are sealed against mutation.
      expect(() => request.conversation.add('x'), throwsUnsupportedError);
    });

    test('a blank identity fails closed at construction', () {
      expect(() => AIRequest(requestId: '  '), throwsArgumentError);
    });

    test('the response envelope carries no generated content', () {
      final source = File(
        'lib/domain/ai_gateway/ai_provider.dart',
      ).readAsStringSync();

      final responseBlock = source.substring(
        source.indexOf('final class AIResponse'),
        source.indexOf('enum AIResponseStatus'),
      );
      expect(responseBlock, contains('providerType'));
      expect(responseBlock, contains('responseId'));
      expect(responseBlock, contains('status'));
      expect(responseBlock, isNot(contains('text')));
      expect(responseBlock, isNot(contains('content')));
    });
  });

  group('ARC-AI01 — every AI call passes through the gateway', () {
    test('the AI surface is confined and no engine is reachable directly', () {
      const allowedSurface = [
        'lib/domain/ai_gateway/ai_gateway.dart',
        'lib/domain/ai_gateway/ai_provider.dart',
        'lib/application/ai_gateway/ai_gateway_application_service.dart',
        'lib/infrastructure/ai_gateway/simulated_ai_provider.dart',
        'lib/composition/mentora_composition_root.dart',
        'lib/composition/mentora_dependencies.dart',
      ];
      // No AI vendor SDK may be imported anywhere in lib — a real engine
      // adapter joins lib/infrastructure/ai_gateway/ in its own wave and
      // relaxes this list for that directory only.
      const forbiddenImports = [
        "import 'package:openai",
        "import 'package:dart_openai",
        "import 'package:google_generative_ai",
        "import 'package:anthropic",
        "import 'package:deepgram",
        "import 'package:azure",
      ];

      final surfaceOffenders = <String>[];
      final vendorOffenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();

        if ((source.contains('AIProvider') || source.contains('AIGateway')) &&
            !allowedSurface.contains(normalized)) {
          surfaceOffenders.add(normalized);
        }
        for (final forbidden in forbiddenImports) {
          if (source.contains(forbidden)) {
            vendorOffenders.add('$normalized -> $forbidden');
          }
        }
      }

      expect(surfaceOffenders, isEmpty);
      expect(vendorOffenders, isEmpty);
    });

    test('the gateway layer itself names no vendor', () {
      for (final path in const [
        'lib/domain/ai_gateway/ai_gateway.dart',
        'lib/domain/ai_gateway/ai_provider.dart',
        'lib/application/ai_gateway/ai_gateway_application_service.dart',
        'lib/infrastructure/ai_gateway/simulated_ai_provider.dart',
      ]) {
        final source = File(path).readAsStringSync().toLowerCase();
        for (final vendor in const [
          'openai',
          'gemini',
          'claude',
          'anthropic',
          'deepgram',
          'google speech',
          'azure',
        ]) {
          expect(source, isNot(contains(vendor)), reason: '$path: $vendor');
        }
      }
    });
  });
}

AIGatewayApplicationService _gateway(AIProvider provider) {
  return AIGatewayApplicationService(
    session: _Session('client_1'),
    provider: provider,
  );
}

final class _RecordingProvider implements AIProvider {
  _RecordingProvider({this.error, this.healthError});

  final Object? error;
  final Object? healthError;
  final List<AIRequest> executed = [];

  @override
  AIProviderType get providerType => AIProviderType.simulated;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    if (error case final cause?) throw cause;
    executed.add(request);
    return AIResponse(
      providerType: AIProviderType.simulated,
      responseId: 'simulated_${request.requestId}',
      status: AIResponseStatus.accepted,
    );
  }

  @override
  Future<bool> health() async {
    if (healthError case final cause?) throw cause;
    return true;
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
