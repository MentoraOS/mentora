import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../application/authentication/authentication_session.dart';

import '../theme/mentora_theme.dart';

class MyPaymentsScreen extends StatelessWidget {
  const MyPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationSession>().currentUserId;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Session introuvable')));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Mes paiements')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('clientId', isEqualTo: uid)
            .where('paymentStatus', isEqualTo: 'paid')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: MentoraColors.gold),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          int totalSpent = 0;

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalSpent += (data['amount'] ?? 0) as int;
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _FinanceSummaryCard(
                totalSpent: totalSpent,
                paymentsCount: docs.length,
              ),

              const SizedBox(height: 22),

              Text(
                'Historique',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 12),

              if (docs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(MentoraRadius.large),
                    boxShadow: MentoraShadows.soft,
                  ),
                  child: Text(
                    'Aucun paiement pour le moment.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return _PaymentTile(
                    expertName: data['expertName'] ?? 'Expert',
                    date: data['bookingDate'] ?? '',
                    time: data['bookingTime'] ?? '',
                    amount: data['amount'] ?? 0,
                    method: data['paymentMethod'] ?? 'Orange Money',
                    status: data['paymentStatus'] ?? 'paid',
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _FinanceSummaryCard extends StatelessWidget {
  final int totalSpent;
  final int paymentsCount;

  const _FinanceSummaryCard({
    required this.totalSpent,
    required this.paymentsCount,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTotal = totalSpent.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (match) => '${match[1]} ',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: MentoraColors.gold,
        borderRadius: BorderRadius.circular(MentoraRadius.large),
        boxShadow: MentoraShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total dépensé',
            style: TextStyle(
              color: MentoraColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$formattedTotal FCFA',
            style: const TextStyle(
              color: MentoraColors.navy,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$paymentsCount paiement(s) effectué(s)',
            style: const TextStyle(
              color: MentoraColors.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String expertName;
  final String date;
  final String time;
  final int amount;
  final String method;
  final String status;

  const _PaymentTile({
    required this.expertName,
    required this.date,
    required this.time,
    required this.amount,
    required this.method,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (match) => '${match[1]} ',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(MentoraRadius.large),
        boxShadow: MentoraShadows.soft,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: MentoraColors.gold,
            child: Icon(Icons.receipt_long, color: MentoraColors.navy),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expertName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$date • $time',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  method,
                  style: const TextStyle(
                    color: MentoraColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$formattedAmount FCFA',
                style: const TextStyle(
                  color: MentoraColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status == 'paid' ? 'Payé' : status,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
