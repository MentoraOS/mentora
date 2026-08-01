import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/recording/consultation_recording.dart';
import '../domain/recording/recording_provider.dart';

/// One participant's consent decision. Nothing else.
enum ConsentDecision { pending, accepted, refused }

/// The global consent outcome of the pair.
enum ConsentOutcome { waiting, authorized, unavailable }

/// Presentation-only controller of the recording consent.
///
/// GOVERNANCE: the only authorized chain is RecordingSession ->
/// RecordingConsentController -> RecordingConsentOverlay. Consent is a
/// RIGHT, never a formality: each participant decides independently and
/// freely, a refusal is a normal answer respected IMMEDIATELY and
/// FINALLY (no renegotiation, no automatic re-ask, no pressure — a
/// decision cannot be flipped here). Nothing is persisted, no media
/// exists, no recording is started by this wave: the real start and the
/// cross-device synchronization arrive with their own waves. When a
/// [RecordingSession] exists, the controller follows ITS updates only.
final class RecordingConsentController extends ChangeNotifier {
  RecordingConsentController({RecordingSession? session}) {
    if (session != null) {
      _subscription = session.updates.listen(
        (recording) {
          _recordingStatus = recording.status;
          notifyListeners();
        },
        // Fail closed: an errored lifecycle shows nothing invented.
        onError: (Object _) {},
      );
    }
  }

  ConsentDecision _client = ConsentDecision.pending;
  ConsentDecision _expert = ConsentDecision.pending;
  RecordingStatus? _recordingStatus;
  StreamSubscription<ConsultationRecording>? _subscription;
  bool _collapsed = false;

  ConsentDecision get clientDecision => _client;
  ConsentDecision get expertDecision => _expert;

  /// The followed recording lifecycle, when a session exists.
  RecordingStatus? get recordingStatus => _recordingStatus;

  /// Whether the overlay is retracted to its compact chip.
  bool get collapsed => _collapsed;

  /// The pair's outcome: both accepted authorizes; ONE refusal makes the
  /// recording unavailable — immediately and without negotiation.
  ConsentOutcome get outcome {
    if (_client == ConsentDecision.refused ||
        _expert == ConsentDecision.refused) {
      return ConsentOutcome.unavailable;
    }
    if (_client == ConsentDecision.accepted &&
        _expert == ConsentDecision.accepted) {
      return ConsentOutcome.authorized;
    }
    return ConsentOutcome.waiting;
  }

  void acceptClient() => _decideClient(ConsentDecision.accepted);

  void refuseClient() => _decideClient(ConsentDecision.refused);

  void acceptExpert() => _decideExpert(ConsentDecision.accepted);

  void refuseExpert() => _decideExpert(ConsentDecision.refused);

  void toggleCollapsed() {
    _collapsed = !_collapsed;
    notifyListeners();
  }

  void _decideClient(ConsentDecision decision) {
    // A decision is free and final: no flip-flop, no pressure.
    if (_client != ConsentDecision.pending) return;
    _client = decision;
    notifyListeners();
  }

  void _decideExpert(ConsentDecision decision) {
    if (_expert != ConsentDecision.pending) return;
    _expert = decision;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
