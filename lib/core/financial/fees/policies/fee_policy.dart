import '../models/fee_quote.dart';

abstract class FeePolicy {
  const FeePolicy();

  String get key;

  FeeQuote calculate({required int grossAmountMinor, required String currency});
}
