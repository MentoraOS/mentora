import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/booking/booking_creation.dart';
import '../../domain/booking/booking_creation_repository.dart';
import 'booking_creation_firestore_mapper.dart';

final class FirestoreBookingCreationRepository
    implements BookingCreationRepository {
  const FirestoreBookingCreationRepository({
    required FirebaseFirestore firestore,
    BookingCreationFirestoreMapper mapper =
        const BookingCreationFirestoreMapper(),
  }) : _firestore = firestore,
       _mapper = mapper;

  final FirebaseFirestore _firestore;
  final BookingCreationFirestoreMapper _mapper;

  @override
  Future<String> create(BookingCreation booking) async {
    final bookingDocument = _firestore.collection('bookings').doc();
    final slotGuard = _slotGuardDocument(booking);

    try {
      await _firestore.runTransaction<void>((transaction) async {
        final guardSnapshot = await transaction.get(slotGuard);
        if (guardSnapshot.exists) {
          throw const BookingCreationConflictException();
        }

        transaction.set(bookingDocument, _mapper.toMap(booking));
        transaction.set(slotGuard, <String, dynamic>{
          'bookingId': bookingDocument.id,
          'expertId': booking.expertId,
          'bookingDate': booking.bookingDate,
          'bookingTime': booking.bookingTime,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      return bookingDocument.id;
    } on BookingCreationConflictException {
      rethrow;
    } on FirebaseException catch (error) {
      throw BookingCreationRepositoryException(
        cause: error,
        infrastructureUnavailable: _isUnavailable(error),
      );
    } catch (error) {
      throw BookingCreationRepositoryException(cause: error);
    }
  }

  DocumentReference<Map<String, dynamic>> _slotGuardDocument(
    BookingCreation booking,
  ) {
    final identity = jsonEncode(<String>[
      booking.expertId,
      booking.bookingDate,
      booking.bookingTime,
    ]);
    final documentId = base64Url
        .encode(utf8.encode(identity))
        .replaceAll('=', '');
    return _firestore.collection('_booking_creation_slots').doc(documentId);
  }

  bool _isUnavailable(FirebaseException error) {
    return error.code == 'unavailable' ||
        error.code == 'deadline-exceeded' ||
        error.code == 'network-request-failed';
  }
}
