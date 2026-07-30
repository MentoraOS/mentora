import 'dart:async';
import 'package:flutter/material.dart';
import 'booking_success_screen.dart';
import '../core/routing/app_router.dart';

class PaymentSuccessAnimation extends StatefulWidget {
  final String bookingId;
  final String expertName;
  final String selectedDate;
  final String selectedTime;
  final String aiSummary;

  const PaymentSuccessAnimation({
    super.key,
    required this.bookingId,
    required this.expertName,
    required this.selectedDate,
    required this.selectedTime,
    required this.aiSummary,
  });

  @override
  State<PaymentSuccessAnimation> createState() =>
      _PaymentSuccessAnimationState();
}

class _PaymentSuccessAnimationState extends State<PaymentSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    controller.forward();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      AppRouter.replaceWithBookingSuccess(
        context: context,
        bookingId: widget.bookingId,
        expertName: widget.expertName,
        selectedDate: widget.selectedDate,
        selectedTime: widget.selectedTime,
        aiSummary: widget.aiSummary,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  static const gold = Color(0xFFF5A400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: controller, curve: Curves.elasticOut),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 140,
                height: 140,

                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),

                child: const Icon(Icons.check, color: Colors.white, size: 80),
              ),

              const SizedBox(height: 30),

              const Text(
                "Paiement confirmé",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),

              const Text(
                "Votre consultation est réservée.",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 40),

              const CircularProgressIndicator(color: gold),

              const SizedBox(height: 18),

              const Text("Préparation de votre espace..."),
            ],
          ),
        ),
      ),
    );
  }
}
