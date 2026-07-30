import '../../repositories/withdrawal_repository.dart';

class RejectWithdrawalUseCase {
  final WithdrawalRepository repository;

  const RejectWithdrawalUseCase(this.repository);

  Future<void> call(String requestId) {
    return repository.reject(requestId);
  }
}
