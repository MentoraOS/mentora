import 'package:cloud_firestore/cloud_firestore.dart';

import 'repository/firestore_withdrawal_repository.dart';
import 'repository/withdrawal_repository.dart';
import 'withdrawal_request.dart';
import 'withdrawal_status.dart';

class WithdrawalEngine {
  final WithdrawalRepository repository;

  const WithdrawalEngine({required this.repository});

  factory WithdrawalEngine.firestore() {
    return WithdrawalEngine(
      repository: FirestoreWithdrawalRepository(
        firestore: FirebaseFirestore.instance,
      ),
    );
  }

  Future<void> createWithdrawalRequest({
    required String expertId,
    required int amount,
    required String currency,
    required String countryCode,
    required String method,
    required String destination,
  }) async {
    final request = WithdrawalRequest(
      id: 'withdrawal_${DateTime.now().millisecondsSinceEpoch}',
      expertId: expertId,
      amount: amount,
      currency: currency,
      countryCode: countryCode,
      method: method,
      destination: destination,
      status: WithdrawalStatus.pending,
      createdAt: DateTime.now(),
    );

    await repository.create(request);
  }

  Future<WithdrawalRequest?> findWithdrawal(String id) {
    return repository.findById(id);
  }

  Future<void> updateWithdrawalStatus({
    required String id,
    required WithdrawalStatus status,
  }) {
    return repository.updateStatus(id: id, status: status.name);
  }
}
