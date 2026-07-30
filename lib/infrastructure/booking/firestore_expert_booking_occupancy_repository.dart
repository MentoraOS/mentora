import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/booking/expert_booking_occupancy.dart';
import '../../domain/booking/expert_booking_occupancy_repository.dart';
import 'expert_booking_occupancy_firestore_mapper.dart';

final class FirestoreExpertBookingOccupancyRepository
    implements ExpertBookingOccupancyRepository {
  const FirestoreExpertBookingOccupancyRepository({
    required FirebaseFirestore firestore,
    ExpertBookingOccupancyFirestoreMapper mapper =
        const ExpertBookingOccupancyFirestoreMapper(),
  }) : _firestore = firestore,
       _mapper = mapper;

  final FirebaseFirestore _firestore;
  final ExpertBookingOccupancyFirestoreMapper _mapper;

  @override
  Future<List<ExpertBookingOccupancy>> loadForExpert(String expertId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('expertId', isEqualTo: expertId)
          .where('status', whereIn: const ['pending', 'confirmed', 'paid'])
          .get();

      return List<ExpertBookingOccupancy>.unmodifiable(
        snapshot.docs.map((document) => _mapper.fromMap(document.data())),
      );
    } on FormatException catch (error) {
      throw ExpertBookingOccupancyRepositoryException(
        cause: error,
        malformedData: true,
      );
    } on FirebaseException catch (error) {
      throw ExpertBookingOccupancyRepositoryException(cause: error);
    } catch (error) {
      throw ExpertBookingOccupancyRepositoryException(cause: error);
    }
  }
}
