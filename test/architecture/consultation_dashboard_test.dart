import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/video_session/video_session_application_service.dart';
import 'package:mentora/domain/video_session/live_consultation_room.dart';
import 'package:mentora/domain/video_session/video_session_provider.dart';
import 'package:mentora/infrastructure/video_session/livekit_cloud_adapter.dart';
import 'package:mentora/domain/booking/booking_overview.dart';
import 'package:mentora/screens/consultation_dashboard_screen.dart';
import 'package:mentora/screens/live_consultation_screen.dart';
import 'package:mentora/widgets/video_track_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows every reservation fact of the confirmed booking', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(_booking()));

    expect(find.text('Espace consultation'), findsOneWidget);
    expect(find.text('Awa'), findsOneWidget);
    expect(find.text('Votre expert'), findsOneWidget);
    expect(find.text('Confirmée'), findsOneWidget);
    expect(find.text('2026-08-03'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('60 minutes'), findsOneWidget);
    expect(find.text('Africa/Bamako'), findsOneWidget);
    expect(find.text('Préparé ✓'), findsOneWidget);
  });

  testWidgets('shows the preparation placeholders', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(_booking()));

    expect(find.text('Informations de consultation'), findsOneWidget);
    // Private notes are expert-only: the client never sees the card.
    expect(find.text('Notes privées'), findsNothing);
    expect(find.text('Documents partagés'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Consultation vidéo'), findsOneWidget);
  });

  testWidgets('joining opens the live room through the video boundary', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(_booking()));

    await tester.ensureVisible(find.text('Rejoindre la consultation'));
    await tester.tap(find.text('Rejoindre la consultation'));
    await tester.pumpAndSettle();

    expect(find.byType(LiveConsultationScreen), findsOneWidget);
  });

  testWidgets('an expert session sees the client framing', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(_booking(), isExpert: true));

    expect(find.text('Avec votre client'), findsOneWidget);
    // The expert does get the private notes card.
    expect(find.text('Notes privées'), findsOneWidget);
  });

  testWidgets('legacy bookings without modern fields stay readable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _app(
        const BookingOverview(
          bookingId: 'b_legacy',
          status: 'paid',
          clientId: 'client_1',
          expertId: '',
          expertName: 'Expert',
          bookingDate: 'Lundi',
          bookingTime: '09:00',
          durationMinutes: null,
          amountMinor: null,
          currency: null,
          expertTimezone: null,
          aiSummary: '',
          raw: <String, dynamic>{},
        ),
      ),
    );

    expect(find.text('Payée'), findsOneWidget);
    expect(find.text('Lundi'), findsOneWidget);
    expect(find.textContaining('minutes'), findsNothing);
    expect(find.text('Fuseau horaire'), findsNothing);
  });
}

BookingOverview _booking() {
  return const BookingOverview(
    bookingId: 'b1',
    status: 'confirmed',
    clientId: 'client_1',
    expertId: 'expert_1',
    expertName: 'Awa',
    bookingDate: '2026-08-03',
    bookingTime: '09:00',
    durationMinutes: 60,
    amountMinor: 50000,
    currency: 'XOF',
    expertTimezone: 'Africa/Bamako',
    aiSummary: 'Résumé',
    raw: <String, dynamic>{},
  );
}

Widget _app(BookingOverview booking, {bool isExpert = false}) {
  final session = _Session(isExpert: isExpert);
  return MultiProvider(
    providers: [
      Provider<AuthenticationSession>.value(value: session),
      Provider<VideoSessionApplicationService>.value(
        value: VideoSessionApplicationService(
          session: session,
          provider: const LiveKitCloudAdapter(),
        ),
      ),
      Provider<LiveConsultationRoomProvider>.value(
        value: const _FakeRoomProvider(),
      ),
      Provider<VideoTrackViewBuilder>.value(
        value: (context, track) => const SizedBox.shrink(),
      ),
    ],
    child: MaterialApp(home: ConsultationDashboardScreen(booking: booking)),
  );
}

final class _FakeRoomProvider implements LiveConsultationRoomProvider {
  const _FakeRoomProvider();

  @override
  LiveConsultationRoom createRoom(VideoSessionInfo session) => _FakeRoom();
}

final class _FakeRoom implements LiveConsultationRoom {
  final StreamController<void> _changes = StreamController<void>.broadcast();

  LiveConsultationConnectionState _state =
      LiveConsultationConnectionState.disconnected;

  @override
  Future<void> connect() async {
    _state = LiveConsultationConnectionState.connected;
  }

  @override
  Future<void> disconnect() async {
    _state = LiveConsultationConnectionState.disconnected;
  }

  @override
  Future<void> reconnect() => connect();

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {}

  @override
  Future<void> setCameraEnabled(bool enabled) async {}

  @override
  LiveConsultationConnectionState get connectionState => _state;

  @override
  bool get microphoneEnabled => true;

  @override
  bool get cameraEnabled => true;

  @override
  String? get remoteParticipantIdentity => null;

  @override
  Object? get localVideoTrack => null;

  @override
  Object? get remoteVideoTrack => null;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> dispose() async {
    await _changes.close();
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session({required this.isExpert});

  @override
  final bool isExpert;

  @override
  String get currentUserId => isExpert ? 'expert_1' : 'client_1';

  @override
  bool get isAuthenticated => true;
}
