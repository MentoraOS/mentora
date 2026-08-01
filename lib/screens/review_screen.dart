import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/review/review_application_service.dart';
import '../application/review/review_failure.dart';
import '../theme/mentora_theme.dart';

/// Publish the client's single review of a completed consultation:
/// pick 1..5 stars, optionally comment, publish, return. Nothing else.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.expertName,
  });

  final String bookingId;
  final String expertName;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _comment = TextEditingController();
  int _rating = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_rating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une note de 1 à 5 étoiles.')),
      );
      return;
    }

    setState(() => _submitting = true);
    var message = 'La publication a échoué. Réessayez plus tard.';
    try {
      await context.read<ReviewApplicationService>().submitReview(
        bookingId: widget.bookingId,
        rating: _rating,
        comment: _comment.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour votre avis !')),
      );
      Navigator.of(context).pop(true);
      return;
    } on ReviewAlreadyExistsFailure {
      message = 'Vous avez déjà publié un avis pour cette consultation.';
    } on ReviewInvalidStateFailure {
      message = 'Seule une consultation terminée peut être évaluée.';
    } on ReviewBookingNotFoundFailure {
      message = 'Cette réservation est introuvable.';
    } on ReviewFailure {
      // Keep the generic message.
    } catch (_) {
      // Keep the generic message.
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Donner un avis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comment s’est passée votre consultation avec '
              '${widget.expertName} ?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var star = 1; star <= 5; star++)
                  IconButton(
                    tooltip: '$star',
                    iconSize: 40,
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _rating = star),
                    icon: Icon(
                      star <= _rating ? Icons.star : Icons.star_border,
                      color: MentoraColors.gold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _comment,
              enabled: !_submitting,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Partagez votre expérience (facultatif)…',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: .08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _publish,
                icon: const Icon(Icons.send),
                label: const Text(
                  'Publier',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
