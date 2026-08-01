import 'package:flutter/material.dart';

import '../domain/conversation/conversation.dart';
import '../theme/mentora_theme.dart';

/// One text message bubble: sender's own messages on the right in gold,
/// the other participant's on the left, each with its timestamp.
class ConversationBubble extends StatelessWidget {
  const ConversationBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isMine
              ? MentoraColors.gold
              : Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMine ? MentoraColors.navy : Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _timestamp(message.createdAt),
              style: TextStyle(
                color: isMine
                    ? MentoraColors.navy.withValues(alpha: .6)
                    : Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _timestamp(DateTime? instant) {
    if (instant == null) return 'Envoi…';
    final local = instant.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
