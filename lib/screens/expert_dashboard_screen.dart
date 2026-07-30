import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/routing/app_router.dart';

class ExpertDashboardScreen extends StatelessWidget {
  final String expertId;

  const ExpertDashboardScreen({super.key, required this.expertId});

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(backgroundColor: navy, title: const Text('Espace Expert')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('expertId', isEqualTo: expertId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: gold));
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                'Aucune réservation reçue',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final doc = bookings[index];
              final data = doc.data() as Map<String, dynamic>;
              final meetingStatus = data['meetingStatus'] ?? 'waiting';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['expertName'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${data['duration']} min • ${data['time']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${data['totalPrice']} FCFA',
                      style: const TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meetingStatus == 'started'
                          ? 'Session en cours'
                          : meetingStatus == 'completed'
                          ? 'Terminée'
                          : 'En attente',
                      style: TextStyle(
                        color: meetingStatus == 'started'
                            ? Colors.greenAccent
                            : meetingStatus == 'completed'
                            ? Colors.blueAccent
                            : gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _FinancialCenterCard(
                      onTap: () {
                        AppRouter.openFinancialCenter(
                          context: context,
                          expertId: expertId,
                          currency: 'XOF',
                          countryCode: 'ML',
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {
                        try {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bouton cliqué')),
                          );

                          print("DOC ID = ${doc.id}");

                          await FirebaseFirestore.instance
                              .collection('bookings')
                              .doc(doc.id)
                              .update({
                                'meetingStatus': 'started',
                                'meetingStarted': true,
                                'startedAt': FieldValue.serverTimestamp(),
                              });

                          if (!context.mounted) return;

                          AppRouter.openVideoCall(
                            context: context,
                            bookingId: doc.id,
                            expertName: data['expertName'] ?? '',
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Session démarrée')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                        }
                      },
                      child: const Text('Démarrer la session'),
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

class _FinancialCenterCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FinancialCenterCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A400);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold.withOpacity(.35)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: gold.withOpacity(.18),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: gold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Centre financier',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Wallet, revenus, retraits et historique',
                      style: TextStyle(color: Colors.white70, height: 1.3),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
