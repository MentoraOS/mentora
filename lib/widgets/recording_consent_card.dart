import 'package:flutter/material.dart';

import '../theme/mentora_theme.dart';
import 'recording_consent_controller.dart';

/// One participant's consent row: who, their status, and — while pending
/// — exactly two free choices: accept or refuse. The wording and the
/// visuals never push toward either answer.
class RecordingConsentCard extends StatelessWidget {
  const RecordingConsentCard({
    super.key,
    required this.label,
    required this.decision,
    required this.onAccept,
    required this.onRefuse,
  });

  final String label;
  final ConsentDecision decision;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = switch (decision) {
      ConsentDecision.pending => ('En attente', Colors.white54),
      ConsentDecision.accepted => ('Accepté', Colors.greenAccent),
      ConsentDecision.refused => ('Refusé', Colors.white70),
    };

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE614192A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            statusLabel,
            style: TextStyle(color: statusColor, fontSize: 11),
          ),
          if (decision == ConsentDecision.pending) ...[
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Accepter — $label',
              iconSize: 16,
              visualDensity: VisualDensity.compact,
              color: MentoraColors.gold,
              onPressed: onAccept,
              icon: const Icon(Icons.check),
            ),
            IconButton(
              tooltip: 'Refuser — $label',
              iconSize: 16,
              visualDensity: VisualDensity.compact,
              color: Colors.white70,
              onPressed: onRefuse,
              icon: const Icon(Icons.close),
            ),
          ],
        ],
      ),
    );
  }
}
