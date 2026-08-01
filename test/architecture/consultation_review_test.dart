import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/review/review_application_service.dart';
import 'package:mentora/application/review/review_failure.dart';
import 'package:mentora/domain/booking/booking_overview.dart';
import 'package:mentora/domain/review/consultation_review.dart';
import 'package:mentora/domain/review/consultation_review_repository.dart';
import 'package:mentora/screens/consultation_dashboard_screen.dart';
import 'package:mentora/screens/review_screen.dart';
import 'package:mentora/widgets/consultation_review_card.dart';
import 'package:mentora/widgets/expert_reviews_list.dart';
import 'package:provider/provider.dart';

void main() {
  group('ReviewApplicationService — submission', () {
    test('a completed reservation accepts the client review', () async {
      final repository = _ReviewRepository();
      final service = _service(repository);

      await service.submitReview(
        bookingId: 'b1',
        rating: 4,
        comment: '  Très utile.  ',
      );

      expect(repository.submitted, [('b1', 'client_1', 4, 'Très utile.')]);
    });

    test('a non-completed reservation is refused with its status', () async {
      for (final status in const ['pending_payment', 'cancelled']) {
        final repository = _ReviewRepository(
          error: ConsultationReviewStateException(currentStatus: status),
        );

        await expectLater(
          _service(repository).submitReview(
            bookingId: 'b1',
            rating: 5,
            comment: '',
          ),
          throwsA(
            isA<ReviewInvalidStateFailure>().having(
              (failure) => failure.currentStatus,
              'currentStatus',
              status,
            ),
          ),
        );
      }
    });

    test('a second review is refused cleanly', () {
      final repository = _ReviewRepository(
        error: const ConsultationReviewAlreadyExistsException(),
      );

      expect(
        () => _service(repository).submitReview(
          bookingId: 'b1',
          rating: 5,
          comment: '',
        ),
        throwsA(isA<ReviewAlreadyExistsFailure>()),
      );
    });

    test('a foreign client or unknown booking reads as not-found', () {
      final repository = _ReviewRepository(
        error: const ConsultationReviewBookingNotFoundException(),
      );

      expect(
        () => _service(repository).submitReview(
          bookingId: 'b1',
          rating: 5,
          comment: '',
        ),
        throwsA(isA<ReviewBookingNotFoundFailure>()),
      );
    });

    test('an out-of-range rating never reaches the repository', () async {
      final repository = _ReviewRepository();
      final service = _service(repository);

      for (final rating in const [0, 6]) {
        await expectLater(
          service.submitReview(bookingId: 'b1', rating: rating, comment: ''),
          throwsA(isA<ReviewInvalidRatingFailure>()),
        );
      }
      expect(repository.submitted, isEmpty);
    });

    test('an unauthenticated session fails typed', () {
      final repository = _ReviewRepository();
      final service = ReviewApplicationService(
        session: _Session(null),
        repository: repository,
      );

      expect(
        () => service.submitReview(bookingId: 'b1', rating: 5, comment: ''),
        throwsA(isA<ReviewUnauthenticatedFailure>()),
      );
      expect(repository.submitted, isEmpty);
    });
  });

  group('ReviewApplicationService — reads', () {
    test('expert reviews come back most recent first', () async {
      final repository = _ReviewRepository(
        stored: [
          _review(bookingId: 'b_old', createdAt: DateTime.utc(2026, 7, 1)),
          _review(bookingId: 'b_new', createdAt: DateTime.utc(2026, 8, 1)),
          _review(bookingId: 'b_pending', createdAt: null),
        ],
      );

      final reviews = await _service(repository).getExpertReviews('expert_1');

      expect(reviews.map((review) => review.bookingId).toList(), [
        'b_new',
        'b_old',
        'b_pending',
      ]);
    });

    test('a reservation without review reads as null', () async {
      final service = _service(_ReviewRepository());

      expect(await service.getBookingReview('b1'), isNull);
    });
  });

  group('Consultation reviews — adapter contract', () {
    final source = File(
      'lib/infrastructure/review/firestore_consultation_review_repository.dart',
    ).readAsStringSync();

    test('one transactional review per completed owned reservation', () {
      expect(source, contains('runTransaction'));
      expect(source, contains("collection('consultation_reviews')"));
      // Ownership and state are guarded on the booking read.
      expect(source, contains("data['clientId'] != clientId"));
      expect(source, contains("data['status'] != 'completed'"));
      // The review document is keyed by the booking: a second review is
      // structurally impossible.
      expect(source, contains('_reviews.doc(bookingId)'));
      expect(source, contains('ConsultationReviewAlreadyExistsException'));
      expect(source, contains("'createdAt': FieldValue.serverTimestamp()"));
      // The booking document is never written, and nothing is aggregated.
      expect(source, isNot(contains('transaction.update')));
      expect(source, isNot(contains('average')));
    });
  });

  group('ReviewScreen', () {
    testWidgets('publishing sends the rating and comment then returns', (
      tester,
    ) async {
      final repository = _ReviewRepository();
      await tester.pumpWidget(_reviewApp(repository));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('4'));
      await tester.enterText(find.byType(TextField), 'Très clair.');
      await tester.tap(find.text('Publier'));
      await tester.pumpAndSettle();

      expect(repository.submitted, [('b1', 'client_1', 4, 'Très clair.')]);
      expect(find.text('Merci pour votre avis !'), findsOneWidget);
      expect(find.byType(ReviewScreen), findsNothing);
    });

    testWidgets('publishing without a rating is blocked locally', (
      tester,
    ) async {
      final repository = _ReviewRepository();
      await tester.pumpWidget(_reviewApp(repository));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Publier'));
      await tester.pumpAndSettle();

      expect(repository.submitted, isEmpty);
      expect(
        find.text('Choisissez une note de 1 à 5 étoiles.'),
        findsOneWidget,
      );
      expect(find.byType(ReviewScreen), findsOneWidget);
    });

    testWidgets('a second review fails with a clear message', (tester) async {
      final repository = _ReviewRepository(
        error: const ConsultationReviewAlreadyExistsException(),
      );
      await tester.pumpWidget(_reviewApp(repository));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('5'));
      await tester.tap(find.text('Publier'));
      await tester.pumpAndSettle();

      expect(
        find.text('Vous avez déjà publié un avis pour cette consultation.'),
        findsOneWidget,
      );
      expect(find.byType(ReviewScreen), findsOneWidget);
    });
  });

  group('Review display widgets', () {
    testWidgets('the consultation card shows the published review', (
      tester,
    ) async {
      await tester.pumpWidget(
        _widgetApp(
          _ReviewRepository(
            stored: [
              _review(
                bookingId: 'b1',
                comment: 'Très bonne séance.',
                createdAt: DateTime.utc(2026, 8, 1),
              ),
            ],
          ),
          const ConsultationReviewCard(bookingId: 'b1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Très bonne séance.'), findsOneWidget);
      expect(find.textContaining('Publié le'), findsOneWidget);
      expect(find.text('Aucun avis.'), findsNothing);
    });

    testWidgets('the consultation card says so when no review exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        _widgetApp(
          _ReviewRepository(),
          const ConsultationReviewCard(bookingId: 'b1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aucun avis.'), findsOneWidget);
    });

    testWidgets('the expert profile lists reviews chronologically', (
      tester,
    ) async {
      await tester.pumpWidget(
        _widgetApp(
          _ReviewRepository(
            stored: [
              _review(
                bookingId: 'b_old',
                comment: 'Premier avis.',
                createdAt: DateTime.utc(2026, 7, 1),
              ),
              _review(
                bookingId: 'b_new',
                comment: 'Deuxième avis.',
                createdAt: DateTime.utc(2026, 8, 1),
              ),
            ],
          ),
          const ExpertReviewsList(expertId: 'expert_1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Premier avis.'), findsOneWidget);
      expect(find.text('Deuxième avis.'), findsOneWidget);
      // Most recent first.
      final newOffset = tester.getTopLeft(find.text('Deuxième avis.'));
      final oldOffset = tester.getTopLeft(find.text('Premier avis.'));
      expect(newOffset.dy, lessThan(oldOffset.dy));
    });

    testWidgets('an expert without reviews reads "Aucun avis."', (
      tester,
    ) async {
      await tester.pumpWidget(
        _widgetApp(
          _ReviewRepository(),
          const ExpertReviewsList(expertId: 'expert_1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aucun avis.'), findsOneWidget);
    });
  });

  group('Consultation dashboard — review entry point', () {
    testWidgets('a completed consultation offers "Donner un avis"', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_dashboardApp(status: 'completed'));
      await tester.pumpAndSettle();

      // Once as the timeline's next step, once as the action button.
      expect(find.text('Donner un avis'), findsNWidgets(2));
    });

    testWidgets('experts and active consultations get no review action', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _dashboardApp(status: 'completed', isExpert: true),
      );
      await tester.pumpAndSettle();
      // The timeline projection only — no action button for the expert.
      expect(find.text('Donner un avis'), findsOneWidget);

      await tester.pumpWidget(_dashboardApp(status: 'confirmed'));
      await tester.pumpAndSettle();
      expect(find.text('Donner un avis'), findsNothing);
    });
  });
}

ConsultationReview _review({
  required String bookingId,
  String comment = 'Très utile.',
  DateTime? createdAt,
}) {
  return ConsultationReview(
    reviewId: bookingId,
    bookingId: bookingId,
    expertId: 'expert_1',
    clientId: 'client_1',
    rating: 5,
    comment: comment,
    createdAt: createdAt,
  );
}

ReviewApplicationService _service(_ReviewRepository repository) {
  return ReviewApplicationService(
    session: _Session('client_1'),
    repository: repository,
  );
}

Widget _reviewApp(_ReviewRepository repository) {
  return MultiProvider(
    providers: [
      Provider<ReviewApplicationService>.value(value: _service(repository)),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReviewScreen(
                      bookingId: 'b1',
                      expertName: 'Awa',
                    ),
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _widgetApp(_ReviewRepository repository, Widget child) {
  return MultiProvider(
    providers: [
      Provider<ReviewApplicationService>.value(value: _service(repository)),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

Widget _dashboardApp({required String status, bool isExpert = false}) {
  final session = _Session(isExpert ? 'expert_1' : 'client_1',
      isExpert: isExpert);
  return MultiProvider(
    providers: [
      Provider<AuthenticationSession>.value(value: session),
      Provider<ReviewApplicationService>.value(
        value: ReviewApplicationService(
          session: session,
          repository: _ReviewRepository(),
        ),
      ),
    ],
    child: MaterialApp(
      home: ConsultationDashboardScreen(
        booking: BookingOverview(
          bookingId: 'b1',
          status: status,
          clientId: 'client_1',
          expertId: 'expert_1',
          expertName: 'Awa',
          bookingDate: '2026-08-03',
          bookingTime: '09:00',
          durationMinutes: 60,
          amountMinor: 50000,
          currency: 'XOF',
          expertTimezone: 'Africa/Bamako',
          aiSummary: '',
          raw: const <String, dynamic>{},
        ),
      ),
    ),
  );
}

final class _ReviewRepository implements ConsultationReviewRepository {
  _ReviewRepository({this.stored = const [], this.error});

  final List<ConsultationReview> stored;
  final Object? error;
  final List<(String, String, int, String)> submitted = [];

  @override
  Future<void> submit({
    required String bookingId,
    required String clientId,
    required int rating,
    required String comment,
  }) async {
    if (error case final cause?) throw cause;
    submitted.add((bookingId, clientId, rating, comment));
  }

  @override
  Future<ConsultationReview?> findByBookingId(String bookingId) async {
    for (final review in stored) {
      if (review.bookingId == bookingId) return review;
    }
    return null;
  }

  @override
  Future<List<ConsultationReview>> listByExpertId(String expertId) async {
    return [
      for (final review in stored)
        if (review.expertId == expertId) review,
    ];
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId, {this.isExpert = false});

  @override
  final String? currentUserId;

  @override
  final bool isExpert;

  @override
  bool get isAuthenticated => currentUserId != null;
}
