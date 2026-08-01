import 'package:flutter/material.dart';

import '../domain/conversation/conversation.dart';
import 'conversation_bubble.dart';

/// The live message list, newest pinned to the bottom.
///
/// Rendered reversed so new messages are visible instantly without any
/// manual scrolling — the WhatsApp behaviour.
class ConversationList extends StatelessWidget {
  const ConversationList({
    super.key,
    required this.messages,
    required this.currentUserId,
  });

  final List<Message> messages;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Aucun message. Écrivez le premier !',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return ConversationBubble(
          message: message,
          isMine: message.senderId == currentUserId,
        );
      },
    );
  }
}
