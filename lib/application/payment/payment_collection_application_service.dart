import '../../domain/payment/payment_collection_provider.dart';

/// Orchestrates a payment collection through the provider port.
///
/// The service builds the validated request from the authoritative commercial
/// values (AD-021 decision 12 — never recomputed here) and returns the
/// provider's typed outcome. Ambiguous or failed collections surface as
/// [PaymentCollectionProviderFailure]; callers must never present them as a
/// confirmation, and Booking confirmation remains its own Booking-owned
/// boundary invoked only on a confirmed outcome.
final class PaymentCollectionApplicationService {
  const PaymentCollectionApplicationService({
    required PaymentCollectionProvider provider,
  }) : _provider = provider;

  final PaymentCollectionProvider _provider;

  Future<PaymentCollectionResult> collect({
    required String bookingId,
    required int amountMinor,
    required String currency,
    required String method,
  }) async {
    final request = PaymentCollectionRequest(
      bookingId: bookingId,
      amountMinor: amountMinor,
      currency: currency,
      method: method,
    );

    try {
      return await _provider.collect(request);
    } on PaymentCollectionProviderFailure {
      rethrow;
    } catch (error) {
      // An unexpected provider error is an unknown outcome, never a result.
      throw PaymentCollectionAmbiguousFailure(cause: error);
    }
  }
}
