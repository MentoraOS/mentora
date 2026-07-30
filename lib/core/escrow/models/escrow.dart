import 'escrow_status.dart';

class Escrow {
  final String id;
  final String paymentId;
  final String consultationId;

  final String payerId;
  final String receiverId;

  final double amount;
  final String currency;

  final EscrowStatus status;

  const Escrow({
    required this.id,
    required this.paymentId,
    required this.consultationId,
    required this.payerId,
    required this.receiverId,
    required this.amount,
    required this.currency,
    required this.status,
  });

  Escrow copyWith({EscrowStatus? status}) {
    return Escrow(
      id: id,
      paymentId: paymentId,
      consultationId: consultationId,
      payerId: payerId,
      receiverId: receiverId,
      amount: amount,
      currency: currency,
      status: status ?? this.status,
    );
  }
}
