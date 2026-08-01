import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/video_session/video_session_application_service.dart';
import 'package:mentora/application/video_session/video_session_failure.dart';
import 'package:mentora/domain/booking/booking_overview.dart';
import 'package:mentora/domain/video_session/video_session_provider.dart';
import 'package:mentora/infrastructure/video_session/livekit_cloud_adapter.dart';
import 'package:mentora/infrastructure/video_session/video_token_provider.dart';

void main() {
  group('VideoSessionApplicationService', () {
    test(
      'the client joins with the client role and full session info',
      () async {
        final provider = _RecordingProvider();
        final service = _service(provider);

        final info = await service.joinConsultation(_booking());

        final request = provider.joins.single;
        expect(request.bookingId, 'booking_1');
        expect(request.participantId, 'client_1');
        expect(request.role, VideoParticipantRole.client);

        expect(info.sessionId, 'session_1');
        expect(info.participantIdentity, 'client_1');
        expect(info.serverUrl, 'wss://fake');
        expect(info.accessToken, 'token_1');
      },
    );

    test('the expert joins with the expert role', () async {
      final provider = _RecordingProvider();
      final service = _service(provider, userId: 'expert_1');

      await service.joinConsultation(_booking());

      expect(provider.joins.single.role, VideoParticipantRole.expert);
    });

    test('a foreign user is forbidden before the provider', () async {
      final provider = _RecordingProvider();
      final service = _service(provider, userId: 'intruder');

      await expectLater(
        service.joinConsultation(_booking()),
        throwsA(isA<VideoSessionForbiddenFailure>()),
      );
      expect(provider.joins, isEmpty);
    });

    test('only confirmed or paid reservations are joinable', () async {
      final service = _service(_RecordingProvider());

      for (final status in const [
        'pending_payment',
        'pending',
        'cancelled',
        'completed',
      ]) {
        await expectLater(
          service.joinConsultation(_booking(status: status)),
          throwsA(isA<VideoSessionInvalidStateFailure>()),
          reason: status,
        );
      }

      await service.joinConsultation(_booking(status: 'paid'));
    });

    test('an unauthenticated session is rejected', () {
      final service = _service(_RecordingProvider(), userId: null);

      expect(
        () => service.joinConsultation(_booking()),
        throwsA(isA<VideoSessionUnauthenticatedFailure>()),
      );
    });

    test('provider failures surface typed for join and close', () async {
      final service = _service(
        _RecordingProvider(
          error: const VideoSessionProviderFailure(cause: 'down'),
        ),
      );

      await expectLater(
        service.joinConsultation(_booking()),
        throwsA(isA<VideoSessionUnavailableFailure>()),
      );
      await expectLater(
        service.closeSession('session_1'),
        throwsA(isA<VideoSessionUnavailableFailure>()),
      );
    });

    test('closing delegates to the provider', () async {
      final provider = _RecordingProvider();
      await _service(provider).closeSession('session_9');

      expect(provider.closed, ['session_9']);
    });
  });

  group('LiveKitCloudAdapter — session credentials', () {
    const adapter = LiveKitCloudAdapter();

    test('resolves the room and identity conventions', () async {
      final request = VideoSessionRequest(
        bookingId: 'booking_1',
        participantId: 'client_1',
        role: VideoParticipantRole.client,
      );

      final created = await adapter.createSession(request);
      final joined = await adapter.joinSession(request);

      expect(created.sessionId, 'mentora_consultation_booking_1');
      expect(joined.sessionId, created.sessionId);
      expect(joined.participantIdentity, 'booking_1_client_client_1');
      expect(joined.role, VideoParticipantRole.client);
      expect(joined.serverUrl, startsWith('wss://'));
    });

    test('tokens come from the provider, JWT-shaped, never hard-coded', () async {
      VideoSessionRequest request(String bookingId) => VideoSessionRequest(
        bookingId: bookingId,
        participantId: 'client_1',
        role: VideoParticipantRole.client,
      );

      final first = await adapter.joinSession(request('booking_1'));
      final second = await adapter.joinSession(request('booking_2'));

      expect(first.accessToken.split('.'), hasLength(3));
      expect(second.accessToken, isNot(first.accessToken));
    });

    test('token provider failures surface as provider failures', () async {
      const adapter = LiveKitCloudAdapter(
        tokenProvider: _FailingTokenProvider(),
      );

      await expectLater(
        adapter.joinSession(
          VideoSessionRequest(
            bookingId: 'booking_1',
            participantId: 'client_1',
            role: VideoParticipantRole.client,
          ),
        ),
        throwsA(isA<VideoSessionProviderFailure>()),
      );
    });

    test('closing the session completes', () async {
      await adapter.closeSession('mentora_consultation_booking_1');
    });
  });
}

final class _FailingTokenProvider implements VideoTokenProvider {
  const _FailingTokenProvider();

  @override
  Future<VideoAccessCredentials> credentialsFor({
    required String roomName,
    required String identity,
  }) async {
    throw StateError('token backend down');
  }
}

BookingOverview _booking({String status = 'confirmed'}) {
  return BookingOverview(
    bookingId: 'booking_1',
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
  );
}

VideoSessionApplicationService _service(
  VideoSessionProvider provider, {
  String? userId = 'client_1',
}) {
  return VideoSessionApplicationService(
    session: _Session(userId),
    provider: provider,
  );
}

final class _RecordingProvider implements VideoSessionProvider {
  _RecordingProvider({this.error});

  final Object? error;
  final List<VideoSessionRequest> joins = [];
  final List<String> closed = [];

  @override
  Future<VideoSessionInfo> createSession(VideoSessionRequest request) {
    return joinSession(request);
  }

  @override
  Future<VideoSessionInfo> joinSession(VideoSessionRequest request) async {
    if (error case final cause?) throw cause;
    joins.add(request);
    return VideoSessionInfo(
      sessionId: 'session_1',
      participantIdentity: request.participantId,
      role: request.role,
      serverUrl: 'wss://fake',
      accessToken: 'token_1',
    );
  }

  @override
  Future<void> closeSession(String sessionId) async {
    if (error case final cause?) throw cause;
    closed.add(sessionId);
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
