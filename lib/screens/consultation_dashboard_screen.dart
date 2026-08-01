import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../application/authentication/authentication_session.dart';
import '../application/booking/consultation_completion_application_service.dart';
import '../application/booking/consultation_completion_failure.dart';
import '../application/notification/booking_notification_application_service.dart';
import '../application/video_session/video_session_application_service.dart';
import '../application/video_session/video_session_failure.dart';
import '../domain/booking/booking_overview.dart';
import '../core/routing/app_router.dart';
import '../theme/mentora_theme.dart';
import '../widgets/consultation_brief_card.dart';
import '../widgets/consultation_documents_card.dart';
import '../widgets/consultation_private_notes_card.dart';
import '../widgets/consultation_review_card.dart';
import '../widgets/consultation_timeline.dart';
import 'live_consultation_screen.dart';
import 'review_screen.dart';

/// Consultation Dashboard: the dedicated space for a confirmed reservation.
///
/// Pure projection of the existing booking facts — no new business logic.
/// Notes, documents, messages and video are placeholders for their own
/// future milestones; joining the consultation stays disabled until the
/// video flow exists.
class ConsultationDashboardScreen extends StatefulWidget {
  const ConsultationDashboardScreen({super.key, required this.booking});

  final BookingOverview booking;

  @override
  State<ConsultationDashboardScreen> createState() =>
      _ConsultationDashboardScreenState();
}

class _ConsultationDashboardScreenState
    extends State<ConsultationDashboardScreen> {
  static final NumberFormat _money = NumberFormat('#,##0', 'fr_FR');

  BookingOverview get booking => widget.booking;

  /// Local echo of the official completion; the durable state lives in the
  /// booking document and streams into the dashboards.
  bool _completed = false;

  Future<void> _joinConsultation(BuildContext context) async {
    var message = 'La salle vidéo est indisponible. Réessayez plus tard.';
    try {
      final session = await context
          .read<VideoSessionApplicationService>()
          .joinConsultation(booking);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LiveConsultationScreen(session: session),
        ),
      );
      return;
    } on VideoSessionInvalidStateFailure {
      message =
          'Cette consultation ne peut pas être rejointe '
          'pour le moment.';
    } on VideoSessionFailure {
      // Keep the generic message.
    } catch (_) {
      // Keep the generic message.
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _completeConsultation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terminer la consultation'),
        content: const Text(
          'Confirmer la fin de cette consultation ? '
          'La réservation sera officiellement clôturée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    var message = 'La clôture a échoué. Réessayez plus tard.';
    try {
      await context.read<ConsultationCompletionApplicationService>().complete(
        booking.bookingId,
      );

      if (mounted) {
        // Best-effort by contract: a notification failure never blocks the
        // completed consultation.
        await context
            .read<BookingNotificationApplicationService>()
            .notifyBookingCompleted(
              bookingId: booking.bookingId,
              expertId: booking.expertId,
              expertName: booking.expertName,
              displayDate: booking.bookingDate,
              displayTime: booking.bookingTime,
            );
      }

      if (!mounted) return;
      setState(() => _completed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation terminée.')),
      );
      return;
    } on ConsultationCompletionInvalidStateFailure {
      message = 'Cette consultation ne peut plus être terminée.';
    } on ConsultationCompletionNotFoundFailure {
      message = 'Cette réservation est introuvable.';
    } on ConsultationCompletionFailure {
      // Keep the generic message.
    } catch (_) {
      // Keep the generic message.
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<AuthenticationSession>();
    final isExpert = session.isExpert;
    final canComplete =
        !_completed &&
        (booking.status == 'confirmed' || booking.status == 'paid');
    final canReview =
        !isExpert && (_completed || booking.status == 'completed');

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
                  _StatusBadge(
                    status: _completed ? 'completed' : booking.status,
                  ),
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
              title: 'Brief de consultation',
              icon: Icons.assignment_outlined,
              child: ConsultationBriefCard(
                bookingId: booking.bookingId,
                onFillIn: () => AppRouter.openConsultationBrief(
                  context: context,
                  bookingId: booking.bookingId,
                ),
              ),
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

            // Expert-only: the client never sees this card, not even empty.
            if (isExpert) ...[
              _DashboardCard(
                title: 'Notes privées',
                icon: Icons.edit_note,
                child: ConsultationPrivateNotesCard(
                  bookingId: booking.bookingId,
                ),
              ),
              const SizedBox(height: 16),
            ],

            _DashboardCard(
              title: 'Documents partagés',
              icon: Icons.folder_shared,
              child: ConsultationDocumentsCard(bookingId: booking.bookingId),
            ),
            const SizedBox(height: 16),

            _DashboardCard(
              title: 'Avis',
              icon: Icons.star_border,
              child: ConsultationReviewCard(bookingId: booking.bookingId),
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
                // Vendor-agnostic video boundary: joins the session then
                // opens the live room screen.
                onPressed: () => _joinConsultation(context),
                icon: const Icon(Icons.videocam),
                label: const Text(
                  'Rejoindre la consultation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (canComplete) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _completeConsultation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MentoraColors.gold,
                    side: const BorderSide(color: MentoraColors.gold),
                  ),
                  icon: const Icon(Icons.task_alt),
                  label: const Text(
                    'Terminer la consultation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            if (canReview) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReviewScreen(
                          bookingId: booking.bookingId,
                          expertName: booking.expertName,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MentoraColors.gold,
                    side: const BorderSide(color: MentoraColors.gold),
                  ),
                  icon: const Icon(Icons.star_border),
                  label: const Text(
                    'Donner un avis',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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
