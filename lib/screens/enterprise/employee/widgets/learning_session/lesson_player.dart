import 'package:flutter/material.dart';

class LessonPlayer extends StatelessWidget {
  const LessonPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: Icon(
          Icons.play_circle_fill,
          color: Colors.orangeAccent,
          size: 72,
        ),
      ),
    );
  }
}
