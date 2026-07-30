import '../../repositories/withdrawal_repository.dart';

class ApproveWithdrawalUseCase {
  final WithdrawalRepository repository;

  const ApproveWithdrawalUseCase(this.repository);

  Future<void> call(String requestId) {
    return repository.approve(requestId);
  }
}
