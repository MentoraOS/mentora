import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/authentication/authentication_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'video_call_screen.dart';
import '../core/routing/app_router.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthenticationSession>().currentUserId;
    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text('Session introuvable')));
    }

    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mes sessions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Suivez vos consultations réservées.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 26),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('clientId', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: gold),
                    );
                  }

                  final bookings = snapshot.data!.docs;

                  return Column(
                    children: [
                      _StatsRow(total: bookings.length),

                      const SizedBox(height: 28),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'À venir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      if (bookings.isEmpty)
                        const Text(
                          'Aucune session réservée pour le moment.',
                          style: TextStyle(color: Colors.white60),
                        )
                      else
                        Column(
                          children: bookings.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            print(
                              'DOC ${doc.id} STATUS = ${data['meetingStatus']}',
                            );
                            final meetingStatus =
                                data['meetingStatus'] ?? 'waiting';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _SessionCard(
                                bookingId: doc.id,
                                expert: data['expertName'] ?? '',
                                duration: data['duration'] ?? 0,
                                time: data['time'] ?? '',
                                totalPrice: data['totalPrice'] ?? 0,
                                status: data['meetingStatus'] ?? 'waiting',
                                paymentMethod: data['paymentMethod'] ?? '',
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int total;

  const _StatsRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(value: '$total', label: 'Sessions'),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(value: '0', label: 'Terminées'),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(value: '0', label: 'Annulées'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A400);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: gold,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String expert;
  final int duration;
  final String time;
  final int totalPrice;
  final String paymentMethod;
  final String status;
  final String bookingId;

  const _SessionCard({
    required this.bookingId,
    required this.expert,
    required this.duration,
    required this.time,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A400);

    final bool waiting = status == 'waiting';
    final bool started = status == 'started';
    final bool completed = status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: gold,
            child: const Icon(Icons.person, color: Colors.black),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expert,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$duration min • $paymentMethod',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  '$totalPrice FCFA',
                  style: const TextStyle(
                    color: Color(0xFFF5A400),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: started
                      ? Colors.green.withOpacity(0.12)
                      : completed
                      ? Colors.blue.withOpacity(0.12)
                      : gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  started
                      ? 'En cours'
                      : completed
                      ? 'Terminée'
                      : 'En attente',
                  style: TextStyle(
                    color: started
                        ? Colors.green
                        : completed
                        ? Colors.blue
                        : gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (true)
                ElevatedButton.icon(
                  onPressed: () {
                    AppRouter.openVideoCall(
                      context: context,
                      bookingId: bookingId,
                      expertName: expert,
                    );
                  },
                  icon: const Icon(Icons.videocam, size: 16),
                  label: const Text('Rejoindre'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
