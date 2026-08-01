import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/review/review_application_service.dart';
import '../domain/review/consultation_review.dart';
import '../theme/mentora_theme.dart';

/// Displays the reservation's single review — stars, comment, date — or
/// "Aucun avis." when none was published. Pure read projection.
class ConsultationReviewCard extends StatefulWidget {
  const ConsultationReviewCard({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ConsultationReviewCard> createState() => _ConsultationReviewCardState();
}

enum _ReviewCardState { loading, loaded, failed }

class _ConsultationReviewCardState extends State<ConsultationReviewCard> {
  _ReviewCardState _state = _ReviewCardState.loading;
  ConsultationReview? _review;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final review = await context
          .read<ReviewApplicationService>()
          .getBookingReview(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _review = review;
        _state = _ReviewCardState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _ReviewCardState.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _ReviewCardState.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(color: MentoraColors.gold),
          ),
        );
      case _ReviewCardState.failed:
        return const Text(
          'Les avis sont indisponibles pour le moment.',
          style: TextStyle(color: Colors.white54),
        );
      case _ReviewCardState.loaded:
        final review = _review;
        if (review == null) {
          return const Text(
            'Aucun avis.',
            style: TextStyle(color: Colors.white54),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewStars(rating: review.rating),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.comment,
                style: const TextStyle(color: Colors.white),
              ),
            ],
            if (review.createdAt case final createdAt?) ...[
              const SizedBox(height: 8),
              Text(
                'Publié le ${_displayDate(createdAt)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ],
        );
    }
  }

  static String _displayDate(DateTime instant) {
    final local = instant.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}

/// A plain 1..5 star strip; no averages, no half stars.
class ReviewStars extends StatelessWidget {
  const ReviewStars({super.key, required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= rating ? Icons.star : Icons.star_border,
            color: MentoraColors.gold,
            size: 18,
          ),
      ],
    );
  }
}
