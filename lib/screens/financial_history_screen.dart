import 'package:flutter/material.dart';

import '../core/engines/financial/ledger/financial_ledger_factory.dart';
import '../theme/mentora_theme.dart';

class FinancialHistoryScreen extends StatelessWidget {
  final String accountId;

  const FinancialHistoryScreen({super.key, required this.accountId});

  String formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledger = FinancialLedgerFactory.firestore();

    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Historique financier'),
      ),
      body: FutureBuilder(
        future: ledger.repository.transactionsForAccount(accountId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: MentoraColors.gold),
            );
          }

          final transactions = snapshot.data!;

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'Aucune transaction pour le moment.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];

              final entry = tx.entries.firstWhere(
                (e) => e.accountId == accountId,
              );

              final sign = entry.type.name == 'credit' ? '+' : '-';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: MentoraColors.gold,
                      child: Icon(
                        Icons.receipt_long,
                        color: MentoraColors.navy,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.transactionType.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tx.reference,
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$sign${formatMoney(entry.amount)} ${tx.currency}',
                      style: const TextStyle(
                        color: MentoraColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
