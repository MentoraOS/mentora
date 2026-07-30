import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/mentora_theme.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> booking;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    required this.booking,
  });

  Future<void> _cancelBooking(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Réservation annulée')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final expertName = booking['expertName'] ?? 'Expert';
    final date = booking['bookingDate'] ?? '';
    final time = booking['bookingTime'] ?? '';
    final status = booking['status'] ?? 'pending';
    final amount = booking['amount']?.toString() ?? '15000';
    final postSummary = booking['postConsultationSummary'] ?? '';
    final postActions = List<String>.from(
      booking['postConsultationActions'] ?? [],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Détail réservation')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(MentoraRadius.large),
                boxShadow: MentoraShadows.soft,
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: MentoraColors.gold,
                    child: Icon(
                      Icons.calendar_month,
                      color: MentoraColors.navy,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    expertName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$date • $time',
                    style: const TextStyle(
                      color: MentoraColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(label: 'Statut', value: status),
                  _DetailRow(label: 'Montant', value: '$amount FCFA'),
                  const _DetailRow(label: 'Durée', value: '60 minutes'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (postSummary.isNotEmpty)
              _DetailCard(
                title: 'Résumé post-consultation',
                icon: Icons.auto_awesome,
                child: Text(
                  postSummary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

            const SizedBox(height: 16),

            if (postActions.isNotEmpty)
              _DetailCard(
                title: 'Actions recommandées',
                icon: Icons.task_alt,
                child: Column(
                  children: postActions.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: MentoraColors.gold,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(action)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: status == 'cancelled'
                    ? null
                    : () => _cancelBooking(context),
                icon: const Icon(Icons.cancel),
                label: const Text('Annuler la réservation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: MentoraColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(MentoraRadius.large),
        boxShadow: MentoraShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: MentoraColors.gold),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
