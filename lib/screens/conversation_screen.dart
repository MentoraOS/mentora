import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/authentication/authentication_session.dart';
import '../application/conversation/conversation_application_service.dart';
import '../application/conversation/conversation_failure.dart';
import '../domain/conversation/conversation.dart';
import '../theme/mentora_theme.dart';
import '../widgets/conversation_input.dart';
import '../widgets/conversation_list.dart';

/// The consultation chat: live messages through Firestore streams, one
/// conversation per reservation, client and expert only. Text only —
/// every richer capability belongs to its own future wave.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.bookingId,
    required this.title,
  });

  final String bookingId;

  /// The other participant's display name.
  final String title;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late final Stream<List<Message>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = context.read<ConversationApplicationService>().watchMessages(
      widget.bookingId,
    );
  }

  Future<void> _send(String content) async {
    var message = 'Le message n’a pas pu être envoyé. Réessayez.';
    try {
      await context.read<ConversationApplicationService>().sendMessage(
        bookingId: widget.bookingId,
        content: content,
      );
      return;
    } on ConversationInvalidStateFailure {
      message = 'Cette conversation n’est plus ouverte.';
    } on ConversationNotFoundFailure {
      message = 'Cette conversation est introuvable.';
    } on ConversationFailure {
      // Keep the generic message.
    } catch (_) {
      // Keep the generic message.
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        context.read<AuthenticationSession>().currentUserId ?? '';

    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messages,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'La conversation est indisponible.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: MentoraColors.gold,
                    ),
                  );
                }
                return ConversationList(
                  messages: snapshot.data!,
                  currentUserId: currentUserId,
                );
              },
            ),
          ),
          ConversationInput(onSend: _send),
        ],
      ),
    );
  }
}
