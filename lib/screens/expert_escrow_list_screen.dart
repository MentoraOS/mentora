import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/routing/app_router.dart';
import '../theme/mentora_theme.dart';
import 'escrow_screen.dart';

class ExpertEscrowListScreen extends StatelessWidget {
  final String expertId;
  final String currency;

  const ExpertEscrowListScreen({
    super.key,
    required this.expertId,
    required this.currency,
  });

  String formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Escrow expert'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('expertId', isEqualTo: expertId)
            .where('paymentStatus', isEqualTo: 'paid')
            .where('escrowReleased', isEqualTo: false)
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
                'Aucun montant en escrow pour le moment.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final bookingId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final amount = data['amount'] ?? 0;
              final clientName = data['clientName'] ?? 'Client';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    AppRouter.openEscrow(
                      context: context,
                      bookingId: bookingId,
                      currency: currency,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: MentoraColors.gold,
                          child: Icon(Icons.lock, color: MentoraColors.navy),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clientName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bookingId,
                                style: const TextStyle(color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${formatMoney(amount)} $currency',
                          style: const TextStyle(
                            color: MentoraColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
