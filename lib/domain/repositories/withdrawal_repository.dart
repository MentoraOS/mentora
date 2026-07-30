abstract class WithdrawalRepository {
  Future<void> approve(String requestId);

  Future<void> reject(String requestId);
}
