import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/booking/booking_overview.dart';

/// Streams `bookings` documents as tolerant dashboard projections.
///
/// The mapping is read-tolerant: legacy documents without modern fields stay
/// readable, absent values stay null, and nothing is normalized or invented.
/// Firestore snapshots re-emit on every write, which gives the dashboard its
/// immediate refresh after payment, cancellation and reschedule.
final class FirestoreBookingOverviewRepository
    implements BookingOverviewRepository {
  const FirestoreBookingOverviewRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<BookingOverview>> watchForClient(String clientId) {
    return _watch('clientId', clientId);
  }

  @override
  Stream<List<BookingOverview>> watchForExpert(String expertId) {
    return _watch('expertId', expertId);
  }

  Stream<List<BookingOverview>> _watch(String field, String value) {
    return _firestore
        .collection('bookings')
        .where(field, isEqualTo: value)
        .snapshots()
        .map(
          (snapshot) => List<BookingOverview>.unmodifiable(
            snapshot.docs.map(
              (document) => _fromDocument(document.id, document.data()),
            ),
          ),
        )
        .handleError((Object error, StackTrace stackTrace) {
          Error.throwWithStackTrace(
            BookingOverviewRepositoryException(cause: error),
            stackTrace,
          );
        });
  }

  BookingOverview _fromDocument(String id, Map<String, dynamic> data) {
    return BookingOverview(
      bookingId: id,
      status: _string(data['status']) ?? 'unknown',
      clientId: _string(data['clientId']) ?? '',
      expertId: _string(data['expertId']) ?? '',
      expertName: _string(data['expertName']) ?? 'Expert',
      bookingDate: _string(data['bookingDate']) ?? '',
      bookingTime: _string(data['bookingTime']) ?? '',
      durationMinutes: _int(data['duration']),
      amountMinor: _int(data['amount']),
      currency: _string(data['currency']),
      expertTimezone: _string(data['expertTimezone']),
      aiSummary: _string(data['aiSummary']) ?? '',
      raw: Map<String, dynamic>.unmodifiable(data),
    );
  }

  String? _string(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }

  int? _int(Object? value) {
    if (value is int) return value;
    return null;
  }
}
