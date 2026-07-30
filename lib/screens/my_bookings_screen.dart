import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../application/authentication/authentication_session.dart';
import 'booking_detail_screen.dart';
import '../theme/mentora_theme.dart';
import '../core/routing/app_router.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationSession>().currentUserId;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Session introuvable')));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Mes réservations')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('clientId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: MentoraColors.gold),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Aucune réservation pour le moment.'),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              final isCompleted = status == 'completed';
              final hasSummary = (data['postConsultationSummary'] ?? '')
                  .toString()
                  .isNotEmpty;
              final hasRating = data['rating'] != null;

              return InkWell(
                onTap: () {
                  AppRouter.openBookingDetail(
                    context: context,
                    bookingId: bookings[index].id,
                    booking: data,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(MentoraRadius.large),
                    boxShadow: MentoraShadows.soft,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isCompleted
                            ? Colors.greenAccent
                            : MentoraColors.gold,
                        child: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.calendar_month,
                          color: MentoraColors.navy,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['expertName'] ?? 'Expert',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '${data['bookingDate'] ?? ''} • ${data['bookingTime'] ?? ''}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),

                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _BookingBadge(
                                  icon: isCompleted
                                      ? Icons.check_circle
                                      : Icons.schedule,
                                  text: isCompleted ? 'Terminée' : status,
                                  color: isCompleted
                                      ? Colors.greenAccent
                                      : MentoraColors.gold,
                                ),

                                if (hasRating)
                                  const _BookingBadge(
                                    icon: Icons.star,
                                    text: 'Note donnée',
                                    color: MentoraColors.gold,
                                  ),

                                if (hasSummary)
                                  const _BookingBadge(
                                    icon: Icons.auto_awesome,
                                    text: 'Résumé disponible',
                                    color: Colors.lightBlueAccent,
                                  ),

                                if (isCompleted)
                                  const _BookingBadge(
                                    icon: Icons.receipt_long,
                                    text: 'Reçu PDF',
                                    color: Colors.white70,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
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

class _BookingBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _BookingBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
