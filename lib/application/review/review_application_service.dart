import '../../domain/review/consultation_review.dart';
import '../../domain/review/consultation_review_repository.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import 'review_failure.dart';

/// Consultation reviews: submit one review per completed reservation and
/// read reviews back. No ranking, no averages, no moderation — the strict
/// business minimum.
final class ReviewApplicationService {
  const ReviewApplicationService({
    required AuthenticationSession session,
    required ConsultationReviewRepository repository,
    ConsultationMemoryApplicationService? memory,
  }) : _session = session,
       _repository = repository,
       _memory = memory;

  final AuthenticationSession _session;
  final ConsultationReviewRepository _repository;

  /// Optional memory producer; absent means no fact is recorded.
  final ConsultationMemoryApplicationService? _memory;

  /// Publishes the session client's single review of their completed
  /// reservation. Ownership and the completed state are verified
  /// transactionally by the repository.
  Future<void> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    final clientId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || clientId == null || clientId.isEmpty) {
      throw const ReviewUnauthenticatedFailure();
    }
    if (rating < 1 || rating > 5) {
      throw const ReviewInvalidRatingFailure();
    }

    try {
      await _repository.submit(
        bookingId: bookingId,
        clientId: clientId,
        rating: rating,
        comment: comment.trim(),
      );
    } on ConsultationReviewBookingNotFoundException {
      throw const ReviewBookingNotFoundFailure();
    } on ConsultationReviewStateException catch (error) {
      throw ReviewInvalidStateFailure(currentStatus: error.currentStatus);
    } on ConsultationReviewAlreadyExistsException {
      throw const ReviewAlreadyExistsFailure();
    } on ConsultationReviewRepositoryException catch (error) {
      throw ReviewRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ReviewRepositoryFailure(cause: error);
    }

    await _recordFact(bookingId, MemoryEntryType.reviewCreated, {
      'rating': rating,
      'comment': comment.trim(),
    });
  }

  /// Every review published for this expert, most recent first.
  Future<List<ConsultationReview>> getExpertReviews(String expertId) async {
    try {
      final reviews = await _repository.listByExpertId(expertId);
      return [...reviews]..sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        if (left == null) return right == null ? 0 : 1;
        if (right == null) return -1;
        return right.compareTo(left);
      });
    } on ConsultationReviewRepositoryException catch (error) {
      throw ReviewRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ReviewRepositoryFailure(cause: error);
    }
  }

  /// The reservation's review, or null when none was published.
  Future<ConsultationReview?> getBookingReview(String bookingId) async {
    try {
      return await _repository.findByBookingId(bookingId);
    } on ConsultationReviewRepositoryException catch (error) {
      throw ReviewRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ReviewRepositoryFailure(cause: error);
    }
  }

  /// Best-effort memory producer (ARC-MEM01): the business fact is recorded
  /// through the single memory door AFTER the operation succeeded; a memory
  /// failure never fails the business flow.
  Future<void> _recordFact(
    String bookingId,
    MemoryEntryType type,
    Map<String, Object?> payload,
  ) async {
    try {
      await _memory?.record(bookingId: bookingId, type: type, payload: payload);
    } catch (_) {
      // Best-effort by contract.
    }
  }
}
