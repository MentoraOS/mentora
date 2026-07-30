import 'package:flutter/material.dart';

class LessonHeader extends StatelessWidget {
  const LessonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leadership professionnel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Leçon 03 · Prise de décision',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
      ],
    );
  }
}
