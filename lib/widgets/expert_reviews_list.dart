import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/review/review_application_service.dart';
import '../domain/review/consultation_review.dart';
import 'consultation_review_card.dart';

/// The expert's published reviews, most recent first — a plain chronological
/// list. No average, no ranking, no clever sorting.
class ExpertReviewsList extends StatefulWidget {
  const ExpertReviewsList({super.key, required this.expertId});

  final String expertId;

  @override
  State<ExpertReviewsList> createState() => _ExpertReviewsListState();
}

enum _ReviewsListState { loading, loaded, failed }

class _ExpertReviewsListState extends State<ExpertReviewsList> {
  _ReviewsListState _state = _ReviewsListState.loading;
  List<ConsultationReview> _reviews = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final reviews = await context
          .read<ReviewApplicationService>()
          .getExpertReviews(widget.expertId);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _state = _ReviewsListState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _ReviewsListState.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _ReviewsListState.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        );
      case _ReviewsListState.failed:
        return const Text('Les avis sont indisponibles pour le moment.');
      case _ReviewsListState.loaded:
        if (_reviews.isEmpty) {
          return const Text('Aucun avis.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < _reviews.length; index++) ...[
              if (index > 0) const Divider(),
              _ReviewTile(review: _reviews[index]),
            ],
          ],
        );
    }
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ConsultationReview review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReviewStars(rating: review.rating),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment),
          ],
          if (review.createdAt case final createdAt?) ...[
            const SizedBox(height: 6),
            Text(
              _displayDate(createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  static String _displayDate(DateTime instant) {
    final local = instant.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}
