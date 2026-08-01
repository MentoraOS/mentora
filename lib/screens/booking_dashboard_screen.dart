import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../application/booking/booking_cancellation_application_service.dart';
import '../application/booking/booking_cancellation_failure.dart';
import '../application/booking/booking_dashboard_application_service.dart';
import '../application/notification/booking_notification_application_service.dart';
import '../domain/booking/booking_overview.dart';
import '../core/routing/app_router.dart';
import '../theme/mentora_theme.dart';

/// Booking Dashboard: the reference screen for a user's reservations.
///
/// Pure projection of existing Booking facts, streamed live so every
/// payment, cancellation or reschedule refreshes the sections immediately.
/// Device time is used ONLY to organize the display into sections; it never
/// determines any reservation truth.
class BookingDashboardScreen extends StatelessWidget {
  const BookingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Mes réservations'),
      ),
      body: StreamBuilder<List<BookingOverview>>(
        stream: context
            .read<BookingDashboardApplicationService>()
            .watchMyBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger vos réservations. '
                  'Réessayez plus tard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: MentoraColors.gold),
            );
          }

          final bookings = snapshot.data!;
          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                'Aucune réservation pour le moment.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final sections = _sectionize(bookings);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (final section in sections)
                if (section.bookings.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Text(
                      section.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...section.bookings.map(
                    (booking) => _BookingCard(booking: booking),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          );
        },
      ),
    );
  }

  List<_Section> _sectionize(List<BookingOverview> bookings) {
    // Display-only sectioning: device date picks which section a card lands
    // in, exactly like picking a visible calendar page.
    final now = DateTime.now();
    final today =
        '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final todayList = <BookingOverview>[];
    final upcoming = <BookingOverview>[];
    final completed = <BookingOverview>[];
    final cancelled = <BookingOverview>[];

    for (final booking in bookings) {
      switch (booking.status) {
        case 'cancelled':
          cancelled.add(booking);
        case 'completed':
          completed.add(booking);
        default:
          if (booking.bookingDate == today) {
            todayList.add(booking);
          } else {
            upcoming.add(booking);
          }
      }
    }

    int ascending(BookingOverview a, BookingOverview b) {
      return '${a.bookingDate} ${a.bookingTime}'.compareTo(
        '${b.bookingDate} ${b.bookingTime}',
      );
    }

    todayList.sort(ascending);
    upcoming.sort(ascending);
    completed.sort((a, b) => ascending(b, a));
    cancelled.sort((a, b) => ascending(b, a));

    return [
      _Section('Aujourd’hui', todayList),
      _Section('À venir', upcoming),
      _Section('Terminées', completed),
      _Section('Annulées', cancelled),
    ];
  }
}

final class _Section {
  const _Section(this.title, this.bookings);

  final String title;
  final List<BookingOverview> bookings;
}

final class _StatusBadge {
  const _StatusBadge(this.label, this.color);

  final String label;
  final Color color;
}

_StatusBadge _badgeFor(String status) {
  switch (status) {
    case 'pending_payment':
      return const _StatusBadge('Paiement en attente', Colors.orangeAccent);
    case 'pending':
      return const _StatusBadge('En attente', Colors.orangeAccent);
    case 'confirmed':
      return const _StatusBadge('Confirmée', Colors.greenAccent);
    case 'paid':
      return const _StatusBadge('Payée', Colors.greenAccent);
    case 'completed':
      return const _StatusBadge('Terminée', Colors.lightBlueAccent);
    case 'cancelled':
      return const _StatusBadge('Annulée', Colors.redAccent);
    default:
      return const _StatusBadge('Statut inconnu', Colors.grey);
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final BookingOverview booking;

  static final NumberFormat _money = NumberFormat('#,##0', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    final badge = _badgeFor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              const CircleAvatar(
                radius: 24,
                backgroundColor: MentoraColors.gold,
                child: Icon(Icons.person, color: MentoraColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.expertName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.bookingDate} • ${booking.bookingTime}',
                      style: const TextStyle(color: MentoraColors.gold),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badge.color),
                ),
                child: Text(
                  badge.label,
                  style: TextStyle(
                    color: badge.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (booking.durationMinutes case final duration?)
                _InfoChip(icon: Icons.schedule, label: '$duration min'),
              if (booking.amountMinor case final amount?)
                _InfoChip(
                  icon: Icons.payments,
                  label:
                      '${_money.format(amount)} '
                      '${booking.currency ?? 'XOF'}',
                ),
              if (booking.expertTimezone case final timezone?)
                _InfoChip(icon: Icons.public, label: timezone),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 8, children: _actions(context)),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    switch (booking.status) {
      case 'pending_payment':
        return [
          if (booking.amountMinor != null && booking.currency != null)
            _ActionButton(
              icon: Icons.lock,
              label: 'Payer',
              filled: true,
              onPressed: () => AppRouter.openPayment(
                context: context,
                bookingId: booking.bookingId,
                expertId: booking.expertId,
                expertName: booking.expertName,
                selectedDate: booking.bookingDate,
                selectedTime: booking.bookingTime,
                aiSummary: booking.aiSummary,
                amountMinor: booking.amountMinor!,
                currency: booking.currency!,
              ),
            ),
        ];
      case 'confirmed':
        return [
          _detailsButton(context),
          _ActionButton(
            icon: Icons.event_repeat,
            label: 'Reprogrammer',
            onPressed: () => AppRouter.openRescheduleBooking(
              context: context,
              bookingId: booking.bookingId,
              booking: booking.raw,
            ),
          ),
          _ActionButton(
            icon: Icons.cancel,
            label: 'Annuler',
            onPressed: () => _cancel(context),
          ),
        ];
      case 'paid':
      case 'cancelled':
        return [_detailsButton(context)];
      case 'completed':
        return [
          _detailsButton(context),
          _ActionButton(
            icon: Icons.star_border,
            label: 'Donner un avis',
            onPressed: () {
              // Review flow placeholder — its own future milestone.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Les avis arrivent bientôt.')),
              );
            },
          ),
        ];
      default:
        return const [];
    }
  }

  Widget _detailsButton(BuildContext context) {
    return _ActionButton(
      icon: Icons.info_outline,
      label: 'Voir les détails',
      onPressed: () => AppRouter.openBookingDetail(
        context: context,
        bookingId: booking.bookingId,
        booking: booking.raw,
      ),
    );
  }

  Future<void> _cancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: const Text(
          'Cette action est définitive. La réservation sera annulée pour '
          'vous et pour l’expert.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmer l’annulation'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<BookingCancellationApplicationService>().cancel(
        booking.bookingId,
      );
    } on BookingCancellationFailure {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L’annulation a échoué. Réessayez plus tard.'),
        ),
      );
      return;
    }

    // Best-effort lifecycle notification; the live stream refreshes the
    // dashboard on its own.
    if (context.mounted) {
      await context
          .read<BookingNotificationApplicationService>()
          .notifyBookingCancelled(
            bookingId: booking.bookingId,
            expertId: booking.expertId,
            expertName: booking.expertName,
            displayDate: booking.bookingDate,
            displayTime: booking.bookingTime,
          );
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Réservation annulée')));
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 15),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: MentoraColors.gold,
        side: const BorderSide(color: MentoraColors.gold),
      ),
    );
  }
}
