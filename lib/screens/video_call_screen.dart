import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/mentora_theme.dart';
import '../config/agora_config.dart';
import 'dart:async';
import 'session_completed_screen.dart';
import '../widgets/session_progress.dart';
import '../widgets/call_header.dart';
import '../widgets/consultation_timer.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../core/routing/app_router.dart';

class VideoCallScreen extends StatefulWidget {
  final String bookingId;
  final String expertName;

  const VideoCallScreen({
    super.key,
    required this.bookingId,
    required this.expertName,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);
  String elapsedTime = '00:00';
  String currentAmount = '0 FCFA';

  RtcEngine? _engine;

  Timer? _timer;

  int _remainingSeconds = 0;
  Timer? consultationTimer;
  int secondsElapsed = 0;
  int pricePerMinute = 800;
  bool _timerStarted = false;

  int? _remoteUid;
  bool _joined = false;
  bool _muted = false;
  bool _cameraOff = false;
  bool _speakerOn = true;

  String get channelName => 'mentora${widget.bookingId}';

  @override
  void initState() {
    super.initState();
    startConsultationTimer();
    _loadBookingTimer();
    print("VIDEO CALL SCREEN OPENED");
    print("BOOKING ID = ${widget.bookingId}");
    print("CHANNEL = $channelName");

    _initAgora();
  }

  Widget _localPreview() {
    if (_engine == null || _cameraOff) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(Icons.videocam_off, color: Colors.white54, size: 34),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, color: Colors.white38, size: 70),
              SizedBox(height: 12),
              Text(
                'En attente de l’expert...',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: channelName),
      ),
    );
  }

  void startConsultationTimer() {
    consultationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        secondsElapsed++;

        final minutes = secondsElapsed ~/ 60;
        final seconds = secondsElapsed % 60;

        elapsedTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        final billedMinutes = (secondsElapsed / 60).ceil();
        final amount = billedMinutes * pricePerMinute;

        currentAmount = '${_formatMoney(amount)} FCFA';
      });
    });
  }

  @override
  void dispose() {
    consultationTimer?.cancel();
    _timer?.cancel();

    _engine!.leaveChannel();
    _engine!.release();

    super.dispose();
  }

  String _formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  void _loadBookingTimer() {
    FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .get()
        .then((doc) {
          if (!doc.exists) return;

          final data = doc.data() as Map<String, dynamic>;

          if (data['meetingEnded'] == true ||
              data['meetingStatus'] == 'ended') {
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cette session est terminée')),
              );
            }
            return;
          }

          final duration = data['duration'] ?? 60;
          final startedAt = data['startedAt'];

          if (startedAt == null) {
            startCountdown(duration);
            return;
          }

          final startTime = startedAt.toDate();
          final elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
          final remaining = (duration * 60) - elapsedSeconds;

          startCountdownFromSeconds(remaining > 0 ? remaining : 0);
        });
  }

  String get remainingTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  void startCountdown(int durationMinutes) {
    if (_timerStarted) return;

    _timerStarted = true;

    _remainingSeconds = durationMinutes * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();

        _endCall();

        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void startCountdownFromSeconds(int seconds) {
    if (_timerStarted) return;

    _timerStarted = true;
    _remainingSeconds = seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _endCall();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');

    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  Future<void> _initAgora() async {
    try {
      print('AGORA INIT START');

      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      print('CAMERA PERMISSION = $cameraStatus');
      print('MIC PERMISSION = $micStatus');

      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        print('PERMISSION REFUSED');
        return;
      }

      _engine = createAgoraRtcEngine();
      print('ENGINE CREATED');

      await _engine!.initialize(
        const RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      print('ENGINE INITIALIZED');

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            print('AGORA JOINED CHANNEL');
            setState(() => _joined = true);
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            print('REMOTE USER JOINED = $remoteUid');
            setState(() => _remoteUid = remoteUid);
          },
          onUserOffline: (connection, remoteUid, reason) {
            print('REMOTE USER LEFT = $remoteUid');
            setState(() => _remoteUid = null);
          },
          onError: (err, msg) {
            print('AGORA ERROR = $err / $msg');
          },
        ),
      );

      await _engine!.enableVideo();
      print('VIDEO ENABLED');

      await _engine!.startPreview();
      print('PREVIEW STARTED');

      print('APP ID = ${AgoraConfig.appId}');
      print('CHANNEL = $channelName');
      print("BOOKING ID = ${widget.bookingId}");
      print("CHANNEL = $channelName");

      await _engine!.joinChannel(
        token:
            '007eJxTYPhxffp7cVt2Lp7iGJ3ivgn+KnoR+RZ7ZFkbEmq2RH3et1SBwcjUIMUgzTDR0tzExMTQItUyzTI11cjIPMnEwMLUPCVRfr9NVkMgI0NByHNGRgYIBPGlGXJT80ryixIDCn0KqqKqirOL0yIiI519grNDPBgYAJZKJZg=',
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      print('JOIN CHANNEL CALLED OK');
    } catch (e) {
      print('AGORA INIT ERROR = $e');
    }
  }

  Future<void> _endCall() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: MentoraColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Terminer la consultation ?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir mettre fin à cette consultation ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Terminer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    consultationTimer?.cancel();
    _timer?.cancel();

    await _engine?.leaveChannel();
    await _engine?.release();

    if (!mounted) return;

    AppRouter.replaceWithSessionCompleted(
      context: context,
      bookingId: widget.bookingId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Consultation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            //---------------------------------------
            // Barre de progression
            //---------------------------------------
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SessionProgress(currentStep: 4),
            ),

            CallHeader(
              expertName: widget.expertName,
              expertJob: 'Expert Mentora',
              elapsedTime: elapsedTime,
              amount: currentAmount,
            ),

            const SizedBox(height: 15),

            //---------------------------------------
            // En consultation
            //---------------------------------------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.greenAccent, size: 12),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      "En consultation",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            //---------------------------------------
            // Agora Video
            //---------------------------------------
            SizedBox(
              height: 290,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(22),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(child: _remoteVideo()),

                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        width: 95,
                        height: 125,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: MentoraColors.gold.withOpacity(.8),
                            width: 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _localPreview(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            _CallControls(
              muted: _muted,
              cameraOff: _cameraOff,
              speakerOn: _speakerOn,
              onToggleMic: () {
                setState(() => _muted = !_muted);
                _engine?.muteLocalAudioStream(_muted);
              },
              onToggleCamera: () {
                setState(() => _cameraOff = !_cameraOff);
                _engine?.muteLocalVideoStream(_cameraOff);
              },
              onToggleSpeaker: () {
                setState(() => _speakerOn = !_speakerOn);
                _engine?.setEnableSpeakerphone(_speakerOn);
              },
              onNotes: () {},
              onEndCall: _endCall,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _endCall,
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Session Mentora',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    );
  }

  Widget _localVideo() {
    if (_engine == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_cameraOff) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.videocam_off, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      ),
    );
  }

  Widget _controls() {
    if (_engine == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _roundButton(
                icon: _muted ? Icons.mic_off : Icons.mic,
                label: 'Micro',
                onTap: () async {
                  setState(() => _muted = !_muted);
                  await _engine!.muteLocalAudioStream(_muted);
                },
              ),
              _roundButton(
                icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                label: 'Caméra',
                onTap: () async {
                  setState(() => _cameraOff = !_cameraOff);
                  await _engine!.muteLocalVideoStream(_cameraOff);
                },
              ),
              _roundButton(
                icon: Icons.cameraswitch,
                label: 'Changer',
                onTap: () async {
                  await _engine!.switchCamera();
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: () {
                AppRouter.replaceWithSessionCompleted(
                  context: context,
                  bookingId: widget.bookingId,
                );
              },
              icon: const Icon(Icons.call_end),
              label: const Text('Terminer la consultation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white10,
            child: Icon(icon, color: gold),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CallControls extends StatelessWidget {
  final bool muted;
  final bool cameraOff;
  final bool speakerOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onNotes;
  final VoidCallback onEndCall;

  const _CallControls({
    required this.muted,
    required this.cameraOff,
    required this.speakerOn,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleSpeaker,
    required this.onNotes,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ControlButton(
            icon: muted ? Icons.mic_off : Icons.mic,
            active: !muted,
            onTap: onToggleMic,
          ),
          _ControlButton(
            icon: cameraOff ? Icons.videocam_off : Icons.videocam,
            active: !cameraOff,
            onTap: onToggleCamera,
          ),
          _ControlButton(
            icon: speakerOn ? Icons.volume_up : Icons.volume_off,
            active: speakerOn,
            onTap: onToggleSpeaker,
          ),
          _ControlButton(icon: Icons.edit_note, active: true, onTap: onNotes),
          _ControlButton(
            icon: Icons.call_end,
            active: false,
            danger: true,
            onTap: onEndCall,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool danger;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.active,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? Colors.redAccent
        : active
        ? MentoraColors.gold
        : Colors.white54;

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: danger
              ? Colors.redAccent.withOpacity(.18)
              : Colors.white.withOpacity(.10),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(.45)),
        ),
        child: Icon(icon, color: color, size: 25),
      ),
    );
  }
}
