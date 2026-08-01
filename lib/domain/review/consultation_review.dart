/// A client's review of one completed consultation.
///
/// A review belongs to exactly ONE reservation — never to an expert
/// directly — and a reservation carries at most one review, ever.
final class ConsultationReview {
  final String reviewId;
  final String bookingId;
  final String expertId;
  final String clientId;

  /// 1..5 stars, enforced at construction.
  final int rating;
  final String comment;

  /// Server-side creation instant; null only during server-timestamp latency.
  final DateTime? createdAt;

  factory ConsultationReview({
    required String reviewId,
    required String bookingId,
    required String expertId,
    required String clientId,
    required int rating,
    required String comment,
    required DateTime? createdAt,
  }) {
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'must be between 1 and 5');
    }

    return ConsultationReview._(
      reviewId: reviewId,
      bookingId: bookingId,
      expertId: expertId,
      clientId: clientId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }

  const ConsultationReview._({
    required this.reviewId,
    required this.bookingId,
    required this.expertId,
    required this.clientId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
