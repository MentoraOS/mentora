import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../application/authentication/authentication_session.dart';
import '../domain/booking/booking_overview.dart';
import '../theme/mentora_theme.dart';
import '../widgets/consultation_timeline.dart';

/// Consultation Dashboard: the dedicated space for a confirmed reservation.
///
/// Pure projection of the existing booking facts — no new business logic.
/// Notes, documents, messages and video are placeholders for their own
/// future milestones; joining the consultation stays disabled until the
/// video flow exists.
class ConsultationDashboardScreen extends StatelessWidget {
  const ConsultationDashboardScreen({super.key, required this.booking});

  final BookingOverview booking;

  static final NumberFormat _money = NumberFormat('#,##0', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    final session = context.read<AuthenticationSession>();
    final isExpert = session.isExpert;

    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Espace consultation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: participants.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: MentoraColors.gold,
                    child: Icon(
                      Icons.person,
                      color: MentoraColors.navy,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.expertName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isExpert ? 'Avec votre client' : 'Votre expert',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: booking.status),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _DashboardCard(
              title: 'Progression',
              icon: Icons.timeline,
              child: ConsultationTimeline(booking: booking),
            ),
            const SizedBox(height: 16),

            _DashboardCard(
              title: 'Informations de consultation',
              icon: Icons.event_note,
              child: Column(
                children: [
                  _InfoRow(label: 'Date', value: booking.bookingDate),
                  _InfoRow(label: 'Heure', value: booking.bookingTime),
                  if (booking.durationMinutes case final duration?)
                    _InfoRow(label: 'Durée', value: '$duration minutes'),
                  if (booking.expertTimezone case final timezone?)
                    _InfoRow(label: 'Fuseau horaire', value: timezone),
                  if (booking.amountMinor case final amount?)
                    _InfoRow(
                      label: 'Montant',
                      value:
                          '${_money.format(amount)} '
                          '${booking.currency ?? 'XOF'}',
                    ),
                  if (booking.aiSummary.isNotEmpty)
                    _InfoRow(label: 'Brief IA', value: 'Préparé ✓'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const _DashboardCard(
              title: 'Notes privées',
              icon: Icons.edit_note,
              child: _PlaceholderBody(
                'Vos notes personnelles de consultation arrivent bientôt.',
              ),
            ),
            const SizedBox(height: 16),

            const _DashboardCard(
              title: 'Documents partagés',
              icon: Icons.folder_shared,
              child: _PlaceholderBody(
                'Le partage de documents arrive bientôt.',
              ),
            ),
            const SizedBox(height: 16),

            const _DashboardCard(
              title: 'Messages',
              icon: Icons.chat_bubble_outline,
              child: _PlaceholderBody(
                'La messagerie de consultation arrive bientôt.',
              ),
            ),
            const SizedBox(height: 16),

            const _DashboardCard(
              title: 'Consultation vidéo',
              icon: Icons.videocam_outlined,
              child: _PlaceholderBody(
                'La salle vidéo sera disponible au moment de la '
                'consultation.',
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                // Disabled until the video flow exists (its own milestone).
                onPressed: null,
                icon: const Icon(Icons.videocam),
                label: const Text(
                  'Rejoindre la consultation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Disponible prochainement',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'confirmed' => ('Confirmée', Colors.greenAccent),
      'paid' => ('Payée', Colors.greenAccent),
      'completed' => ('Terminée', Colors.lightBlueAccent),
      _ => (status, Colors.white54),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
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
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message, style: const TextStyle(color: Colors.white54));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
