import 'package:flutter/material.dart';

import '../domain/action_items/action_item.dart';
import '../theme/mentora_theme.dart';
import 'action_items_controller.dart';

/// One proposal under review: priority, title, description — and exactly
/// three actions: accept, edit, reject. Editing is inline (never a
/// popup, never the focus stolen from the consultation) and stays local.
class ActionItemCard extends StatefulWidget {
  const ActionItemCard({
    super.key,
    required this.entry,
    required this.controller,
  });

  final ReviewableActionItem entry;
  final ActionItemsController controller;

  @override
  State<ActionItemCard> createState() => _ActionItemCardState();
}

class _ActionItemCardState extends State<ActionItemCard> {
  late final TextEditingController _title = TextEditingController(
    text: widget.entry.title,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.entry.description,
  );
  bool _editing = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _saveLocalEdit() {
    widget.controller.edit(
      widget.entry.item.actionId,
      title: _title.text,
      description: _description.text,
    );
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final (label, accent) = switch (entry.item.priority) {
      ActionItemPriority.low => ('Info', Colors.white38),
      ActionItemPriority.normal => ('Action', MentoraColors.gold),
      ActionItemPriority.high => ('Prioritaire', MentoraColors.gold),
    };

    return Opacity(
      opacity: entry.accepted ? .65 : 1,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xE614192A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: entry.accepted
                ? Colors.greenAccent.withValues(alpha: .5)
                : accent.withValues(alpha: .5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .5,
                  ),
                ),
                const Spacer(),
                if (entry.accepted)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.greenAccent,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Acceptée',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (_editing) ...[
              TextField(
                controller: _title,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(isDense: true),
              ),
              TextField(
                controller: _description,
                maxLines: 2,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                decoration: const InputDecoration(isDense: true),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _saveLocalEdit,
                  child: const Text('Enregistrer'),
                ),
              ),
            ] else ...[
              Text(
                entry.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!entry.accepted)
                    _action(
                      icon: Icons.check,
                      tooltip: 'Accepter',
                      onPressed: () =>
                          widget.controller.accept(entry.item.actionId),
                    ),
                  _action(
                    icon: Icons.edit_outlined,
                    tooltip: 'Modifier',
                    onPressed: () => setState(() => _editing = true),
                  ),
                  _action(
                    icon: Icons.close,
                    tooltip: 'Rejeter',
                    onPressed: () =>
                        widget.controller.reject(entry.item.actionId),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      iconSize: 16,
      visualDensity: VisualDensity.compact,
      color: Colors.white70,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}
