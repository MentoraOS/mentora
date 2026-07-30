import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import '../theme/mentora_theme.dart';

import '../domain/usecases/withdrawal/approve_withdrawal_usecase.dart';
import '../domain/usecases/withdrawal/reject_withdrawal_usecase.dart';
import '../core/engines/identity/widgets/admin_guard.dart';

import '../core/di/service_locater.dart';
import '../../domain/repositories/withdrawal_repository.dart';

class WithdrawalAdminScreen extends StatelessWidget {
  const WithdrawalAdminScreen({super.key});

  String formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  Future<void> approveWithdrawal(String requestId) async {
    final repository = ServiceLocator.get<WithdrawalRepository>();
    final useCase = ApproveWithdrawalUseCase(repository);
    await useCase(requestId);
  }

  Future<void> rejectWithdrawal(String requestId) async {
    final repository = ServiceLocator.get<WithdrawalRepository>();

    final useCase = RejectWithdrawalUseCase(repository);

    await useCase(requestId);
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        backgroundColor: MentoraColors.navy,
        appBar: AppBar(
          backgroundColor: MentoraColors.navy,
          elevation: 0,
          title: const Text('Demandes de retrait'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('withdrawal_requests')
              .where('status', isEqualTo: 'pending')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: MentoraColors.gold),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune demande en attente.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final requestId = docs[index].id;
                final data = docs[index].data() as Map<String, dynamic>;

                final expertId = data['expertId'] ?? '';
                final amount = data['amount'] ?? 0;
                final currency = data['currency'] ?? 'XOF';
                final method = data['method'] ?? '';
                final destination = data['destination'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formatMoney(amount)} $currency',
                        style: const TextStyle(
                          color: MentoraColors.gold,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Expert : $expertId',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Méthode : $method',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Destination : $destination',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await rejectWithdrawal(requestId);
                              },
                              child: const Text('Rejeter'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await approveWithdrawal(requestId);
                              },
                              child: const Text('Approuver'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
