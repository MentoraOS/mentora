import '../../domain/repositories/withdrawal_repository.dart';
import '../engines/financial/withdrawals/withdrawal_processor.dart';

class WithdrawalRepositoryImpl implements WithdrawalRepository {
  const WithdrawalRepositoryImpl();

  @override
  Future<void> approve(String requestId) {
    return WithdrawalProcessor.approve(requestId: requestId);
  }

  @override
  Future<void> reject(String requestId) {
    return WithdrawalProcessor.reject(requestId: requestId);
  }
}
