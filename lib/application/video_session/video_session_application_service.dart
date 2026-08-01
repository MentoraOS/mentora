import '../../domain/booking/booking_overview.dart';
import '../../domain/video_session/video_session_provider.dart';
import '../authentication/authentication_session.dart';
import 'video_session_failure.dart';

/// Orchestrates joining the video session of a confirmed reservation.
///
/// Preconditions are verified here: the session user must be the booking's
/// client or expert, and the reservation must be confirmed (or legacy paid).
/// The provider behind the port owns everything vendor-specific — no RTC
/// logic and no SDK ever lives in this layer.
final class VideoSessionApplicationService {
  const VideoSessionApplicationService({
    required AuthenticationSession session,
    required VideoSessionProvider provider,
  }) : _session = session,
       _provider = provider;

  static const Set<String> _joinableStatuses = {'confirmed', 'paid'};

  final AuthenticationSession _session;
  final VideoSessionProvider _provider;

  Future<VideoSessionInfo> joinConsultation(BookingOverview booking) async {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const VideoSessionUnauthenticatedFailure();
    }

    final VideoParticipantRole role;
    if (userId == booking.expertId) {
      role = VideoParticipantRole.expert;
    } else if (userId == booking.clientId) {
      role = VideoParticipantRole.client;
    } else {
      throw const VideoSessionForbiddenFailure();
    }

    if (!_joinableStatuses.contains(booking.status)) {
      throw VideoSessionInvalidStateFailure(currentStatus: booking.status);
    }

    try {
      return await _provider.joinSession(
        VideoSessionRequest(
          bookingId: booking.bookingId,
          participantId: userId,
          role: role,
        ),
      );
    } on VideoSessionProviderFailure catch (error) {
      throw VideoSessionUnavailableFailure(cause: error.cause);
    } catch (error) {
      throw VideoSessionUnavailableFailure(cause: error);
    }
  }

  Future<void> closeSession(String sessionId) async {
    try {
      await _provider.closeSession(sessionId);
    } on VideoSessionProviderFailure catch (error) {
      throw VideoSessionUnavailableFailure(cause: error.cause);
    } catch (error) {
      throw VideoSessionUnavailableFailure(cause: error);
    }
  }
}
