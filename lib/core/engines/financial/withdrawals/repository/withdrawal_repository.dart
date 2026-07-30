import '../withdrawal_request.dart';

abstract class WithdrawalRepository {
  Future<void> create(WithdrawalRequest request);

  Future<WithdrawalRequest?> findById(String id);

  Future<void> updateStatus({required String id, required String status});
}
