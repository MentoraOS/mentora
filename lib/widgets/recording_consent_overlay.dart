import 'package:flutter/material.dart';

import '../theme/mentora_theme.dart';
import 'recording_consent_card.dart';
import 'recording_consent_controller.dart';

/// The recording consent overlay — compact, discreet, retractable,
/// trustworthy.
///
/// It shows exactly three things: the expert's consent, the client's
/// consent and the pair's outcome. It never blocks the video (hits pass
/// through outside its bounds), never takes focus, never interrupts the
/// consultation and never pressures anyone: a refusal is respected
/// immediately. The [alignment] makes it ready to become a side panel
/// later; the REC indicator, real start, pause/stop, replay and
/// compliance surfaces arrive as future evolutions of this same
/// component, without a redesign.
class RecordingConsentOverlay extends StatelessWidget {
  const RecordingConsentOverlay({
    super.key,
    required this.controller,
    this.alignment = Alignment.topLeft,
  });

  final RecordingConsentController controller;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerChip(),
                  if (!controller.collapsed) ...[
                    RecordingConsentCard(
                      label: 'Consentement Expert',
                      decision: controller.expertDecision,
                      onAccept: controller.acceptExpert,
                      onRefuse: controller.refuseExpert,
                    ),
                    RecordingConsentCard(
                      label: 'Consentement Client',
                      decision: controller.clientDecision,
                      onAccept: controller.acceptClient,
                      onRefuse: controller.refuseClient,
                    ),
                    _outcome(),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _outcome() {
    final (label, color) = switch (controller.outcome) {
      ConsentOutcome.waiting => (
        'En attente des consentements',
        Colors.white54,
      ),
      ConsentOutcome.authorized => (
        'Enregistrement autorisé',
        Colors.greenAccent,
      ),
      ConsentOutcome.unavailable => (
        'Enregistrement indisponible',
        Colors.white70,
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 8),
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

  Widget _headerChip() {
    return Material(
      color: const Color(0xE614192A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: controller.toggleCollapsed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fiber_smart_record_outlined,
                size: 14,
                color: MentoraColors.gold,
              ),
              const SizedBox(width: 6),
              const Text(
                'Enregistrement',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                controller.collapsed
                    ? Icons.expand_more
                    : Icons.expand_less,
                size: 14,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
