import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/authentication/authentication_session.dart';
import '../domain/action_items/action_items_provider.dart';
import '../domain/assistant/assistant_provider.dart';
import '../domain/translation/translation_provider.dart';
import '../domain/video_session/live_consultation_room.dart';
import '../domain/video_session/video_session_provider.dart';
import '../theme/mentora_theme.dart';
import '../widgets/action_items_controller.dart';
import '../widgets/action_items_overlay.dart';
import '../widgets/assistant_controller.dart';
import '../widgets/assistant_overlay.dart';
import '../widgets/live_subtitle_overlay.dart';
import '../widgets/subtitle_controller.dart';
import '../widgets/video_track_view.dart';

/// The live consultation room: local and remote video, connection state,
/// microphone and camera toggles, and a clean exit. No chat, no vendor
/// SDK — everything goes through the Domain room contract.
class LiveConsultationScreen extends StatefulWidget {
  const LiveConsultationScreen({
    super.key,
    required this.session,
    this.subtitles,
    this.assistant,
    this.actionItems,
  });

  final VideoSessionInfo session;

  /// The already-produced translated projection to render as live
  /// subtitles; null shows none. The pipeline that starts transcription
  /// and translation wires this in its own orchestration wave — no AI
  /// logic ever lives in this screen.
  final TranslationStream? subtitles;

  /// The already-produced copilot flux; null shows none. STRICTLY
  /// expert-only: without an expert session the overlay never appears
  /// (fail closed) — the client never sees the copilot.
  final AssistantStream? assistant;

  /// The already-produced action proposals; null shows none. STRICTLY
  /// expert-only, same fail-closed rule — the client never sees the
  /// review surface.
  final ActionItemsStream? actionItems;

  @override
  State<LiveConsultationScreen> createState() => _LiveConsultationScreenState();
}

class _LiveConsultationScreenState extends State<LiveConsultationScreen> {
  LiveConsultationRoom? _room;
  StreamSubscription<void>? _subscription;
  SubtitleController? _subtitles;
  AssistantController? _assistant;
  ActionItemsController? _actionItems;
  String? _failureMessage;

  @override
  void initState() {
    super.initState();
    if (widget.subtitles case final translation?) {
      _subtitles = SubtitleController(translation: translation);
    }
    // Fail closed: no expert session means NO expert-only surface — the
    // client never sees the copilot nor the action review.
    var isExpert = false;
    try {
      isExpert = context.read<AuthenticationSession>().isExpert;
    } catch (_) {
      isExpert = false;
    }
    if (isExpert) {
      if (widget.assistant case final copilot?) {
        _assistant = AssistantController(assistant: copilot);
      }
      if (widget.actionItems case final proposals?) {
        _actionItems = ActionItemsController(actionItems: proposals);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final room = context.read<LiveConsultationRoomProvider>().createRoom(
      widget.session,
    );
    _subscription = room.changes.listen((_) {
      if (mounted) setState(() {});
    });
    setState(() => _room = room);
    await _connect(room);
  }

  Future<void> _connect(LiveConsultationRoom room) async {
    setState(() => _failureMessage = null);
    try {
      await room.connect();
    } on AuthenticationFailure {
      _fail('Accès vidéo refusé. Reconnectez-vous et réessayez.');
    } on RoomUnavailableFailure {
      _fail('La salle de consultation est indisponible.');
    } on ConnectionFailure {
      _fail('Connexion à la salle impossible. Vérifiez votre réseau.');
    } on VideoRoomFailure {
      _fail('Erreur vidéo inattendue. Réessayez plus tard.');
    } catch (_) {
      _fail('Erreur vidéo inattendue. Réessayez plus tard.');
    }
  }

  void _fail(String message) {
    if (mounted) setState(() => _failureMessage = message);
  }

  Future<void> _leave() async {
    final room = _room;
    if (room != null) {
      try {
        await room.disconnect();
      } catch (_) {
        // Leaving must always succeed from the user's point of view.
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subtitles?.dispose();
    _assistant?.dispose();
    _actionItems?.dispose();
    final room = _room;
    if (room != null) unawaited(room.dispose());
    super.dispose();
  }

  String get _statusLabel {
    if (_failureMessage != null) return 'Échec de connexion';
    return switch (_room?.connectionState) {
      null ||
      LiveConsultationConnectionState.connecting => 'Connexion…',
      LiveConsultationConnectionState.reconnecting => 'Reconnexion…',
      LiveConsultationConnectionState.disconnected => 'Déconnexion…',
      LiveConsultationConnectionState.connected =>
        _room?.remoteParticipantIdentity == null
            ? 'En attente du participant distant…'
            : 'Connecté',
    };
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    final buildTrackView = context.watch<VideoTrackViewBuilder>();
    final remoteTrack = room?.remoteVideoTrack;
    final localTrack = room?.localVideoTrack;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Consultation en direct'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: MentoraColors.navy,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              _statusLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Remote participant, full surface.
                Positioned.fill(
                  child: remoteTrack != null
                      ? buildTrackView(context, remoteTrack)
                      : _VideoPlaceholder(
                          icon: Icons.person_outline,
                          label:
                              _failureMessage ??
                              'En attente du participant distant…',
                        ),
                ),
                // Local participant, corner preview.
                Positioned(
                  right: 16,
                  bottom: 16,
                  width: 110,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: localTrack != null
                        ? buildTrackView(context, localTrack)
                        : const _VideoPlaceholder(
                            icon: Icons.videocam_off_outlined,
                            label: 'Caméra coupée',
                            dense: true,
                          ),
                  ),
                ),
                // Live subtitles: a discreet projection of the translated
                // flux, over the video, never blocking it.
                if (_subtitles case final subtitles?)
                  Positioned.fill(
                    child: LiveSubtitleOverlay(controller: subtitles),
                  ),
                // Expert-only copilot: compact, retractable, passive —
                // never a popup, never the focus.
                if (_assistant case final assistant?)
                  Positioned.fill(
                    child: AssistantOverlay(controller: assistant),
                  ),
                // Expert-only action review: the expert consults,
                // accepts, edits locally or rejects — the AI never
                // decides.
                if (_actionItems case final actionItems?)
                  Positioned.fill(
                    child: ActionItemsOverlay(controller: actionItems),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    tooltip: room?.microphoneEnabled ?? true
                        ? 'Couper le micro'
                        : 'Activer le micro',
                    icon: room?.microphoneEnabled ?? true
                        ? Icons.mic
                        : Icons.mic_off,
                    onPressed: room == null
                        ? null
                        : () => room.setMicrophoneEnabled(
                            !room.microphoneEnabled,
                          ),
                  ),
                  _ControlButton(
                    tooltip: room?.cameraEnabled ?? true
                        ? 'Couper la caméra'
                        : 'Activer la caméra',
                    icon: room?.cameraEnabled ?? true
                        ? Icons.videocam
                        : Icons.videocam_off,
                    onPressed: room == null
                        ? null
                        : () => room.setCameraEnabled(!room.cameraEnabled),
                  ),
                  _ControlButton(
                    tooltip: 'Quitter',
                    icon: Icons.call_end,
                    background: Colors.redAccent,
                    onPressed: _leave,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.background,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? Colors.white.withValues(alpha: .12),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        iconSize: 28,
        color: Colors.white,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({
    required this.icon,
    required this.label,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF10141F),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white38, size: dense ? 24 : 48),
            SizedBox(height: dense ? 6 : 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 24),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: dense ? 11 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
