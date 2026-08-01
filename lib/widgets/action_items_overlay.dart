import 'package:flutter/material.dart';

import '../theme/mentora_theme.dart';
import 'action_item_card.dart';
import 'action_items_controller.dart';

/// The action-items review overlay — the first human/AI collaboration
/// surface: compact, discreet, retractable, expert-only.
///
/// Pure presentation of the controller's proposals with the expert's
/// three decisions per card. It never blocks the video (hits pass
/// through outside its bounds), never takes focus, never interrupts the
/// consultation. The [alignment] and width constraints make it ready to
/// become a side panel later without a redesign; future evolutions
/// (definitive validation, task conversion, calendar, CRM, tracking)
/// are new decisions behind the same surface.
class ActionItemsOverlay extends StatelessWidget {
  const ActionItemsOverlay({
    super.key,
    required this.controller,
    this.alignment = Alignment.bottomLeft,
  });

  final ActionItemsController controller;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280, maxHeight: 340),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerChip(),
                  if (!controller.collapsed && controller.items.isNotEmpty)
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final entry in controller.items)
                              ActionItemCard(
                                key: ValueKey(entry.item.actionId),
                                entry: entry,
                                controller: controller,
                              ),
                          ],
                        ),
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
                Icons.checklist_outlined,
                size: 14,
                color: MentoraColors.gold,
              ),
              const SizedBox(width: 6),
              const Text(
                'Actions proposées',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                controller.collapsed
                    ? Icons.expand_less
                    : Icons.expand_more,
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
