import 'package:flutter/material.dart';

class LessonAIAssistant extends StatelessWidget {
  const LessonAIAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text(
                'Mentora AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Pose une question sur cette leçon, demande un résumé ou un exemple pratique.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Demander à Mentora AI...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AIPromptChip(label: 'Résume la leçon'),
              _AIPromptChip(label: 'Explique simplement'),
              _AIPromptChip(label: 'Donne un exemple'),
              _AIPromptChip(label: 'Génère un quiz'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AIPromptChip extends StatelessWidget {
  final String label;

  const _AIPromptChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white10,
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
