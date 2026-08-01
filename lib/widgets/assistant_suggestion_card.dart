import 'package:flutter/material.dart';

import '../domain/assistant/assistant_suggestion.dart';
import '../theme/mentora_theme.dart';

/// One copilot suggestion: priority, title, content — nothing else.
///
/// The three priorities are visually distinct through calm accents (no
/// aggressive color coding): LOW is muted, NORMAL carries the gold
/// accent, HIGH carries a filled gold marker.
class AssistantSuggestionCard extends StatelessWidget {
  const AssistantSuggestionCard({super.key, required this.suggestion});

  final AssistantSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final (label, accent, filled) = switch (suggestion.priority) {
      AssistantPriority.low => ('Info', Colors.white38, false),
      AssistantPriority.normal => ('Suggestion', MentoraColors.gold, false),
      AssistantPriority.high => ('Important', MentoraColors.gold, true),
    };

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xE614192A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: filled ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accent),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: filled ? MentoraColors.navy : accent,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            suggestion.content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
