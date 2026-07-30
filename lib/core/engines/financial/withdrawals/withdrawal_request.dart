import 'withdrawal_status.dart';

class WithdrawalRequest {
  final String id;
  final String expertId;
  final int amount;
  final String currency;
  final String countryCode;
  final String method;
  final String destination;
  final WithdrawalStatus status;
  final DateTime createdAt;

  const WithdrawalRequest({
    required this.id,
    required this.expertId,
    required this.amount,
    required this.currency,
    required this.countryCode,
    required this.method,
    required this.destination,
    required this.status,
    required this.createdAt,
  });
}
