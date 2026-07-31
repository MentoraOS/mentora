import '../../domain/booking/booking_creation.dart';
import '../../domain/booking/booking_creation_repository.dart';
import '../../domain/expert_catalog/consultation_offer.dart';
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

  /// Creates the initial Booking from the authoritative selected offer.
  ///
  /// [offer] is the single commercial source (AD-021). Its duration, amount
  /// and currency are copied into the reservation snapshot; no value is
  /// recomputed or defaulted here.
  Future<String> create({
    required String expertId,
    required String expertName,
    required String bookingDate,
    required String bookingTime,
    required String clientNeed,
    required String aiSummary,
    required ConsultationOffer offer,
  }) async {
    final clientId = _session.currentUserId;
    if (!_session.isAuthenticated ||
        clientId == null ||
        clientId.trim().isEmpty) {
      throw const BookingCreationUnauthenticatedFailure();
    }

    if (!offer.clientSelectable) {
      throw const BookingCreationOfferUnavailableFailure();
    }
    // A blank expert identity is an invalid request, not a mismatch; it is
    // reported by BookingCreation's own validation below.
    if (expertId.trim().isNotEmpty && offer.expertId != expertId) {
      throw const BookingCreationExpertMismatchFailure();
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
        offerId: offer.offerId,
        durationMinutes: offer.durationMinutes,
        amountMinor: offer.amountMinor,
        currency: offer.currency,
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
