import 'package:flutter/material.dart';

import '../theme/mentora_theme.dart';
import 'assistant_controller.dart';
import 'assistant_suggestion_card.dart';

/// The copilot overlay — compact, discreet, retractable, expert-only.
///
/// Pure presentation of the controller's suggestions: it never opens a
/// popup, never takes focus, never interrupts the consultation — the
/// video keeps running underneath and only the small header chip is
/// tappable (to retract or expand). The [alignment] makes it movable
/// later without a redesign; future copilot surfaces (checklists,
/// reminders, resources, interim syntheses) are new card kinds here, not
/// new architecture.
class AssistantOverlay extends StatelessWidget {
  const AssistantOverlay({
    super.key,
    required this.controller,
    this.alignment = Alignment.topRight,
  });

  final AssistantController controller;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _headerChip(),
                  if (!controller.collapsed)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Column(
                        key: ValueKey(
                          controller.visible
                              .map((suggestion) => suggestion.suggestionId)
                              .join('|'),
                        ),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Passive by design: the suggestions themselves
                          // are not interactive.
                          for (final suggestion in controller.visible)
                            IgnorePointer(
                              child: AssistantSuggestionCard(
                                suggestion: suggestion,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _headerChip() {
    return Material(
      color: const Color(0xE614192A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: controller.toggleCollapsed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.assistant_outlined,
                size: 14,
                color: MentoraColors.gold,
              ),
              const SizedBox(width: 6),
              const Text(
                'Copilote',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                controller.collapsed
                    ? Icons.expand_more
                    : Icons.expand_less,
                size: 14,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
