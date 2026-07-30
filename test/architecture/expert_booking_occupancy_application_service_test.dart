import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/booking/expert_booking_occupancy_application_service.dart';
import 'package:mentora/application/booking/expert_booking_occupancy_failure.dart';
import 'package:mentora/domain/booking/expert_booking_occupancy.dart';
import 'package:mentora/domain/booking/expert_booking_occupancy_repository.dart';

void main() {
  group('ExpertBookingOccupancyApplicationService', () {
    test(
      'forwards the requested Expert and preserves occupancy facts',
      () async {
        final occupied = [
          ExpertBookingOccupancy(bookingDate: 'Lundi', bookingTime: '09:00'),
        ];
        final repository = _Repository(result: occupied);
        final service = ExpertBookingOccupancyApplicationService(
          repository: repository,
        );

        final result = await service.loadForExpert('expert_1');

        expect(repository.requestedExpertId, 'expert_1');
        expect(result, occupied);
        expect(result.single.slotIdentity, 'Lundi|09:00');
      },
    );

    test('empty occupancy is a successful empty result', () async {
      final service = ExpertBookingOccupancyApplicationService(
        repository: _Repository(result: const []),
      );

      expect(await service.loadForExpert('expert_1'), isEmpty);
    });

    test('rejects an empty Expert identity', () {
      final service = ExpertBookingOccupancyApplicationService(
        repository: _Repository(result: const []),
      );

      expect(
        () => service.loadForExpert(' '),
        throwsA(isA<ExpertBookingOccupancyInvalidRequestFailure>()),
      );
    });

    test('maps repository read failure without converting it to empty', () {
      final cause = StateError('offline');
      final service = ExpertBookingOccupancyApplicationService(
        repository: _Repository(result: const [], error: cause),
      );

      expect(
        () => service.loadForExpert('expert_1'),
        throwsA(
          isA<ExpertBookingOccupancyReadFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });

    test('maps malformed persisted data explicitly', () {
      final cause = const FormatException('invalid booking');
      final service = ExpertBookingOccupancyApplicationService(
        repository: _Repository(
          result: const [],
          error: cause,
          malformed: true,
        ),
      );

      expect(
        () => service.loadForExpert('expert_1'),
        throwsA(
          isA<ExpertBookingOccupancyMalformedDataFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });
  });
}

final class _Repository implements ExpertBookingOccupancyRepository {
  _Repository({required this.result, this.error, this.malformed = false});

  final List<ExpertBookingOccupancy> result;
  final Object? error;
  final bool malformed;
  String? requestedExpertId;

  @override
  Future<List<ExpertBookingOccupancy>> loadForExpert(String expertId) async {
    requestedExpertId = expertId;
    if (error case final cause?) {
      throw ExpertBookingOccupancyRepositoryException(
        cause: cause,
        malformedData: malformed,
      );
    }
    return result;
  }
}
