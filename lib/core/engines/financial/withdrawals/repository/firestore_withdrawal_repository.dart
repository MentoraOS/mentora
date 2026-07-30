import 'package:cloud_firestore/cloud_firestore.dart';

import '../withdrawal_request.dart';
import '../withdrawal_status.dart';
import 'withdrawal_repository.dart';

class FirestoreWithdrawalRepository implements WithdrawalRepository {
  final FirebaseFirestore firestore;

  const FirestoreWithdrawalRepository({required this.firestore});

  @override
  Future<void> create(WithdrawalRequest request) async {
    await firestore.collection('withdrawal_requests').doc(request.id).set({
      'id': request.id,
      'expertId': request.expertId,
      'amount': request.amount,
      'currency': request.currency,
      'countryCode': request.countryCode,
      'method': request.method,
      'destination': request.destination,
      'status': request.status.name,
      'createdAt': Timestamp.fromDate(request.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<WithdrawalRequest?> findById(String id) async {
    final doc = await firestore.collection('withdrawal_requests').doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    return WithdrawalRequest(
      id: data['id'],
      expertId: data['expertId'],
      amount: data['amount'],
      currency: data['currency'],
      countryCode: data['countryCode'],
      method: data['method'],
      destination: data['destination'],
      status: _statusFromString(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    await firestore.collection('withdrawal_requests').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  WithdrawalStatus _statusFromString(String value) {
    switch (value) {
      case 'approved':
        return WithdrawalStatus.approved;
      case 'rejected':
        return WithdrawalStatus.rejected;
      case 'processing':
        return WithdrawalStatus.processing;
      case 'paid':
        return WithdrawalStatus.paid;
      case 'failed':
        return WithdrawalStatus.failed;
      default:
        return WithdrawalStatus.pending;
    }
  }
}
