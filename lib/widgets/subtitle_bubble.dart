import 'package:flutter/material.dart';

import '../domain/translation/translated_transcript_chunk.dart';
import '../theme/mentora_theme.dart';

/// One subtitle: ALWAYS the original and its translation together, each
/// in its own color — original in the primary gold, translation in
/// white. The two are never mixed. Language codes come from the chunk
/// itself; nothing is hard-coded.
class SubtitleBubble extends StatelessWidget {
  const SubtitleBubble({super.key, required this.chunk});

  final TranslatedTranscriptChunk chunk;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _line(
            language: chunk.sourceLanguage,
            text: chunk.originalText,
            color: MentoraColors.gold,
          ),
          const SizedBox(height: 2),
          _line(
            language: chunk.targetLanguage,
            text: chunk.translatedText,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _line({
    required String language,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          language.toUpperCase(),
          style: TextStyle(
            color: color.withValues(alpha: .6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 14, height: 1.3),
          ),
        ),
      ],
    );
  }
}
