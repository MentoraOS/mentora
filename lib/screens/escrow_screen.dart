import 'package:flutter/material.dart';

import '../core/engines/financial/ledger/financial_ledger_factory.dart';
import '../theme/mentora_theme.dart';

class EscrowScreen extends StatelessWidget {
  final String bookingId;
  final String currency;

  const EscrowScreen({
    super.key,
    required this.bookingId,
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
    final accountId = 'escrow_$bookingId';
    final ledger = FinancialLedgerFactory.firestore();

    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Escrow'),
      ),
      body: FutureBuilder(
        future: ledger.balanceOf(accountId),
        builder: (context, snapshot) {
          final balance = snapshot.data ?? 0;

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: MentoraColors.gold),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, color: MentoraColors.gold, size: 58),
                  const SizedBox(height: 16),
                  const Text(
                    'Montant en escrow',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${formatMoney(balance)} $currency',
                    style: const TextStyle(
                      color: MentoraColors.gold,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
