/// Marketplace Payment Provider boundary (AD-021 decision 12, AD-022
/// decision 11).
///
/// Any real PSP (mobile money, gateway, card) is integrated by implementing
/// this port in Infrastructure; nothing else changes. Payment consumes the
/// authoritative amount and currency and never computes them, and the port
/// keeps the canonical outcome distinctions:
///
/// - [PaymentCollectionConfirmed] — the provider authoritatively confirmed.
/// - [PaymentCollectionRejected] — the provider DEFINITIVELY rejected.
/// - [PaymentCollectionProviderFailure] (thrown) — timeout, unavailability or
///   an ambiguous outcome. Ambiguity is NEVER a confirmation and NEVER a
///   definitive rejection.
///
/// This is the product-facing payment boundary only: it owns no reservation
/// state and no Financial Core semantics.
abstract interface class PaymentCollectionProvider {
  Future<PaymentCollectionResult> collect(PaymentCollectionRequest request);
}

final class PaymentCollectionRequest {
  final String bookingId;
  final int amountMinor;
  final String currency;

  /// Provider method identifier selected by the client (e.g. `wave`).
  final String method;

  factory PaymentCollectionRequest({
    required String bookingId,
    required int amountMinor,
    required String currency,
    required String method,
  }) {
    if (bookingId.trim().isEmpty) {
      throw ArgumentError.value(bookingId, 'bookingId', 'must not be empty');
    }
    if (amountMinor < 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'must not be negative',
      );
    }
    if (currency.trim().isEmpty) {
      throw ArgumentError.value(currency, 'currency', 'must not be empty');
    }
    if (method.trim().isEmpty) {
      throw ArgumentError.value(method, 'method', 'must not be empty');
    }

    return PaymentCollectionRequest._(
      bookingId: bookingId,
      amountMinor: amountMinor,
      currency: currency,
      method: method,
    );
  }

  const PaymentCollectionRequest._({
    required this.bookingId,
    required this.amountMinor,
    required this.currency,
    required this.method,
  });
}

sealed class PaymentCollectionResult {
  const PaymentCollectionResult();
}

/// The provider authoritatively confirmed the collection.
final class PaymentCollectionConfirmed extends PaymentCollectionResult {
  const PaymentCollectionConfirmed({required this.providerReference});

  /// Provider-issued reference of the confirmed collection.
  final String providerReference;
}

/// The provider DEFINITIVELY rejected the collection (AD-022 decision 11).
final class PaymentCollectionRejected extends PaymentCollectionResult {
  const PaymentCollectionRejected({required this.reason});

  final String reason;
}

/// Thrown outcomes that are neither confirmation nor definitive rejection.
sealed class PaymentCollectionProviderFailure implements Exception {
  const PaymentCollectionProviderFailure();
}

/// The provider could not be reached or failed technically.
final class PaymentCollectionUnavailableFailure
    extends PaymentCollectionProviderFailure {
  const PaymentCollectionUnavailableFailure({required this.cause});

  final Object cause;
}

/// The outcome is unknown (timeout, ambiguous response, disconnect). It MUST
/// NOT be treated as success and MUST NOT be treated as definitive rejection.
final class PaymentCollectionAmbiguousFailure
    extends PaymentCollectionProviderFailure {
  const PaymentCollectionAmbiguousFailure({this.cause});

  final Object? cause;
}
