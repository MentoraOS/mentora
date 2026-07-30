import 'commission_result.dart';

class CommissionEngine {
  CommissionEngine._();

  static CommissionResult calculate({
    required int amount,
    required double commissionPercent,
  }) {
    final platformFee = (amount * commissionPercent / 100).round();
    final expertAmount = amount - platformFee;

    return CommissionResult(
      grossAmount: amount,
      platformFee: platformFee,
      expertAmount: expertAmount,
    );
  }
}
