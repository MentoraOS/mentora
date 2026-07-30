import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/phoenix/orchestrator/registry/pipeline_registry.dart';
import 'package:mentora/core/events/models/phoenix_event.dart';
import 'package:mentora/core/phoenix/orchestrator/engine/phoenix_orchestrator.dart';
import 'package:mentora/core/phoenix/orchestrator/registry/orchestration_rule_registry.dart';
import 'package:mentora/core/phoenix/orchestrator/rules/booking_confirmed_rule.dart';
import 'package:mentora/core/phoenix/orchestrator/services/booking_orchestration_service.dart';
import 'package:mentora/core/pricing/domains/pricing_domain.dart';
import 'package:mentora/core/pricing/engine/pricing_engine.dart';
import 'package:mentora/core/phoenix/orchestrator/pipelines/booking_pipeline_builder.dart';
import 'package:mentora/core/payment/engine/payment_engine.dart';
import 'package:mentora/core/payment/domains/payment_domain.dart';
import 'package:mentora/core/payment/repositories/memory_payment_repository.dart';

void main() {
  group('Phoenix Orchestrator', () {
    test('should execute booking confirmed rule', () async {
      final registry = OrchestrationRuleRegistry();
      final pricingDomain = PricingDomain();

      final pricingEngine = PricingEngine(domain: pricingDomain);
      final paymentRepository = MemoryPaymentRepository();

      final paymentDomain = PaymentDomain(repository: paymentRepository);

      final paymentEngine = PaymentEngine(domain: paymentDomain);

      final pipelineRegistry = PipelineRegistry();

      pipelineRegistry.registerPipeline(
        'booking.confirmed',
        BookingPipelineBuilder(
          pricingEngine: pricingEngine,
          paymentEngine: paymentEngine,
        ).build(),
      );

      final service = BookingOrchestrationService(
        pipelineRegistry: pipelineRegistry,
      );

      registry.registerRule(
        'booking.confirmed',
        BookingConfirmedRule(service: service),
      );

      final orchestrator = PhoenixOrchestrator(registry: registry);

      final event = PhoenixEvent(
        id: 'evt_orchestrator_001',
        name: 'booking.confirmed',
        source: 'booking',
        userId: 'client_001',
        consultationId: 'consultation_001',
        payload: const {'bookingId': 'booking_001', 'expertId': 'expert_001'},
        occurredAt: DateTime.now(),
      );

      final results = await orchestrator.handle(event);

      expect(results.length, 1);
      expect(results.first.success, isTrue);
    });
  });
}
