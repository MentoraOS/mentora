import '../../domain/payment/payment_collection_provider.dart';

/// Development stand-in for a real PSP.
///
/// Reproduces the product's current simulated behaviour exactly: a short
/// processing delay, then an authoritative confirmation. Swapping in a real
/// provider means replacing this adapter only; nothing upstream changes.
final class SimulatedPaymentProvider implements PaymentCollectionProvider {
  const SimulatedPaymentProvider({
    this.processingDelay = const Duration(seconds: 3),
  });

  final Duration processingDelay;

  @override
  Future<PaymentCollectionResult> collect(
    PaymentCollectionRequest request,
  ) async {
    await Future<void>.delayed(processingDelay);

    return PaymentCollectionConfirmed(
      providerReference: 'simulated:${request.method}:${request.bookingId}',
    );
  }
}
