import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/ai_gateway/ai_orchestrator.dart';
import 'package:mentora/application/ai_gateway/ai_provider_registry.dart';
import 'package:mentora/application/ai_gateway/ai_routing_policy.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';

void main() {
  group('AIProviderRegistry', () {
    test('registers and finds a provider per task', () {
      final registry = AIProviderRegistry();
      final engine = _Provider('summary_engine');

      registry.register(task: AITask.summary, provider: engine);

      expect(registry.providerFor(AITask.summary), same(engine));
      expect(registry.providerFor(AITask.translation), isNull);
    });

    test('refuses duplicates — one task, one engine', () {
      final registry = AIProviderRegistry();
      registry.register(task: AITask.summary, provider: _Provider('a'));

      expect(
        () => registry.register(
          task: AITask.summary,
          provider: _Provider('b'),
        ),
        throwsArgumentError,
      );
    });

    test('unregistering frees the task for a new engine', () {
      final registry = AIProviderRegistry();
      registry.register(task: AITask.summary, provider: _Provider('a'));

      registry.unregister(AITask.summary);
      expect(registry.providerFor(AITask.summary), isNull);

      final replacement = _Provider('b');
      registry.register(task: AITask.summary, provider: replacement);
      expect(registry.providerFor(AITask.summary), same(replacement));
    });
  });

  group('AIRoutingPolicy — today: the task, nothing else', () {
    test('selects the provider registered for the request task', () {
      final registry = AIProviderRegistry.from({
        AITask.summary: _Provider('summary_engine'),
        AITask.translation: _Provider('translation_engine'),
      });
      const policy = TaskRoutingPolicy();

      final selected = policy.select(
        request: AIRequest(requestId: 'r1', task: AITask.summary, text: 'x'),
        registry: registry,
      );

      expect((selected as _Provider).name, 'summary_engine');
    });

    test('has no opinion without a task or a registration', () {
      final registry = AIProviderRegistry();
      const policy = TaskRoutingPolicy();

      expect(
        policy.select(
          request: AIRequest(requestId: 'r1', text: 'x'),
          registry: registry,
        ),
        isNull,
      );
      expect(
        policy.select(
          request: AIRequest(
            requestId: 'r1',
            task: AITask.assistant,
            text: 'x',
          ),
          registry: registry,
        ),
        isNull,
      );
    });
  });

  group('AIOrchestrator — delegate, never transform', () {
    test('routes through the policy and returns the response VERBATIM', () async {
      final summaryEngine = _Provider('summary_engine');
      final fallback = _Provider('fallback');
      final orchestrator = AIOrchestrator(
        defaultProvider: fallback,
        registry: AIProviderRegistry.from({AITask.summary: summaryEngine}),
        policy: const TaskRoutingPolicy(),
      );

      final routed = await orchestrator.execute(
        AIRequest(requestId: 'r1', task: AITask.summary, text: 'x'),
      );
      final defaulted = await orchestrator.execute(
        AIRequest(requestId: 'r2', text: 'x'),
      );

      expect(summaryEngine.executed.single.requestId, 'r1');
      expect(fallback.executed.single.requestId, 'r2');
      // Verbatim delegation: the exact response object, untouched.
      expect(routed, same(summaryEngine.lastResponse));
      expect(defaulted, same(fallback.lastResponse));
    });

    test('health reflects the default engine', () async {
      final orchestrator = AIOrchestrator(
        defaultProvider: _Provider('fallback', healthy: false),
        registry: AIProviderRegistry(),
        policy: const TaskRoutingPolicy(),
      );

      expect(await orchestrator.health(), isFalse);
    });
  });

  group('Governance — only the gateway knows the orchestrator', () {
    test('AIOrchestrator, the registry and the policy are invisible to '
        'every business module', () {
      const allowedSurface = [
        'lib/application/ai_gateway/ai_orchestrator.dart',
        'lib/application/ai_gateway/ai_provider_registry.dart',
        'lib/application/ai_gateway/ai_routing_policy.dart',
        'lib/application/ai_gateway/ai_gateway_application_service.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('AIOrchestrator') ||
                source.contains('AIProviderRegistry') ||
                source.contains('AIRoutingPolicy')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the orchestration chain stays pure — no vendor, no network, no '
        'persistence, no business module', () {
      for (final path in const [
        'lib/application/ai_gateway/ai_orchestrator.dart',
        'lib/application/ai_gateway/ai_provider_registry.dart',
        'lib/application/ai_gateway/ai_routing_policy.dart',
      ]) {
        final source = File(path).readAsStringSync().toLowerCase();
        for (final forbidden in const [
          'openai',
          'gemini',
          'claude',
          'deepgram',
          'httpclient',
          'firestore',
          'consultation_memory',
          'booking',
        ]) {
          expect(
            source,
            isNot(contains(forbidden)),
            reason: '$path must not know $forbidden',
          );
        }
      }
    });
  });
}

final class _Provider implements AIProvider {
  _Provider(this.name, {this.healthy = true});

  final String name;
  final bool healthy;
  final List<AIRequest> executed = [];
  AIResponse? lastResponse;

  @override
  AIProviderType get providerType => AIProviderType.simulated;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    executed.add(request);
    return lastResponse = AIResponse(
      providerType: AIProviderType.simulated,
      responseId: '${name}_${request.requestId}',
      status: AIResponseStatus.accepted,
    );
  }

  @override
  Future<bool> health() async => healthy;
}
