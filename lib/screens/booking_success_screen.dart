import 'package:flutter/material.dart';
import '../theme/mentora_theme.dart';
import 'waiting_room_screen.dart';
import '../core/routing/app_router.dart';

class BookingSuccessScreen extends StatefulWidget {
  final String bookingId;
  final String expertName;
  final String selectedDate;
  final String selectedTime;
  final String aiSummary;

  const BookingSuccessScreen({
    super.key,
    required this.bookingId,
    required this.expertName,
    required this.selectedDate,
    required this.selectedTime,
    required this.aiSummary,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Paiement confirmé'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(.35),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 70,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Consultation réservée',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Votre paiement a été confirmé avec succès.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 28),

            Column(
              children: [
                _InfoCard(
                  icon: Icons.person,
                  title: "Votre expert",
                  child: Text(
                    widget.expertName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                _InfoCard(
                  icon: Icons.calendar_month,
                  title: "Détails de la consultation",
                  child: Column(
                    children: [
                      _InfoRow(label: "Date", value: widget.selectedDate),

                      _InfoRow(label: "Heure", value: widget.selectedTime),

                      const _InfoRow(label: "Durée", value: "60 minutes"),

                      const _InfoRow(label: "Montant", value: "50 000 FCFA"),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _InfoCard(
                  icon: Icons.auto_awesome,
                  title: "Résumé Mentora AI",
                  child: Text(
                    widget.aiSummary.isEmpty
                        ? "Aucun résumé IA disponible."
                        : widget.aiSummary,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ),

                const SizedBox(height: 18),

                const _InfoCard(
                  icon: Icons.verified,
                  title: "Confirmation",
                  child: Column(
                    children: [
                      _SuccessRow("Paiement sécurisé"),

                      _SuccessRow("Réservation confirmée"),

                      _SuccessRow("Salle d'attente disponible"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  AppRouter.replaceWithWaitingRoom(
                    context: context,
                    bookingId: widget.bookingId,
                    expertName: widget.expertName,
                    selectedDate: widget.selectedDate,
                    selectedTime: widget.selectedTime,
                    aiSummary: widget.aiSummary,
                  );
                },

                icon: const Icon(Icons.calendar_month),
                label: const Text('Réjoindre la salle'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Retour à l’accueil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: MentoraColors.gold,
                  side: const BorderSide(color: MentoraColors.gold),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: MentoraColors.gold),

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  final String text;

  const _SuccessRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),

          const SizedBox(width: 12),

          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
