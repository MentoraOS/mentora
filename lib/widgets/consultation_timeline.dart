import 'package:flutter/material.dart';

import '../domain/booking/booking_overview.dart';
import '../theme/mentora_theme.dart';

/// Consultation progress timeline.
///
/// Pure projection of the reservation status — no clock, no writes, no new
/// business logic. Steps are derived from the persisted lifecycle only; the
/// remaining-time indicator is a placeholder until the scheduled-trigger
/// milestone exists.
class ConsultationTimeline extends StatelessWidget {
  const ConsultationTimeline({super.key, required this.booking});

  final BookingOverview booking;

  static const List<String> _stepLabels = [
    'Réservation créée',
    'Paiement confirmé',
    'Consultation confirmée',
    'Consultation à venir',
    'Consultation terminée',
    'Avis',
  ];

  /// How many steps the persisted status has completed.
  static int _completedSteps(String status) {
    switch (status) {
      case 'pending_payment':
      case 'pending':
        return 1;
      case 'confirmed':
      case 'paid':
        return 3;
      case 'completed':
        return 5;
      default:
        return 0;
    }
  }

  static String nextStepFor(String status) {
    switch (status) {
      case 'pending_payment':
      case 'pending':
        return 'Payer la réservation';
      case 'confirmed':
      case 'paid':
        return 'Consultation à venir';
      case 'completed':
        return 'Donner un avis';
      case 'cancelled':
        return 'Aucune — réservation annulée';
      default:
        return 'Statut inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cancelled = booking.status == 'cancelled';
    final completed = _completedSteps(booking.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < _stepLabels.length; index++)
          _TimelineStep(
            label: _stepLabels[index],
            done: !cancelled && index < completed,
            current: !cancelled && index == completed,
            last: index == _stepLabels.length - 1,
          ),
        const SizedBox(height: 12),
        _SummaryRow(
          icon: Icons.flag,
          label: 'Prochaine étape',
          value: nextStepFor(booking.status),
        ),
        const SizedBox(height: 8),
        const _SummaryRow(
          icon: Icons.hourglass_empty,
          label: 'Temps restant',
          // Placeholder until the scheduled-trigger milestone; no device
          // countdown is ever authoritative.
          value: 'Bientôt disponible',
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.done,
    required this.current,
    required this.last,
  });

  final String label;
  final bool done;
  final bool current;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? Colors.greenAccent
        : current
        ? MentoraColors.gold
        : Colors.white24;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Icon(
                done
                    ? Icons.check_circle
                    : current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: color,
                size: 20,
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: done ? Colors.greenAccent : Colors.white12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 18),
            child: Text(
              label,
              style: TextStyle(
                color: done || current ? Colors.white : Colors.white38,
                fontWeight: current ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: MentoraColors.gold, size: 16),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: MentoraColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
