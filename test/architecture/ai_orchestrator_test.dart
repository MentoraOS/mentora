import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/ai_gateway/ai_orchestrator.dart';
import 'package:mentora/application/ai_gateway/ai_provider_registry.dart';
import 'package:mentora/application/ai_gateway/routing_context.dart';
import 'package:mentora/application/ai_gateway/routing_decision.dart';
import 'package:mentora/application/ai_gateway/routing_strategy.dart';
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

  group('RoutingContext and RoutingDecision — immutable contracts', () {
    test('the context is immutable with only optional prepared fields', () {
      const context = RoutingContext(task: AITask.summary, requestId: 'r1');

      expect(context.task, AITask.summary);
      // Every prepared field is optional and carries no logic today.
      expect(context.sourceLanguage, isNull);
      expect(context.targetLanguage, isNull);
      expect(context.region, isNull);
      expect(context.country, isNull);
      expect(context.priority, isNull);
      expect(context.qualityLevel, isNull);
      expect(context.privacyLevel, isNull);
      expect(context.budget, isNull);
      expect(context.maxDuration, isNull);
      expect(context.subscriptionTier, isNull);

      final source = File(
        'lib/application/ai_gateway/routing_context.dart',
      ).readAsStringSync();
      // Immutable: every field is final; const-constructible.
      expect(RegExp(r'\n  \w').allMatches(source), isNotEmpty);
      expect(source, isNot(contains('set ')));
      expect(
        RegExp(r'final \w+\??' r' \w+;').allMatches(source).length,
        12,
      );
    });

    test('the decision is immutable with exactly provider, strategy, '
        'reason and timestamp', () {
      final source = File(
        'lib/application/ai_gateway/routing_decision.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final AIProvider? provider;',
        'final String strategy;',
        'final String reason;',
        'final DateTime timestamp;',
      ]);
      // No metric, no score, no cost.
      expect(source.toLowerCase(), isNot(contains('score')));
      expect(source.toLowerCase(), isNot(contains('metric')));
      expect(source.toLowerCase(), isNot(contains('cost;')));
    });
  });

  group('DefaultRoutingStrategy — today, explained and traced', () {
    test('finds the provider registered for the task, with a reason', () {
      final engine = _Provider('summary_engine');
      final registry = AIProviderRegistry.from({AITask.summary: engine});

      final decision = const DefaultRoutingStrategy().decide(
        context: const RoutingContext(task: AITask.summary),
        registry: registry,
      );

      expect(decision.provider, same(engine));
      expect(decision.strategy, 'DefaultRoutingStrategy');
      expect(decision.reason, contains('summary'));
      expect(decision.timestamp, isNotNull);
    });

    test('has no opinion — explained — without a task or a registration', () {
      const strategy = DefaultRoutingStrategy();
      final registry = AIProviderRegistry();

      final noTask = strategy.decide(
        context: const RoutingContext(),
        registry: registry,
      );
      final noProvider = strategy.decide(
        context: const RoutingContext(task: AITask.assistant),
        registry: registry,
      );

      expect(noTask.provider, isNull);
      expect(noTask.reason, contains('No task'));
      expect(noProvider.provider, isNull);
      expect(noProvider.reason, contains('assistant'));
    });
  });

  group('AIOrchestrator — decide through the strategy, delegate '
      'verbatim', () {
    test('routes through a RoutingDecision and returns the response '
        'VERBATIM', () async {
      final summaryEngine = _Provider('summary_engine');
      final fallback = _Provider('fallback');
      final orchestrator = AIOrchestrator(
        defaultProvider: fallback,
        registry: AIProviderRegistry.from({AITask.summary: summaryEngine}),
      );

      final routed = await orchestrator.execute(
        AIRequest(requestId: 'r1', task: AITask.summary, text: 'x'),
      );
      final defaulted = await orchestrator.execute(
        AIRequest(requestId: 'r2', text: 'x'),
      );

      expect(summaryEngine.executed.single.requestId, 'r1');
      expect(fallback.executed.single.requestId, 'r2');
      expect(routed, same(summaryEngine.lastResponse));
      expect(defaulted, same(fallback.lastResponse));
    });

    test('a custom strategy slots in as a simple module', () async {
      final preferred = _Provider('preferred');
      final orchestrator = AIOrchestrator(
        defaultProvider: _Provider('fallback'),
        registry: AIProviderRegistry(),
        strategy: _AlwaysStrategy(preferred),
      );

      await orchestrator.execute(AIRequest(requestId: 'r1', text: 'x'));

      expect(preferred.executed, hasLength(1));
    });

    test('health reflects the default engine', () async {
      final orchestrator = AIOrchestrator(
        defaultProvider: _Provider('fallback', healthy: false),
        registry: AIProviderRegistry(),
      );

      expect(await orchestrator.health(), isFalse);
    });
  });

  group('Governance — routing internals are orchestrator-only', () {
    test('RoutingStrategy, RoutingDecision and RoutingContext are '
        'invisible outside the orchestrator', () {
      const allowedSurface = [
        'lib/application/ai_gateway/routing_context.dart',
        'lib/application/ai_gateway/routing_decision.dart',
        'lib/application/ai_gateway/routing_strategy.dart',
        'lib/application/ai_gateway/ai_orchestrator.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('RoutingStrategy') ||
                source.contains('RoutingDecision') ||
                source.contains('RoutingContext')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('AIOrchestrator and the registry stay gateway-only, and the '
        'chain stays pure', () {
      const allowedSurface = [
        'lib/application/ai_gateway/ai_orchestrator.dart',
        'lib/application/ai_gateway/ai_provider_registry.dart',
        'lib/application/ai_gateway/routing_strategy.dart',
        'lib/application/ai_gateway/ai_gateway_application_service.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('AIOrchestrator') ||
                source.contains('AIProviderRegistry')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);

      for (final path in const [
        'lib/application/ai_gateway/ai_orchestrator.dart',
        'lib/application/ai_gateway/ai_provider_registry.dart',
        'lib/application/ai_gateway/routing_context.dart',
        'lib/application/ai_gateway/routing_decision.dart',
        'lib/application/ai_gateway/routing_strategy.dart',
      ]) {
        final source = File(path).readAsStringSync().toLowerCase();
        for (final forbidden in const [
          'openai',
          'gemini',
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

final class _AlwaysStrategy implements RoutingStrategy {
  _AlwaysStrategy(this.provider);

  final AIProvider provider;

  @override
  RoutingDecision decide({
    required RoutingContext context,
    required AIProviderRegistry registry,
  }) {
    return RoutingDecision(
      provider: provider,
      strategy: '_AlwaysStrategy',
      reason: 'test strategy',
      timestamp: DateTime.utc(2026, 8, 1),
    );
  }
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
