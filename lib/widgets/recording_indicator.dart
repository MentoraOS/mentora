import 'dart:async';

import 'package:flutter/material.dart';

import '../application/recording/recording_orchestrator.dart';
import '../domain/recording/consultation_recording.dart';

/// The REC indicator — extremely discreet, trustworthy, never masking
/// the consultation.
///
/// GOVERNANCE: the only authorized chain is RecordingSession ->
/// RecordingOrchestrator -> RecordingIndicator. The indicator follows
/// ONLY the relayed RecordingSession status and renders exactly:
/// nothing (NOT_STARTED, COMPLETED), 'REC...' (STARTING), a red dot
/// with 'REC' (RECORDING), 'Fin...' (STOPPING) and 'REC indisponible'
/// (FAILED). No provider, no vendor, no persistence, no media.
class RecordingIndicator extends StatefulWidget {
  const RecordingIndicator({super.key, required this.orchestrator});

  final RecordingOrchestrator orchestrator;

  @override
  State<RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator> {
  StreamSubscription<ConsultationRecording>? _subscription;
  RecordingStatus? _status;

  @override
  void initState() {
    super.initState();
    _status = widget.orchestrator.session?.recording.status;
    _subscription = widget.orchestrator.updates.listen(
      (recording) {
        if (mounted) setState(() => _status = recording.status);
      },
      // Fail closed: a relayed failure shows the unavailable state.
      onError: (Object _) {
        if (mounted) setState(() => _status = RecordingStatus.failed);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (label, showDot) = switch (_status) {
      null ||
      RecordingStatus.notStarted ||
      RecordingStatus.completed => (null, false),
      RecordingStatus.starting => ('REC...', false),
      RecordingStatus.recording => ('REC', true),
      RecordingStatus.stopping => ('Fin...', false),
      RecordingStatus.failed => ('REC indisponible', false),
    };
    if (label == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xB014192A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}
