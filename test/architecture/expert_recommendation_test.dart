import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/expert_recommendation/recommendation_application_service.dart';
import 'package:mentora/domain/ai_gateway/ai_gateway.dart';
import 'package:mentora/domain/ai_gateway/ai_provider.dart';
import 'package:mentora/domain/expert_recommendation/expert_recommendation.dart';
import 'package:mentora/domain/expert_recommendation/recommendation_provider.dart';
import 'package:mentora/infrastructure/ai_gateway/openai_ai_provider.dart';
import 'package:mentora/infrastructure/ai_gateway/openai_recommendation_adapter.dart';
import 'package:mentora/infrastructure/expert_recommendation/ai_recommendation_provider.dart';

void main() {
  group('ExpertRecommendation — immutable proposal', () {
    test('carries exactly the six facts and the three qualitative '
        'confidence levels — no numeric score anywhere', () {
      final source = File(
        'lib/domain/expert_recommendation/expert_recommendation.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String recommendationId;',
        'final String expertId;',
        'final String title;',
        'final String explanation;',
        'final RecommendationConfidence confidence;',
        'final DateTime createdAt;',
      ]);
      expect(
        RecommendationConfidence.values.map((value) => value.name).toList(),
        ['low', 'medium', 'high'],
      );
      // Qualitative only: no numeric score, no percentage.
      expect(source, isNot(contains('double')));
      expect(source, isNot(contains('int ')));
      expect(source, isNot(contains('percent')));
    });

    test('an empty expert, title or explanation fails closed', () {
      ExpertRecommendation build({
        String expertId = 'expert_1',
        String title = 'Titre',
        String explanation = 'Explication',
      }) {
        return ExpertRecommendation(
          recommendationId: 'r1',
          expertId: expertId,
          title: title,
          explanation: explanation,
          confidence: RecommendationConfidence.medium,
          createdAt: DateTime.utc(2026, 8, 1),
        );
      }

      expect(() => build(expertId: ' '), throwsArgumentError);
      expect(() => build(title: ' '), throwsArgumentError);
      expect(() => build(explanation: ' '), throwsArgumentError);
    });
  });

  group('RecommendationApplicationService — the port and nothing else', () {
    test('a session user gets proposals for a trimmed need', () async {
      final provider = _RecordingProvider();
      final service = _service(provider);

      final recommendations = await service.recommend(
        need: '  Structurer ma stratégie de croissance  ',
      );

      expect(provider.needs, ['Structurer ma stratégie de croissance']);
      expect(recommendations, hasLength(1));
    });

    test('an unauthenticated session fails typed before the provider', () async {
      final provider = _RecordingProvider();
      final service = RecommendationApplicationService(
        session: _Session(null),
        provider: provider,
      );

      await expectLater(
        service.recommend(need: 'besoin'),
        throwsA(isA<RecommendationUnauthenticatedFailure>()),
      );
      expect(provider.needs, isEmpty);
    });

    test('an empty need fails closed before the provider', () async {
      final provider = _RecordingProvider();
      final service = _service(provider);

      await expectLater(
        service.recommend(need: '   '),
        throwsA(isA<RecommendationInvalidRequestFailure>()),
      );
      expect(provider.needs, isEmpty);
    });

    test('provider errors surface typed', () {
      final service = _service(_RecordingProvider(error: StateError('down')));

      expect(
        () => service.recommend(need: 'besoin'),
        throwsA(isA<RecommendationUnavailableFailure>()),
      );
    });
  });

  group('AIRecommendationProvider — the governed proposals', () {
    test('routes AITask.RECOMMENDATION through the gateway; one line = '
        'one recommendation; invalid lines rejected', () async {
      final gateway = _RecordingGateway(
        answer:
            'HIGH;expert_1;Coach croissance;Expérience directe du sujet.\n'
            'MEDIUM;expert_2;Consultant;Approche complémentaire.\n'
            'PERCENT;expert_3;Invalide;Confiance inconnue.\n'
            'ligne sans structure',
      );
      final provider = AIRecommendationProvider(gateway: gateway);

      final recommendations = await provider.recommend(
        need: 'Structurer ma croissance',
      );

      final request = gateway.executed.single;
      expect(request.task, AITask.recommendation);
      expect(request.text, contains('Structurer ma croissance'));
      expect(request.text, contains('n’inventes JAMAIS'));

      expect(recommendations, hasLength(2));
      expect(recommendations.first.expertId, 'expert_1');
      expect(
        recommendations.first.confidence,
        RecommendationConfidence.high,
      );
      expect(recommendations.last.expertId, 'expert_2');
      expect(
        () => recommendations.add(recommendations.first),
        throwsUnsupportedError,
      );
    });

    test('with known candidates, an expert outside them is NEVER '
        'invented — dropped', () async {
      final gateway = _RecordingGateway(
        answer:
            'HIGH;expert_1;Pertinent;Dans la liste.\n'
            'HIGH;expert_invente;Fantôme;Hors de la liste.',
      );
      final provider = AIRecommendationProvider(gateway: gateway);

      final recommendations = await provider.recommend(
        need: 'besoin',
        candidateExpertIds: const ['expert_1', 'expert_2'],
      );

      expect(recommendations.map((r) => r.expertId).toList(), ['expert_1']);
    });

    test('an engine with nothing relevant proposes nothing', () async {
      final provider = AIRecommendationProvider(
        gateway: _RecordingGateway(answer: '   '),
      );

      expect(await provider.recommend(need: 'besoin'), isEmpty);
    });
  });

  group('OpenAIRecommendationAdapter', () {
    test('delegates to the injected OpenAI relay and fails closed '
        'unconfigured', () async {
      const adapter = OpenAIRecommendationAdapter(
        configuration: OpenAIConfiguration(apiKey: ''),
      );

      expect(adapter.providerType, AIProviderType.openAI);
      await expectLater(
        adapter.execute(AIRequest(requestId: 'r1', text: 'prompt')),
        throwsA(isA<AIUnavailableFailure>()),
      );
      expect(await adapter.health(), isFalse);
    });
  });

  group('Governance — search and recommendation are total strangers', () {
    test('the application service knows only the port', () {
      final source = File(
        'lib/application/expert_recommendation/'
        'recommendation_application_service.dart',
      ).readAsStringSync();

      expect(source, contains('RecommendationProvider'));
      for (final forbidden in const [
        'AIGateway',
        'openai',
        'OpenAI',
        'HttpClient',
        'cloud_firestore',
        'ExpertCatalog',
        'expert_catalog',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the recommendation service must not know $forbidden',
        );
      }
    });

    test('the AI provider knows only the gateway — never the search '
        'engine, never storage', () {
      final source = File(
        'lib/infrastructure/expert_recommendation/'
        'ai_recommendation_provider.dart',
      ).readAsStringSync();

      expect(source, contains('AIGateway'));
      expect(source, contains('AITask.recommendation'));
      for (final forbidden in const [
        'openai',
        'OpenAI',
        'HttpClient',
        'cloud_firestore',
        'ExpertCatalog',
        'expert_catalog',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the recommendation provider must not know $forbidden',
        );
      }
    });

    test('the search engine never knows the recommendation pipeline — '
        'fully decoupled, both ways', () {
      // Search side: the catalog layers never reference recommendations.
      for (final path in const [
        'lib/application/expert_catalog/expert_catalog_application_service.dart',
        'lib/infrastructure/expert_catalog/firestore_expert_catalog_repository.dart',
        'lib/infrastructure/expert_catalog/expert_catalog_firestore_mapper.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final identifier in const [
          'ExpertRecommendation',
          'RecommendationProvider',
          'RecommendationApplicationService',
        ]) {
          expect(
            source,
            isNot(contains(identifier)),
            reason: '$path must not know $identifier',
          );
        }
      }

      // Recommendation surface confined to its own layers + composition.
      const allowedSurface = [
        'lib/domain/expert_recommendation/expert_recommendation.dart',
        'lib/domain/expert_recommendation/recommendation_provider.dart',
        'lib/application/expert_recommendation/'
            'recommendation_application_service.dart',
        'lib/infrastructure/expert_recommendation/'
            'ai_recommendation_provider.dart',
        'lib/infrastructure/ai_gateway/openai_recommendation_adapter.dart',
        'lib/composition/mentora_composition_root.dart',
        'lib/composition/mentora_dependencies.dart',
      ];
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('ExpertRecommendation') ||
                source.contains('RecommendationProvider') ||
                source.contains('RecommendationApplicationService')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

RecommendationApplicationService _service(_RecordingProvider provider) {
  return RecommendationApplicationService(
    session: _Session('client_1'),
    provider: provider,
  );
}

final class _RecordingProvider implements RecommendationProvider {
  _RecordingProvider({this.error});

  final Object? error;
  final List<String> needs = [];

  @override
  Future<List<ExpertRecommendation>> recommend({
    required String need,
    List<String> candidateExpertIds = const [],
  }) async {
    if (error case final cause?) throw cause;
    needs.add(need);
    return [
      ExpertRecommendation(
        recommendationId: 'r1',
        expertId: 'expert_1',
        title: 'Coach croissance',
        explanation: 'Correspond au besoin exprimé.',
        confidence: RecommendationConfidence.high,
        createdAt: DateTime.utc(2026, 8, 1),
      ),
    ];
  }

  @override
  Future<bool> health() async => true;
}

final class _RecordingGateway implements AIGateway {
  _RecordingGateway({required this.answer});

  final String answer;
  final List<AIRequest> executed = [];

  @override
  Future<AIResponse> execute(AIRequest request) async {
    executed.add(request);
    return AIResponse(
      providerType: AIProviderType.openAI,
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
