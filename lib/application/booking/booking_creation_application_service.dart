import '../../domain/booking/booking_creation.dart';
import '../../domain/booking/booking_creation_repository.dart';
import '../authentication/authentication_session.dart';
import 'booking_creation_failure.dart';

typedef BookingChannelFactory = String Function();

final class BookingCreationApplicationService {
  BookingCreationApplicationService({
    required AuthenticationSession session,
    required BookingCreationRepository repository,
    BookingChannelFactory? channelFactory,
  }) : _session = session,
       _repository = repository,
       _channelFactory = channelFactory ?? _defaultChannel;

  final AuthenticationSession _session;
  final BookingCreationRepository _repository;
  final BookingChannelFactory _channelFactory;

  Future<String> create({
    required String expertId,
    required String expertName,
    required String bookingDate,
    required String bookingTime,
    required String clientNeed,
    required String aiSummary,
  }) async {
    final clientId = _session.currentUserId;
    if (!_session.isAuthenticated ||
        clientId == null ||
        clientId.trim().isEmpty) {
      throw const BookingCreationUnauthenticatedFailure();
    }

    late final BookingCreation booking;
    try {
      booking = BookingCreation(
        clientId: clientId,
        expertId: expertId,
        expertName: expertName,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        agoraChannel: _channelFactory(),
        clientNeed: clientNeed,
        aiSummary: aiSummary,
      );
    } on ArgumentError catch (error) {
      throw BookingCreationInvalidRequestFailure(cause: error);
    }

    try {
      return await _repository.create(booking);
    } on BookingCreationConflictException {
      throw const BookingCreationSlotConflictFailure();
    } on BookingCreationRepositoryException catch (error) {
      if (error.malformedData) {
        throw BookingCreationMalformedDataFailure(cause: error.cause);
      }
      if (error.infrastructureUnavailable) {
        throw BookingCreationInfrastructureUnavailableFailure(
          cause: error.cause,
        );
      }
      throw BookingCreationPersistenceFailure(cause: error.cause);
    } catch (error) {
      throw BookingCreationPersistenceFailure(cause: error);
    }
  }

  static String _defaultChannel() =>
      'mentora_${DateTime.now().millisecondsSinceEpoch}';
}
