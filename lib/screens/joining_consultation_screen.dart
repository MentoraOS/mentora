import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/mentora_theme.dart';
import 'video_call_screen.dart';
import '../core/routing/app_router.dart';

class JoiningConsultationScreen extends StatefulWidget {
  final String bookingId;
  final String expertName;

  const JoiningConsultationScreen({
    super.key,
    required this.bookingId,
    required this.expertName,
  });

  @override
  State<JoiningConsultationScreen> createState() =>
      _JoiningConsultationScreenState();
}

class _JoiningConsultationScreenState extends State<JoiningConsultationScreen> {
  int step = 0;

  final List<String> steps = const [
    'Préparation de la consultation...',
    'Connexion sécurisée...',
    'Activation caméra...',
    'Activation micro...',
    'Connexion avec l’expert...',
  ];

  @override
  void initState() {
    super.initState();
    _startTransition();
  }

  Future<void> _startTransition() async {
    for (int i = 0; i < steps.length; i++) {
      if (!mounted) return;
      setState(() => step = i);
      await Future.delayed(const Duration(milliseconds: 650));
    }

    if (!mounted) return;

    AppRouter.replaceWithVideoCall(
      context: context,
      bookingId: widget.bookingId,
      expertName: widget.expertName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / steps.length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF061A3D), Color(0xFF0B2E80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: MentoraColors.gold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: MentoraColors.gold.withOpacity(.35),
                      blurRadius: 35,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.video_call,
                  color: MentoraColors.navy,
                  size: 58,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Ouverture de votre consultation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                steps[step],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 34),

              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: MentoraColors.gold,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: MentoraColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              const Text(
                'Connexion sécurisée par Mentora',
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
