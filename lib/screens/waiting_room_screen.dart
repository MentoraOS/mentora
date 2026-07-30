import 'dart:async';
import 'package:flutter/material.dart';

import 'video_call_screen.dart';
import '../widgets/session_progress.dart';
import '../theme/mentora_theme.dart';
import 'joining_consultation_screen.dart';
import '../core/routing/app_router.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String bookingId;
  final String expertName;
  final String selectedDate;
  final String selectedTime;
  final String aiSummary;

  const WaitingRoomScreen({
    super.key,
    required this.bookingId,
    required this.expertName,
    required this.selectedDate,
    required this.selectedTime,
    required this.aiSummary,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  bool roomReady = false;
  bool expertConnected = false;
  bool canJoinCall = false;
  bool agoraReady = false;
  bool isPreparingAgora = true;

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  @override
  void initState() {
    super.initState();

    prepareAgora();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => roomReady = true);
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      setState(() => expertConnected = true);
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      setState(() => canJoinCall = true);
    });
  }

  void joinConsultation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _JoiningCallDialog(),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pop(context);

      AppRouter.openVideoCall(
        context: context,
        bookingId: widget.bookingId,
        expertName: widget.expertName,
      );
    });
  }

  Future<void> prepareAgora() async {
    print("prepareAgora lancé");

    setState(() {
      isPreparingAgora = true;
      agoraReady = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    print("Agora prête");

    setState(() {
      isPreparingAgora = false;
      agoraReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        title: const Text('Salle d’attente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _WaitingHeader(
              expertName: widget.expertName,
              selectedDate: widget.selectedDate,
              selectedTime: widget.selectedTime,
              expertConnected: expertConnected,
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 16),
            const SessionProgress(currentStep: 4),
            const SizedBox(height: 16),

            _AiBriefCard(aiSummary: widget.aiSummary),

            const SizedBox(height: 16),

            _TechChecklistCard(),

            const SizedBox(height: 16),

            _AgoraPreparationCard(
              isPreparing: isPreparingAgora,
              isReady: agoraReady,
            ),

            const SizedBox(height: 16),

            _Card(
              title: 'Préparation',
              child: const Column(
                children: [
                  _CheckRow(text: 'Créneau confirmé'),
                  _CheckRow(text: 'Résumé IA généré'),
                  _CheckRow(text: 'Paiement confirmé'),
                  _CheckRow(text: 'Expert informé'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            _Card(
              title: 'Conseils avant l’appel',
              child: const Column(
                children: [
                  _TipRow(text: 'Placez-vous dans un endroit calme'),
                  _TipRow(text: 'Préparez vos questions'),
                  _TipRow(text: 'Vérifiez votre connexion'),
                  _TipRow(text: 'Utilisez un casque si possible'),
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: agoraReady && canJoinCall ? joinConsultation : null,
                icon: Icon(canJoinCall ? Icons.video_call : Icons.lock_clock),
                label: Text(
                  canJoinCall
                      ? 'Entrer dans la salle'
                      : 'Disponible à l’heure du rendez-vous',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;

  const _CheckRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFF5A400), size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;

  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFFF5A400), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

class _WaitingHeader extends StatelessWidget {
  final String expertName;
  final String selectedDate;
  final String selectedTime;
  final bool expertConnected;

  const _WaitingHeader({
    required this.expertName,
    required this.selectedDate,
    required this.selectedTime,
    required this.expertConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: MentoraShadows.soft,
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: MentoraColors.gold,
            child: Icon(Icons.person, color: MentoraColors.navy, size: 42),
          ),

          const SizedBox(height: 14),

          Text(
            expertName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 6),

          Text(
            '$selectedDate • $selectedTime',
            style: const TextStyle(
              color: MentoraColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: expertConnected
                  ? Colors.green.withOpacity(.12)
                  : MentoraColors.gold.withOpacity(.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: expertConnected
                      ? Colors.greenAccent
                      : MentoraColors.gold,
                ),
                const SizedBox(width: 8),
                Text(
                  expertConnected
                      ? 'Expert connecté'
                      : 'En attente de l’expert',
                  style: TextStyle(
                    color: expertConnected
                        ? Colors.greenAccent
                        : MentoraColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBriefCard extends StatelessWidget {
  final String aiSummary;

  const _AiBriefCard({required this.aiSummary});

  @override
  Widget build(BuildContext context) {
    final hasSummary = aiSummary.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: MentoraShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: MentoraColors.gold),
              SizedBox(width: 10),
              Text(
                'Mentora AI Brief',
                style: TextStyle(
                  color: MentoraColors.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            hasSummary
                ? aiSummary
                : 'Aucun résumé IA disponible pour cette consultation.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: MentoraColors.gold.withOpacity(.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.lightbulb_outline,
                  color: MentoraColors.gold,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Conseil : préparez vos questions principales avant le début de l’appel.',
                    style: TextStyle(
                      color: MentoraColors.gold,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChecklistCard extends StatelessWidget {
  const _TechChecklistCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: MentoraShadows.soft,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: MentoraColors.gold),
              SizedBox(width: 10),
              Text(
                'Vérification technique',
                style: TextStyle(
                  color: MentoraColors.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          _TechCheckRow(icon: Icons.videocam, title: 'Caméra', status: 'Prête'),

          _TechCheckRow(icon: Icons.mic, title: 'Micro', status: 'Prêt'),

          _TechCheckRow(icon: Icons.wifi, title: 'Connexion', status: 'Stable'),

          _TechCheckRow(
            icon: Icons.volume_up,
            title: 'Audio',
            status: 'Activé',
          ),
        ],
      ),
    );
  }
}

class _TechCheckRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;

  const _TechCheckRow({
    required this.icon,
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.greenAccent.withOpacity(.14),
            child: Icon(icon, color: Colors.greenAccent, size: 20),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgoraPreparationCard extends StatelessWidget {
  final bool isPreparing;
  final bool isReady;

  const _AgoraPreparationCard({
    required this.isPreparing,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: MentoraShadows.soft,
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle : Icons.sync,
            color: isReady ? Colors.greenAccent : MentoraColors.gold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isReady
                  ? 'Salle vidéo prête'
                  : 'Préparation de la salle vidéo...',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isPreparing)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: MentoraColors.gold,
              ),
            ),
        ],
      ),
    );
  }
}

class _JoiningCallDialog extends StatelessWidget {
  const _JoiningCallDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: const Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_call, color: MentoraColors.gold, size: 64),
            SizedBox(height: 22),
            Text(
              'Ouverture de la consultation',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Préparation de la vidéo et de l’audio...',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 26),
            CircularProgressIndicator(color: MentoraColors.gold),
          ],
        ),
      ),
    );
  }
}
