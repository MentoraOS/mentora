import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/ai_gateway/ai_cost_observer.dart';
import 'package:mentora/application/ai_gateway/ai_cost_record.dart';
import 'package:mentora/application/ai_gateway/ai_orchestrator.dart';
import 'package:mentora/application/ai_gateway/ai_provider_registry.dart';
import 'package:mentora/application/ai_gateway/ai_usage_record.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';

void main() {
  group('AICostRecord — immutable contract, nothing invented', () {
    test('every field is optional and every numeric field can be null', () {
      const empty = AICostRecord();

      expect(empty.requestId, isNull);
      expect(empty.provider, isNull);
      expect(empty.model, isNull);
      expect(empty.estimatedInputTokens, isNull);
      expect(empty.estimatedOutputTokens, isNull);
      expect(empty.estimatedTotalTokens, isNull);
      expect(empty.estimatedCost, isNull);
      expect(empty.currency, isNull);
      expect(empty.createdAt, isNull);
    });

    test('carries exactly the nine contract fields, all immutable, and '
        'performs no computation', () {
      final source = File(
        'lib/application/ai_gateway/ai_cost_record.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String? requestId;',
        'final String? provider;',
        'final String? model;',
        'final int? estimatedInputTokens;',
        'final int? estimatedOutputTokens;',
        'final int? estimatedTotalTokens;',
        'final num? estimatedCost;',
        'final String? currency;',
        'final DateTime? createdAt;',
      ]);
      // Contract only: no computation of any kind.
      expect(source, isNot(contains('=>')));
      expect(source, isNot(contains('* ')));
      expect(source, isNot(contains('+ ')));
    });
  });

  group('AIUsageRecord — immutable, exactly six facts', () {
    test('carries exactly requestId, task, provider, model, success and '
        'createdAt', () {
      final source = File(
        'lib/application/ai_gateway/ai_usage_record.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String requestId;',
        'final AITask? task;',
        'final String? provider;',
        'final String? model;',
        'final bool success;',
        'final DateTime createdAt;',
      ]);
    });
  });

  group('AICostObserver — observes, never computes, never decides', () {
    test('returns records unchanged and keeps them in bounded memory '
        'only', () {
      final observer = AICostObserver(capacity: 2);
      const cost = AICostRecord(requestId: 'r1');
      final usage = AIUsageRecord(
        requestId: 'r1',
        task: AITask.summary,
        provider: 'simulated',
        model: null,
        success: true,
        createdAt: DateTime.utc(2026, 8, 1),
      );

      expect(observer.observeCost(cost), same(cost));
      expect(observer.observeUsage(usage), same(usage));
      expect(observer.costs.single, same(cost));
      expect(observer.usages.single, same(usage));

      observer.observeCost(const AICostRecord(requestId: 'r2'));
      observer.observeCost(const AICostRecord(requestId: 'r3'));
      expect(observer.costs, hasLength(2));
      expect(observer.costs.first.requestId, 'r2');
      expect(() => observer.costs.add(cost), throwsUnsupportedError);
    });

    test('the observer performs no billing, no limitation, no decision', () {
      final source = File(
        'lib/application/ai_gateway/ai_cost_observer.dart',
      ).readAsStringSync();

      // Observation only: no arithmetic, no throw-based limiting, no
      // network, no persistence in code.
      expect(source, isNot(contains('* ')));
      expect(source, isNot(contains('+ ')));
      expect(source, isNot(contains('throw ')));
      expect(source, isNot(contains('Firestore')));
      expect(source, isNot(contains('HttpClient')));
    });
  });

  group('AIOrchestrator — every execution emits usage and cost', () {
    test('a successful execution emits both records with only the '
        'available facts — nothing invented', () async {
      final observer = AICostObserver();
      final engine = _Provider('engine');
      final orchestrator = AIOrchestrator(
        defaultProvider: engine,
        registry: AIProviderRegistry.from({AITask.summary: engine}),
        costObserver: observer,
      );

      await orchestrator.execute(
        AIRequest(requestId: 'r1', task: AITask.summary, text: 'x'),
      );

      final usage = observer.usages.single;
      expect(usage.requestId, 'r1');
      expect(usage.task, AITask.summary);
      expect(usage.provider, 'simulated');
      expect(usage.success, isTrue);
      // Unknown facts stay null — never invented.
      expect(usage.model, isNull);

      final cost = observer.costs.single;
      expect(cost.requestId, 'r1');
      expect(cost.provider, 'simulated');
      expect(cost.model, isNull);
      expect(cost.estimatedInputTokens, isNull);
      expect(cost.estimatedOutputTokens, isNull);
      expect(cost.estimatedTotalTokens, isNull);
      expect(cost.estimatedCost, isNull);
      expect(cost.currency, isNull);
    });

    test('a failed execution emits both records too, and the error stays '
        'untouched', () async {
      final observer = AICostObserver();
      final boom = StateError('engine down');
      final orchestrator = AIOrchestrator(
        defaultProvider: _Provider('engine', error: boom),
        registry: AIProviderRegistry(),
        costObserver: observer,
      );

      Object? caught;
      try {
        await orchestrator.execute(AIRequest(requestId: 'r1', text: 'x'));
      } catch (error) {
        caught = error;
      }

      expect(caught, same(boom));
      expect(observer.usages.single.success, isFalse);
      expect(observer.costs.single.requestId, 'r1');
    });
  });

  group('Governance — cost & usage is orchestrator-only and pure', () {
    test('AICostObserver and the records are invisible outside the '
        'orchestrator', () {
      const allowedSurface = [
        'lib/application/ai_gateway/ai_cost_observer.dart',
        'lib/application/ai_gateway/ai_cost_record.dart',
        'lib/application/ai_gateway/ai_usage_record.dart',
        'lib/application/ai_gateway/ai_orchestrator.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('AICostObserver') ||
                source.contains('AICostRecord') ||
                source.contains('AIUsageRecord')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the cost layer persists nothing and knows no vendor, no '
        'business module', () {
      for (final path in const [
        'lib/application/ai_gateway/ai_cost_observer.dart',
        'lib/application/ai_gateway/ai_cost_record.dart',
        'lib/application/ai_gateway/ai_usage_record.dart',
      ]) {
        final source = File(path).readAsStringSync().toLowerCase();
        for (final forbidden in const [
          'firestore',
          'firebase_storage',
          'httpclient',
          'openai',
          'gemini',
          'deepgram',
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
  _Provider(this.name, {this.error});

  final String name;
  final Object? error;

  @override
  AIProviderType get providerType => AIProviderType.simulated;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    if (error case final cause?) throw cause;
    return AIResponse(
      providerType: AIProviderType.simulated,
      responseId: '${name}_${request.requestId}',
      status: AIResponseStatus.accepted,
    );
  }

  @override
  Future<bool> health() async => true;
}
