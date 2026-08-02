import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/ai_gateway/ai_execution_metrics.dart';
import 'package:mentora/application/ai_gateway/ai_execution_trace.dart';
import 'package:mentora/application/ai_gateway/ai_observability.dart';
import 'package:mentora/application/ai_gateway/ai_orchestrator.dart';
import 'package:mentora/application/ai_gateway/ai_provider_registry.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';

void main() {
  group('AIExecutionTrace — immutable, technical facts only', () {
    test('completion produces a NEW trace; the original never mutates', () {
      final started = AIExecutionTrace(
        requestId: 'r1',
        provider: 'openAI',
        task: AITask.summary,
        strategy: 'DefaultRoutingStrategy',
        startedAt: DateTime.utc(2026, 8, 1, 9),
        finishedAt: null,
        status: AIExecutionStatus.started,
      );

      final finished = started.finished(
        status: AIExecutionStatus.succeeded,
        finishedAt: DateTime.utc(2026, 8, 1, 9, 0, 2),
      );

      expect(started.status, AIExecutionStatus.started);
      expect(started.finishedAt, isNull);
      expect(finished.status, AIExecutionStatus.succeeded);
      expect(finished.finishedAt, isNotNull);
      expect(finished.requestId, started.requestId);
    });

    test('carries exactly the seven facts — no AI content, no prompt, no '
        'response, no user data', () {
      final source = File(
        'lib/application/ai_gateway/ai_execution_trace.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String requestId;',
        'final String provider;',
        'final AITask? task;',
        'final String strategy;',
        'final DateTime startedAt;',
        'final DateTime? finishedAt;',
        'final AIExecutionStatus status;',
      ]);
      for (final forbidden in const [
        'prompt',
        'response',
        'userId',
        'clientId',
        'expertId',
      ]) {
        expect(
          source.toLowerCase(),
          isNot(contains(forbidden.toLowerCase())),
          reason: 'a trace must never carry $forbidden',
        );
      }
    });
  });

  group('AIExecutionMetrics — immutable structure only', () {
    test('carries exactly duration, success and failed', () {
      const metrics = AIExecutionMetrics(
        duration: Duration(milliseconds: 420),
        success: true,
        failed: false,
      );
      expect(metrics.duration.inMilliseconds, 420);

      final source = File(
        'lib/application/ai_gateway/ai_execution_metrics.dart',
      ).readAsStringSync();
      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final Duration duration;',
        'final bool success;',
        'final bool failed;',
      ]);
    });
  });

  group('AIObservability — observes, never modifies', () {
    test('returns the exact trace it received and keeps it in bounded '
        'memory only', () {
      final observability = AIObservability(capacity: 2);
      final trace = AIExecutionTrace(
        requestId: 'r1',
        provider: 'simulated',
        task: null,
        strategy: 's',
        startedAt: DateTime.utc(2026, 8, 1),
        finishedAt: null,
        status: AIExecutionStatus.started,
      );

      final returned = observability.observe(trace);

      expect(returned, same(trace));
      expect(observability.traces.single, same(trace));
      // Bounded for millions of daily executions.
      observability.observe(trace.finished(
        status: AIExecutionStatus.succeeded,
        finishedAt: DateTime.utc(2026, 8, 1, 0, 0, 1),
      ));
      observability.observe(trace);
      expect(observability.traces, hasLength(2));
      expect(
        () => observability.traces.add(trace),
        throwsUnsupportedError,
      );
    });
  });

  group('AIOrchestrator — every execution observable, results '
      'untouched', () {
    test('a trace is opened BEFORE the provider and completed after '
        'success — the response stays verbatim', () async {
      final observability = AIObservability();
      final engine = _Provider('engine', observability: observability);
      final orchestrator = AIOrchestrator(
        defaultProvider: engine,
        registry: AIProviderRegistry.from({AITask.summary: engine}),
        observability: observability,
      );

      final response = await orchestrator.execute(
        AIRequest(requestId: 'r1', task: AITask.summary, text: 'x'),
      );

      expect(response, same(engine.lastResponse));
      final traces = observability.traces;
      expect(traces, hasLength(2));
      expect(traces.first.status, AIExecutionStatus.started);
      expect(traces.first.finishedAt, isNull);
      expect(traces.last.status, AIExecutionStatus.succeeded);
      expect(traces.last.finishedAt, isNotNull);
      expect(traces.last.requestId, 'r1');
      expect(traces.last.provider, 'simulated');
      expect(traces.last.strategy, 'DefaultRoutingStrategy');
      // The trace was opened BEFORE the provider ran.
      expect(engine.tracesAtExecution, 1);
    });

    test('an error completes the trace as failed and the error itself is '
        'rethrown untouched', () async {
      final observability = AIObservability();
      final boom = StateError('engine down');
      final orchestrator = AIOrchestrator(
        defaultProvider: _Provider('engine', error: boom),
        registry: AIProviderRegistry(),
        observability: observability,
      );

      Object? caught;
      try {
        await orchestrator.execute(AIRequest(requestId: 'r1', text: 'x'));
      } catch (error) {
        caught = error;
      }

      expect(caught, same(boom));
      expect(observability.traces.last.status, AIExecutionStatus.failed);
      expect(observability.traces.last.finishedAt, isNotNull);
    });
  });

  group('Governance — observability is orchestrator-only and pure', () {
    test('AIObservability and the trace are invisible outside the '
        'orchestrator', () {
      const allowedSurface = [
        'lib/application/ai_gateway/ai_observability.dart',
        'lib/application/ai_gateway/ai_execution_trace.dart',
        'lib/application/ai_gateway/ai_execution_metrics.dart',
        'lib/application/ai_gateway/ai_orchestrator.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('AIObservability') ||
                source.contains('AIExecutionTrace') ||
                source.contains('AIExecutionMetrics')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the observability layer persists nothing and knows no vendor, '
        'no business module', () {
      for (final path in const [
        'lib/application/ai_gateway/ai_observability.dart',
        'lib/application/ai_gateway/ai_execution_trace.dart',
        'lib/application/ai_gateway/ai_execution_metrics.dart',
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
  _Provider(this.name, {this.error, this.observability});

  final String name;
  final Object? error;
  final AIObservability? observability;
  final List<AIRequest> executed = [];
  AIResponse? lastResponse;

  /// How many traces the observability held when execute ran — proves
  /// the trace is opened BEFORE the provider call.
  int tracesAtExecution = -1;

  @override
  AIProviderType get providerType => AIProviderType.simulated;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    if (error case final cause?) throw cause;
    executed.add(request);
    tracesAtExecution = observability?.traces.length ?? -1;
    return lastResponse = AIResponse(
      providerType: AIProviderType.simulated,
      responseId: '${name}_${request.requestId}',
      status: AIResponseStatus.accepted,
    );
  }

  @override
  Future<bool> health() async => true;
}
