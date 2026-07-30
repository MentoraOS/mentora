import 'escrow.dart';

class EscrowResult {
  final bool success;
  final String? message;
  final Escrow? escrow;

  const EscrowResult({required this.success, this.message, this.escrow});
}
