import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/payment/payment_collection_application_service.dart';
import 'package:mentora/domain/payment/payment_collection_provider.dart';
import 'package:mentora/infrastructure/payment/simulated_payment_provider.dart';

void main() {
  group('Payment Provider boundary — AD-021 D12 / AD-022 D11', () {
    test('forwards the authoritative commercial values verbatim', () async {
      final provider = _RecordingProvider();
      final service = PaymentCollectionApplicationService(provider: provider);

      final outcome = await service.collect(
        bookingId: 'booking_1',
        amountMinor: 50000,
        currency: 'XOF',
        method: 'wave',
      );

      final request = provider.requests.single;
      expect(request.bookingId, 'booking_1');
      expect(request.amountMinor, 50000);
      expect(request.currency, 'XOF');
      expect(request.method, 'wave');
      expect(outcome, isA<PaymentCollectionConfirmed>());
    });

    test('a definitive rejection is a result, never an exception', () async {
      final service = PaymentCollectionApplicationService(
        provider: const _FixedProvider(
          PaymentCollectionRejected(reason: 'declined'),
        ),
      );

      final outcome = await service.collect(
        bookingId: 'booking_1',
        amountMinor: 50000,
        currency: 'XOF',
        method: 'wave',
      );

      expect(
        outcome,
        isA<PaymentCollectionRejected>().having(
          (rejected) => rejected.reason,
          'reason',
          'declined',
        ),
      );
    });

    test('an unexpected provider error becomes an ambiguous outcome', () {
      final service = PaymentCollectionApplicationService(
        provider: _ThrowingProvider(StateError('socket closed')),
      );

      expect(
        () => service.collect(
          bookingId: 'booking_1',
          amountMinor: 50000,
          currency: 'XOF',
          method: 'wave',
        ),
        throwsA(isA<PaymentCollectionAmbiguousFailure>()),
      );
    });

    test('typed provider failures propagate unchanged', () {
      final service = PaymentCollectionApplicationService(
        provider: _ThrowingProvider(
          const PaymentCollectionUnavailableFailure(cause: 'down'),
        ),
      );

      expect(
        () => service.collect(
          bookingId: 'booking_1',
          amountMinor: 50000,
          currency: 'XOF',
          method: 'wave',
        ),
        throwsA(isA<PaymentCollectionUnavailableFailure>()),
      );
    });

    test('invalid requests fail before any provider call', () {
      final provider = _RecordingProvider();
      final service = PaymentCollectionApplicationService(provider: provider);

      expect(
        () => service.collect(
          bookingId: ' ',
          amountMinor: 50000,
          currency: 'XOF',
          method: 'wave',
        ),
        throwsArgumentError,
      );
      expect(
        () => service.collect(
          bookingId: 'booking_1',
          amountMinor: -1,
          currency: 'XOF',
          method: 'wave',
        ),
        throwsArgumentError,
      );
      expect(provider.requests, isEmpty);
    });

    test('the simulated provider confirms with a stable reference', () async {
      const provider = SimulatedPaymentProvider(processingDelay: Duration.zero);

      final outcome = await provider.collect(
        PaymentCollectionRequest(
          bookingId: 'booking_1',
          amountMinor: 50000,
          currency: 'XOF',
          method: 'wave',
        ),
      );

      expect(
        (outcome as PaymentCollectionConfirmed).providerReference,
        'simulated:wave:booking_1',
      );
    });
  });
}

final class _RecordingProvider implements PaymentCollectionProvider {
  final List<PaymentCollectionRequest> requests = [];

  @override
  Future<PaymentCollectionResult> collect(
    PaymentCollectionRequest request,
  ) async {
    requests.add(request);
    return const PaymentCollectionConfirmed(providerReference: 'ref_1');
  }
}

final class _FixedProvider implements PaymentCollectionProvider {
  const _FixedProvider(this.result);

  final PaymentCollectionResult result;

  @override
  Future<PaymentCollectionResult> collect(
    PaymentCollectionRequest request,
  ) async {
    return result;
  }
}

final class _ThrowingProvider implements PaymentCollectionProvider {
  const _ThrowingProvider(this.error);

  final Object error;

  @override
  Future<PaymentCollectionResult> collect(
    PaymentCollectionRequest request,
  ) async {
    throw error;
  }
}
