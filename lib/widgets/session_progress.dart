import 'package:flutter/material.dart';
import '../theme/mentora_theme.dart';

class SessionProgress extends StatelessWidget {
  final int currentStep;

  const SessionProgress({super.key, required this.currentStep});

  static const List<String> steps = [
    'Réservation',
    'Préparation',
    'Paiement',
    'Consultation',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progression',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: List.generate(steps.length, (index) {
              final step = index + 1;
              final isDone = step < currentStep;
              final isActive = step == currentStep;
              final isLast = index == steps.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    _StepCircle(isDone: isDone, isActive: isActive, step: step),

                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: step < currentStep
                                ? MentoraColors.gold
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 10),

          Row(
            children: List.generate(steps.length, (index) {
              final step = index + 1;
              final isActive = step == currentStep;
              final isDone = step < currentStep;

              return Expanded(
                child: Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive || isDone ? Colors.white : Colors.white54,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool isDone;
  final bool isActive;
  final int step;

  const _StepCircle({
    required this.isDone,
    required this.isActive,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: isDone || isActive ? MentoraColors.gold : Colors.white24,
      child: isDone
          ? const Icon(Icons.check, size: 16, color: MentoraColors.navy)
          : Text(
              '$step',
              style: TextStyle(
                color: isActive ? MentoraColors.navy : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
